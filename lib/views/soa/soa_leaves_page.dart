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

class _SOALeavesPageState extends State<SOALeavesPage> {
  bool _isLoading = true;
  List<DailyLeaveDisplay> _dailyLeaves = [];
  DailyLeaveOptions? _template;
  final _fabKey = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    _load();
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
      if (mounted) showErrorToast(context, '加载失败：${result?.value ?? '未知错误'}');
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
    await _loadTemplate();
    _onSaveDailyLeave(null);
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
                  IconButton(
                    onPressed: () async {
                      if (_isLoading) return;
                      _refresh(() => _isLoading = true);
                      await _loadDailyLeaves();
                      _refresh(() => _isLoading = false);
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.rotateRight,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                ],
              ),
              content: _buildBody(),
            ),
          ),
          SafeArea(child: _buildFAB()),
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

  Widget _buildBody() {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: MTheme.primary2,
            ),
          )
        : _dailyLeaves.isEmpty
            ? Center(child: Text('这里什么都木有~'))
            : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 128.0),
                separatorBuilder: (context, index) => SizedBox(height: 16.0),
                itemCount: _dailyLeaves.length,
                itemBuilder: (context, index) {
                  final leave = _dailyLeaves[index];
                  final [start, end] = leave.time.split('至');
                  final statusColor = leave.status.contains('等待')
                      ? Colors.orange
                      : leave.status.contains('通过')
                          ? Colors.green
                          : Colors.red;
                  final leaveStatusColor = switch (leave.leaveStatus) {
                    '申请中' => Colors.orange,
                    '未销假' => Colors.purple,
                    '已销假' => Colors.green,
                    _ => Colors.red
                  };
                  final style = TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withValues(alpha: 0.6),
                  );

                  final child = Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '日常请假',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '开始时间：$start\n结束时间：$end\n事由类型：${leave.type}\n外出地点：${leave.address}',
                          style: style,
                        ),
                        Text(
                          '当前状态：${leave.status}',
                          style: style.copyWith(color: statusColor),
                        ),
                        Text(
                          '请假状态：${leave.leaveStatus}',
                          style: style.copyWith(color: leaveStatusColor),
                        ),
                      ],
                    ),
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: MTheme.border),
                      borderRadius: BorderRadius.circular(MTheme.radius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: OpenContainer(
                      openBuilder: (context, _) => SOADailyLeavePage(
                        action: DailyLeaveAction.edit,
                        onSaveDailyLeave: _onSaveDailyLeave,
                        onDeleteDailyLeave: _onDeleteDailyLeave,
                        leaveId: leave.id,
                        onRefresh: _onReload,
                      ),
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(MTheme.radius),
                        ),
                      ),
                      closedBuilder: (context, openContainer) => child,
                    ),
                  );
                },
              );
  }
}
