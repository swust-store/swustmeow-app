import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/entity/soa/leave/daily_leave_action.dart';
import 'package:miaomiaoswust/entity/soa/leave/daily_leave_display.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/common.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:miaomiaoswust/views/soa/soa_daily_leave_page.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDailyLeaves().then((_) => setState(() => _isLoading = false));
  }

  Future<void> _loadDailyLeaves() async {
    final result = await GlobalService.soaService?.getDailyLeaves();
    if (result == null || result.status != Status.ok) {
      if (mounted) showErrorToast(context, '加载失败：${result?.value ?? '未知错误'}');
      return;
    }

    List<DailyLeaveDisplay> list = (result.value as List<dynamic>).cast();
    setState(() => _dailyLeaves = list);
  }

  void _onSaveDailyLeave(DailyLeaveOptions options) {}

  @override
  Widget build(BuildContext context) {
    const fabDimension = 56.0;
    return Transform.flip(
        flipX: Values.isFlipEnabled.value,
        flipY: Values.isFlipEnabled.value,
        child: Scaffold(
          floatingActionButton: OpenContainer(
            openBuilder: (context, _) => SOADailyLeavePage(
              action: DailyLeaveAction.add,
              onSaveDailyLeave: _onSaveDailyLeave,
            ),
            middleColor: context.theme.colorScheme.background,
            closedColor: context.theme.colorScheme.secondary,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(fabDimension / 2),
              ),
            ),
            closedBuilder: (context, openContainer) => SizedBox(
              height: fabDimension,
              width: fabDimension,
              child: Center(
                child: FIcon(FAssets.icons.plus),
              ),
            ),
          ),
          body: FScaffold(
              contentPad: false,
              header: FHeader.nested(
                title: const Text(
                  '一站式请假',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                prefixActions: [
                  FHeaderAction(
                      icon: FIcon(FAssets.icons.chevronLeft),
                      onPress: () => Navigator.of(context).pop())
                ],
                suffixActions: [
                  FHeaderAction(
                      icon: FIcon(
                        FAssets.icons.rotateCw,
                        color: !_isLoading ? null : Colors.grey,
                      ),
                      onPress: () async {
                        if (_isLoading) return;
                        setState(() => _isLoading = true);
                        await _loadDailyLeaves();
                        setState(() => _isLoading = false);
                      }),
                ],
              ).withBackground,
              content: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: _isLoading && _dailyLeaves.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                        color: context.theme.colorScheme.primary,
                      ))
                    : SingleChildScrollView(
                        child: FTileGroup.builder(
                            divider: FTileDivider.none,
                            count: _dailyLeaves.length,
                            tileBuilder: (context, index) {
                              final leave = _dailyLeaves[index];
                              final [start, end] = leave.time.split('至');
                              final statusColor = leave.status.contains('等待')
                                  ? Colors.yellow
                                  : leave.status.contains('通过')
                                      ? Colors.green
                                      : Colors.red;
                              final leaveStatusColor =
                                  switch (leave.leaveStatus) {
                                '申请中' => Colors.yellow,
                                '未销假' => Colors.purple,
                                '已销假' => Colors.green,
                                _ => Colors.red
                              };

                              return OpenContainer(
                                openBuilder: (context, _) => SOADailyLeavePage(
                                  action: DailyLeaveAction.edit,
                                  onSaveDailyLeave: _onSaveDailyLeave,
                                  leaveId: leave.id,
                                ),
                                middleColor:
                                    context.theme.colorScheme.background,
                                closedBuilder: (context, openContainer) =>
                                    FTile(
                                  title: Text('日常请假'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '开始时间：$start\n结束时间：$end\n事由类型：${leave.type}\n外出地点：${leave.address}'),
                                      Text(
                                        '当前状态：${leave.status}',
                                        style: TextStyle(color: statusColor),
                                      ),
                                      Text(
                                        '请假状态：${leave.leaveStatus}',
                                        style:
                                            TextStyle(color: leaveStatusColor),
                                      ),
                                    ],
                                  ),
                                  suffixIcon: FButton.icon(
                                      onPress: () => openContainer(),
                                      child: FIcon(FAssets.icons.pen)),
                                ),
                              );
                            }),
                      ),
              ).withBackground),
        ));
  }
}
