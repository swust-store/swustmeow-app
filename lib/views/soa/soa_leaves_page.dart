import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/components/utils/pop_receiver.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_action.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_display.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/views/soa/soa_daily_leave_page.dart';

import '../../data/m_theme.dart';
import '../../data/values.dart';
import '../../entity/soa/leave/daily_leave_options.dart';

class SOALeavesPage extends StatefulWidget {
  const SOALeavesPage({super.key});

  @override
  State<StatefulWidget> createState() => _SOALeavesPageState();
}

class _SOALeavesPageState extends State<SOALeavesPage> {
  bool _isLoading = true;
  List<DailyLeaveDisplay> _dailyLeaves = [];
  final _canAddOrEdit = false; // TODO 解决新增和编辑编码问题后开放入口

  @override
  void initState() {
    super.initState();
    _loadDailyLeaves().then((_) => _refresh(() => _isLoading = false));
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  Future<void> _loadDailyLeaves() async {
    final result = await GlobalService.soaService?.getDailyLeaves();
    if (result == null || result.status != Status.ok) {
      if (mounted) showErrorToast(context, '加载失败：${result?.value ?? '未知错误'}');
      return;
    }

    List<DailyLeaveDisplay> list = (result.value as List<dynamic>).cast();
    _refresh(() => _dailyLeaves = list);
  }

  void _onSaveDailyLeave(DailyLeaveOptions options) {}

  @override
  Widget build(BuildContext context) {
    const iconSize = 40.0;

    return Transform.flip(
      flipX: Values.isFlipEnabled.value,
      flipY: Values.isFlipEnabled.value,
      child: PopReceiver(
        onPop: () async {
          _refresh(() => _isLoading = true);
          await _loadDailyLeaves();
          _refresh(() => _isLoading = false);
        },
        child: BasePage(
          gradient: LinearGradient(
            colors: [MTheme.primary1, MTheme.primary2, Colors.white],
            transform: const GradientRotation(pi / 2),
          ),
          top: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      children: [
                        Text(
                          '一站式请假',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _canAddOrEdit && _dailyLeaves.isEmpty
                              ? '点击右下加号以新增请假'
                              : '当前存在请假：${_dailyLeaves.length}个',
                          style: TextStyle(
                            color: MTheme.primaryText,
                            fontSize: 14,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: iconSize,
                    child: IconButton(
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
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottom: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final body = _buildBody();
    final fab = _buildFAB();

    return Stack(
      children: [
        body,
        if (_canAddOrEdit)
          Positioned(
            bottom: 48,
            right: 16,
            child: fab,
          )
      ],
    );
  }

  Widget _buildFAB() {
    const fabDimension = 56.0;
    return OpenContainer(
      openBuilder: (context, _) => SOADailyLeavePage(
        action: DailyLeaveAction.add,
        onSaveDailyLeave: _onSaveDailyLeave,
      ),
      middleColor: context.theme.colorScheme.background,
      closedColor: MTheme.primary3,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(fabDimension / 2)),
      ),
      closedBuilder: (context, openContainer) => Container(
        height: fabDimension,
        width: fabDimension,
        color: MTheme.primary3,
        child: Center(
          child: FaIcon(FontAwesomeIcons.plus, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
            color: MTheme.primary2,
          ))
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
                child: _canAddOrEdit
                    ? OpenContainer(
                        openBuilder: (context, _) => SOADailyLeavePage(
                          action: DailyLeaveAction.edit,
                          onSaveDailyLeave: _onSaveDailyLeave,
                          leaveId: leave.id,
                        ),
                        closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(MTheme.radius),
                          ),
                        ),
                        closedBuilder: (context, openContainer) => child,
                      )
                    : child,
              );
            },
          );
  }
}
