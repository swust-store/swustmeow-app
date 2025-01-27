import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/components/instruction/pages/duifene_login_page.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/views/duifene_settings_page.dart';
import 'package:miaomiaoswust/views/instruction_page.dart';

import '../../entity/duifene/duifene_status.dart';

class DuiFenECard extends StatefulWidget {
  const DuiFenECard({super.key, required this.cardStyle});

  final FCardStyle cardStyle;

  @override
  State<StatefulWidget> createState() => _DuiFenECardState();
}

class _DuiFenECardState extends State<DuiFenECard> {
  bool _enabled = false;
  DuiFenEStatus _status = DuiFenEStatus.initializing;
  String? _currentCourseName;
  int _signCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadTaskCallback();
  }

  void _loadStates() {
    final box = BoxService.duifeneBox;
    _enabled = (box?.get('enableAutomaticSignIn') as bool?) ?? false;
  }

  void _loadTaskCallback() {
    final service = FlutterBackgroundService();
    final box = BoxService.duifeneBox;

    service.on('duifeneStatus').listen((event) {
      final statusString = event!['status'] as String;
      final courseName = event['courseName'] as String?;

      final status =
          DuiFenEStatus.values.singleWhere((v) => v.toString() == statusString);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _status = status;
          _currentCourseName = courseName;
        });
      });
    });

    service.on('duifeneSigned').listen((_) async {
      final count = (box?.get('signCount') as int?) ?? 0;
      await box?.put('signCount', count + 1);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _signCount++;
          GlobalService.duifeneSignTotalCount.value++;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: GlobalService.duifeneService?.isLoginNotifier ??
            ValueNotifier(false),
        builder: (context, isLogin, child) {
          return Clickable(
              onClick: () {
                if (isLogin) {
                  pushTo(context, const DuiFenESettingsPage());
                } else {
                  pushTo(
                      context,
                      const InstructionPage(
                        page: DuiFenELoginPage,
                      ));
                }
              },
              child: FCard(
                image: FIcon(FAssets.icons.bookUser),
                title: Text('对分易签到'),
                style: widget.cardStyle,
                child: _getChild(isLogin),
              ));
        });
  }

  Widget _getChild(bool isLogin) {
    final realIsLogin = isLogin && _status != DuiFenEStatus.notAuthorized;
    final style =
        TextStyle(color: realIsLogin && _enabled ? Colors.grey : Colors.red);
    return SizedBox(
      height: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Divider(),
          Text(
              !realIsLogin
                  ? '未登录'
                  : !_enabled
                      ? '未启用'
                      : switch (_status) {
                          DuiFenEStatus.initializing => '初始化中',
                          DuiFenEStatus.waiting ||
                          DuiFenEStatus.watching ||
                          DuiFenEStatus.signing =>
                            '运行中',
                          DuiFenEStatus.stopped => '已停止',
                          DuiFenEStatus.notAuthorized => '未登录'
                        },
              style: style.copyWith(fontSize: 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  !realIsLogin
                      ? '点击以登录'
                      : !_enabled
                          ? '点击以配置'
                          : switch (_status) {
                              DuiFenEStatus.initializing => '请稍后',
                              DuiFenEStatus.waiting => '等待上课中',
                              DuiFenEStatus.watching =>
                                _currentCourseName == null
                                    ? '监听签到中'
                                    : '监听签到中：$_currentCourseName',
                              DuiFenEStatus.signing =>
                                _currentCourseName == null
                                    ? '签到中'
                                    : '签到中：$_currentCourseName',
                              DuiFenEStatus.stopped => '',
                              DuiFenEStatus.notAuthorized => '点击以登录'
                            },
                  style: style.copyWith(fontSize: 12)),
              ValueListenableBuilder(
                  valueListenable: GlobalService.duifeneSignTotalCount,
                  builder: (context, totalCount, child) {
                    return Text(
                      !realIsLogin
                          ? ''
                          : switch (_status) {
                              DuiFenEStatus.initializing ||
                              DuiFenEStatus.stopped ||
                              DuiFenEStatus.notAuthorized =>
                                '总签到$totalCount次',
                              DuiFenEStatus.waiting ||
                              DuiFenEStatus.watching ||
                              DuiFenEStatus.signing =>
                                '当前$_signCount次，总$totalCount次',
                            },
                      style: style.copyWith(fontSize: 10),
                    );
                  })
            ],
          )
        ],
      ),
    );
  }
}
