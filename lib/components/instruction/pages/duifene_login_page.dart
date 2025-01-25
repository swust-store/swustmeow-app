import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/widget.dart';

import '../../../utils/status.dart';
import '../../icon_text_field.dart';
import '../button_state.dart';

class DuiFenELoginPage extends StatefulWidget {
  const DuiFenELoginPage(
      {super.key,
      required this.sc,
      required this.onStateChange,
      required this.onComplete});

  final ButtonStateContainer sc;
  final Function(ButtonStateContainer sc) onStateChange;
  final Function() onComplete;

  @override
  State<StatefulWidget> createState() => _DuiFenELoginPageState();
}

class _DuiFenELoginPageState extends State<DuiFenELoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    validate() {
      final username = _usernameController.text;
      final password = _passwordController.text;

      if (username.trim().isEmpty || password.trim().isEmpty) {
        return const ButtonStateContainer(
            ButtonState.dissatisfied, '账号或密码不能为空');
      }

      return const ButtonStateContainer(ButtonState.ok);
    }

    onChange() {
      final sc = validate();
      widget.onStateChange(sc);
    }

    const nextStepLabel = '开始西科之旅';

    return Form(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '登录到对分易平台',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            IconTextField(
              icon: FIcon(FAssets.icons.user),
              controller: _usernameController,
              hint: '请输入账号',
              autofocus: false,
              onChange: (_) => onChange(),
            ),
            IconTextField.password(
              icon: FIcon(FAssets.icons.lock),
              controller: _passwordController,
              label: null,
              hint: '请输入密码',
              autofocus: false,
              onChange: (_) => onChange(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, 4),
                  child: FIcon(
                    FAssets.icons.info,
                    size: 16,
                    alignment: Alignment.centerRight,
                    allowDrawingOutsideViewBox: true,
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                const Expanded(
                  child: Text(
                    '用于对分易签到、作业获取等功能，跳过后无法使用相关功能，可后续在设置中手动登录',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: FButton(
                        style: switch (widget.sc.state) {
                          ButtonState.ok => FButtonStyle.primary,
                          ButtonState.dissatisfied ||
                          ButtonState.loading =>
                            FButtonStyle.secondary,
                          ButtonState.error => FButtonStyle.destructive,
                        },
                        onPress:
                            widget.sc.state == ButtonState.ok ? _submit : null,
                        label: Row(
                          children: [
                            if (widget.sc.state == ButtonState.loading) ...[
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.grey,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(
                                width: 8.0,
                              ),
                            ],
                            widget.sc.state == ButtonState.ok
                                ? const Text(
                                    nextStepLabel,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                    .animate(
                                        onPlay: (controller) =>
                                            controller.repeat())
                                    .shimmer(
                                        duration: 1.5.seconds,
                                        delay: 0.5.seconds,
                                        color: Colors.grey)
                                : Text(
                                    widget.sc.state == ButtonState.loading
                                        ? '登录中'
                                        : (widget.sc.message ?? nextStepLabel),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                          ],
                        ))),
                const SizedBox(width: 16.0),
                FButton(
                  onPress: () {},
                  label: const Text('跳过'),
                  style: FButtonStyle.ghost,
                )
              ],
            )
          ]).wrap(context: context),
    );
  }

  Future<void> _submit() async {
    widget.onStateChange(const ButtonStateContainer(ButtonState.loading));
    final String username = _usernameController.value.text;
    final String password = _passwordController.value.text;

    if (GlobalService.duifeneService == null) {
      widget.onStateChange(
          const ButtonStateContainer(ButtonState.error, '本地服务未启动，请重启 APP'));
      return;
    }

    final result = await GlobalService.duifeneService!
        .login(username: username, password: password);
    if (result.status == Status.ok) {
      widget
          .onStateChange(const ButtonStateContainer(ButtonState.dissatisfied));
      widget.onComplete();
    } else {
      widget.onStateChange(ButtonStateContainer(
          ButtonState.error, '登录失败（${result.status.name}）'));
    }
  }
}
