import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/m_scaffold.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/core/constants.dart';
import 'package:miaomiaoswust/utils/status.dart';

import '../api/swuststore_api.dart';
import '../utils/widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isAccepted = false;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MScaffold(
      PaddingContainer(
        Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              '一站式统一身份登录',
              style: TextStyle(fontSize: 20),
            ),
            FTextField(
              controller: _accountController,
              hint: '请输入学号',
              textAlign: TextAlign.center,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => (value?.length == 10) ? null : '请输入十位数学号',
            ),
            FTextField.password(
              controller: _passwordController,
              label: null,
              hint: '请输入密码',
              textAlign: TextAlign.center,
            ),
            FButton(
                label: const Text(
                  '登录',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPress: () async {
                  if (!_formKey.currentState!.validate()) return;

                  const dialogButtonTextStyle =
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

                  if (!isAccepted) {
                    onPress() => Navigator.of(context).pop();
                    showAdaptiveDialog(
                        context: context,
                        builder: (context) => FDialog(
                                direction: Axis.horizontal,
                                title: const Text('服务协议及隐私保护'),
                                body: Text(Constants.agreementPrompt),
                                actions: [
                                  FButton(
                                    onPress: onPress,
                                    label: const Text(
                                      '不同意',
                                      style: dialogButtonTextStyle,
                                    ),
                                    style: FButtonStyle.outline,
                                  ),
                                  FButton(
                                      onPress: onPress,
                                      label: const Text('同意',
                                          style: dialogButtonTextStyle))
                                ]));
                    return;
                  }

                  final loginResult = await apiLogin(
                      _accountController.value.text,
                      _passwordController.value.text);
                  if (loginResult.status == Status.fail) {
                    showAdaptiveDialog(
                        context: context,
                        builder: (context) => FDialog(
                                direction: Axis.horizontal,
                                title: const Text('登录失败'),
                                body: Text(
                                    '无法登录到一站式服务系统：${loginResult.value ?? '未知错误'}'),
                                actions: [
                                  FButton(
                                      onPress: () {
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      label: const Text('好的',
                                          style: dialogButtonTextStyle))
                                ]));
                  }

                  // TODO 登录成功逻辑
                }),
            FCheckbox(
                value: isAccepted,
                onChange: (value) => setState(() => isAccepted = value),
                label: RichText(
                  text: TextSpan(
                      text: '我已阅读并同意',
                      style:
                          context.theme.typography.base.copyWith(fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                            text: '《用户服务协议》',
                            style: TextStyle(color: Colors.blue[900])),
                        TextSpan(
                            text: '《隐私协议政策》',
                            style: TextStyle(color: Colors.blue[900]))
                      ]),
                ))
          ]).wrap(context: context),
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: Constants.loginBgImage, fit: BoxFit.fill)),
      ),
      safeArea: false,
    );
  }
}
