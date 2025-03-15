import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/components/utils/pop_receiver.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_action.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_display.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/widget.dart';
import 'package:swustmeow/views/soa/soa_daily_leave_page.dart';

import '../../data/m_theme.dart';
import '../../entity/soa/leave/daily_leave_options.dart';
import '../../services/boxes/soa_box.dart';
import '../../services/value_service.dart';

class SOALeavesPage extends StatefulWidget {
  const SOALeavesPage({super.key});

  @override
  State<StatefulWidget> createState() => _SOALeavesPageState();
}

class _SOALeavesPageState extends State<SOALeavesPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<DailyLeaveDisplay> _dailyLeaves = [];
  DailyLeaveOptions? _template;
  final _fabKey = GlobalKey<ExpandableFabState>();
  bool _isRefreshing = false;
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  Future<void> _load() async {
    await _loadTemplate();
    await _loadDailyLeaves();
    _refresh(() => _isLoading = false);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  Future<void> _loadTemplate() async {
    final leaveTemplate = SOABox.get('leaveTemplate') as DailyLeaveOptions?;
    _refresh(() => _template = leaveTemplate);
  }

  Future<void> _loadDailyLeaves() async {
    if (Values.showcaseMode) {
      _refresh(() => _dailyLeaves = [
            DailyLeaveDisplay(
              id: '',
              time: '2025年02月19日至2025年02月21日',
              type: '病假',
              address: '市人民医院',
              status: '等待辅导员审批',
              leaveStatus: '申请中',
            ),
            DailyLeaveDisplay(
              id: '',
              time: '2025年01月02日至2025年01月03日',
              type: '事假',
              address: '幸福小区',
              status: '已通过',
              leaveStatus: '已销假',
            ),
            DailyLeaveDisplay(
              id: '',
              time: '2024年10月01日至2024年10月05日',
              type: '旅游',
              address: '迪士尼度假区',
              status: '已通过',
              leaveStatus: '已销假',
            )
          ]);
      return;
    }

    final result = await GlobalService.soaService?.getDailyLeaves();
    if (result == null || result.status != Status.ok) {
      if (mounted) showErrorToast('加载失败：${result?.value ?? '未知错误'}');
      return;
    }

    List<DailyLeaveDisplay> list = (result.value as List<dynamic>).cast();
    _refresh(() => _dailyLeaves = list);
  }

  void _onSaveDailyLeave(DailyLeaveOptions? options) {
    _loadDailyLeaves().then((_) => _refresh());
  }

  void _onDeleteDailyLeave(DailyLeaveOptions options) {
    _refresh(() => _dailyLeaves.removeWhere((d) => d.equalsTo(options)));
  }

  void _onReload() async {
    if (_isRefreshing || Values.showcaseMode) return;
    _refresh(() {
      _isRefreshing = true;
      _refreshAnimationController.repeat();
    });
    await _loadTemplate();
    await _loadDailyLeaves();
    _refresh(() {
      _isRefreshing = false;
      _refreshAnimationController.stop();
      _refreshAnimationController.reset();
    });
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: Stack(
        children: [
          PopReceiver(
            onPop: () async {
              _refresh(() => _isLoading = true);
              await _loadDailyLeaves();
              _refresh(() => _isLoading = false);
            },
            child: BasePage.gradient(
              headerPad: false,
              header: BaseHeader(
                title: Text(
                  '一站式请假',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                suffixIcons: [
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () async {
                          _onReload();
                        },
                        icon: RotationTransition(
                          turns: _refreshAnimationController,
                          child: FaIcon(
                            FontAwesomeIcons.rotateRight,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      if (_isRefreshing)
                        Positioned(
                          bottom: 5,
                          left: 20 / 2,
                          child: Text(
                            '刷新中...',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              ),
              content: _buildBody(),
            ),
          ),
          if (!Values.showcaseMode) SafeArea(child: _buildFAB()),
        ],
      ),
    );
  }

  Widget _buildFABOpenContainer({
    required String text,
    required Color color,
    required IconData icon,
    required Widget target,
  }) {
    return OpenContainer(
      openBuilder: (context, _) => target,
      middleColor: Colors.transparent,
      closedColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      closedBuilder: (context, openContainer) => Row(
        children: joinGap(
          gap: 8.0,
          axis: Axis.horizontal,
          widgets: [
            Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                _fabKey.currentState?.toggle();
                openContainer();
              },
              elevation: 0,
              backgroundColor: color,
              child: FaIcon(
                icon,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    if (_template == null) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: OpenContainer(
            openBuilder: (context, _) => SOADailyLeavePage(
              action: DailyLeaveAction.add,
              onSaveDailyLeave: _onSaveDailyLeave,
              onDeleteDailyLeave: _onDeleteDailyLeave,
              onRefresh: _onReload,
            ),
            middleColor: Colors.transparent,
            closedColor: MTheme.primary3,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            closedElevation: 6,
            closedBuilder: (context, openContainer) => FloatingActionButton(
              heroTag: null,
              onPressed: openContainer,
              elevation: 0,
              backgroundColor: MTheme.primary2,
              child: FaIcon(
                FontAwesomeIcons.plus,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return ExpandableFab(
      key: _fabKey,
      distance: 70,
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      overlayStyle: ExpandableFabOverlayStyle(blur: 3),
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: FaIcon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: MTheme.primary2,
      ),
      closeButtonBuilder: RotateFloatingActionButtonBuilder(
        child: FaIcon(
          FontAwesomeIcons.xmark,
          color: Colors.white,
        ),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: MTheme.primary2,
      ),
      children: [
        _buildFABOpenContainer(
          text: '使用模板创建',
          color: Colors.green,
          icon: FontAwesomeIcons.solidNoteSticky,
          target: SOADailyLeavePage(
            action: DailyLeaveAction.add,
            onSaveDailyLeave: _onSaveDailyLeave,
            onDeleteDailyLeave: _onDeleteDailyLeave,
            onRefresh: _onReload,
            template: _template!,
          ),
        ),
        _buildFABOpenContainer(
          text: '从空白创建',
          color: Colors.orange,
          icon: FontAwesomeIcons.noteSticky,
          target: SOADailyLeavePage(
            action: DailyLeaveAction.add,
            onSaveDailyLeave: _onSaveDailyLeave,
            onDeleteDailyLeave: _onDeleteDailyLeave,
            onRefresh: _onReload,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      String s when s.contains('等待') => Colors.orange,
      String s when s.contains('通过') => Colors.green,
      String s when s.contains('驳回') => Colors.red,
      _ => Colors.grey,
    };
  }

  Color _getLeaveStatusColor(String status) {
    return switch (status) {
      '申请中' => Colors.orange,
      '未销假' => MTheme.primary2,
      '已销假' => Colors.green,
      _ => Colors.grey,
    };
  }

  Widget _buildLeaveCard(DailyLeaveDisplay leave) {
    final [start, end] = leave.time.split('至');

    return OpenContainer(
      openBuilder: (context, _) => SOADailyLeavePage(
        action: DailyLeaveAction.edit,
        onSaveDailyLeave: _onSaveDailyLeave,
        onDeleteDailyLeave: _onDeleteDailyLeave,
        leaveId: leave.id,
        onRefresh: _onReload,
      ),
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      closedColor: Colors.transparent,
      closedElevation: 0,
      closedBuilder: (context, openContainer) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: MTheme.border),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (Values.showcaseMode) return;
              openContainer();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.calendarDays,
                        size: 16,
                        color: MTheme.primary2,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '日常请假',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Spacer(),
                      _buildStatusBadge(
                        leave.leaveStatus,
                        _getLeaveStatusColor(leave.leaveStatus),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    FontAwesomeIcons.clock,
                    '开始时间',
                    start,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    FontAwesomeIcons.hourglassEnd,
                    '结束时间',
                    end,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    FontAwesomeIcons.tag,
                    '请假类型',
                    leave.type,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    FontAwesomeIcons.locationDot,
                    '外出地点',
                    leave.address,
                  ),
                  SizedBox(height: 12),
                  _buildStatusBadge(
                    leave.status,
                    _getStatusColor(leave.status),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: MTheme.primary2,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              '加载中...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_dailyLeaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.boxOpen,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              '暂无请假记录',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 128.0),
      separatorBuilder: (context, index) => SizedBox(height: 16.0),
      itemCount: _dailyLeaves.length,
      itemBuilder: (context, index) => _buildLeaveCard(_dailyLeaves[index]),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Color(0xFF95A5A6),
        ),
        SizedBox(width: 8),
        Text(
          '$label：',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF95A5A6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
