import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/instruction/pages/duifene_login_page.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/duifene/duifene_signin_settings_page.dart';
import 'package:swustmeow/views/instruction_page.dart';

import '../../entity/duifene/duifene_sign_in_status.dart';

class DuiFenECard extends StatefulWidget {
  const DuiFenECard({super.key});

  @override
  State<StatefulWidget> createState() => _DuiFenECardState();
}

class _DuiFenECardState extends State<DuiFenECard> {
  bool _enabled = false;
  DuiFenESignInStatus _status = DuiFenESignInStatus.initializing;
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
          DuiFenESignInStatus.values.singleWhere((v) => v.toString() == statusString);

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
          return FTappable(
              onPress: () {
                if (isLogin) {
                  pushTo(context, const DuiFenESignInSettingsPage(),
                      pushInto: true);
                } else {
                  pushTo(
                      context,
                      const InstructionPage(
                        page: DuiFenELoginPage,
                      ),
                      pushInto: true);
                }
                setState(() {});
              },
              child: FCard(
                image: FIcon(FAssets.icons.bookUser),
                title: Text('对分易签到'),
                child: _getChild(isLogin),
              ));
        });
  }

  Widget _getChild(bool isLogin) {
    final realIsLogin = isLogin && _status != DuiFenESignInStatus.notAuthorized;
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
                          DuiFenESignInStatus.initializing => '初始化中',
                          DuiFenESignInStatus.waiting ||
                          DuiFenESignInStatus.watching ||
                          DuiFenESignInStatus.signing =>
                            '运行中',
                          DuiFenESignInStatus.stopped => '已停止',
                          DuiFenESignInStatus.notAuthorized => '未登录'
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
                              DuiFenESignInStatus.initializing => '请稍后',
                              DuiFenESignInStatus.waiting => '等待上课中',
                              DuiFenESignInStatus.watching =>
                                _currentCourseName == null
                                    ? '监听签到中'
                                    : '监听签到中：$_currentCourseName',
                              DuiFenESignInStatus.signing =>
                                _currentCourseName == null
                                    ? '签到中'
                                    : '签到中：$_currentCourseName',
                              DuiFenESignInStatus.stopped => '',
                              DuiFenESignInStatus.notAuthorized => '点击以登录'
                            },
                  style: style.copyWith(fontSize: 12)),
              ValueListenableBuilder(
                  valueListenable: GlobalService.duifeneSignTotalCount,
                  builder: (context, totalCount, child) {
                    return Text(
                      !realIsLogin
                          ? ''
                          : switch (_status) {
                              DuiFenESignInStatus.initializing ||
                              DuiFenESignInStatus.stopped ||
                              DuiFenESignInStatus.notAuthorized =>
                                '总签到$totalCount次',
                              DuiFenESignInStatus.waiting ||
                              DuiFenESignInStatus.watching ||
                              DuiFenESignInStatus.signing =>
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
