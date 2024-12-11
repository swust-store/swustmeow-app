import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../components/animated_text.dart';
import '../components/m_scaffold.dart';
import '../components/padding_container.dart';
import '../data/values.dart';
import '../utils/router.dart';
import '../utils/status.dart';
import '../utils/user.dart';
import '../utils/widget.dart';
import 'main_page.dart';

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
  bool isLoading = false;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MScaffold(
      safeArea: false,
      child: PaddingContainer(
        decoration: BoxDecoration(
            image:
                DecorationImage(image: Values.loginBgImage, fit: BoxFit.fill)),
        child: _buildForm(),
      ).loading(isLoading,
          child: const Center(
              child: AnimatedText(
            textList: ['登录中   ', '登录中.  ', '登录中.. ', '登录中...'],
            textStyle: TextStyle(fontSize: 14),
          ))),
    );
  }

  Widget _buildForm() => Form(
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
            autofocus: false,
          ),
          FTextField.password(
            controller: _passwordController,
            label: null,
            hint: '请输入密码',
            textAlign: TextAlign.center,
            autofocus: false,
          ),
          FButton(
              label: const Text(
                '登录',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPress: () async {
                if (!_formKey.currentState!.validate()) return;

                onPress() {
                  Navigator.of(context).pop();
                  FocusManager.instance.primaryFocus?.unfocus();
                }

                if (context.mounted) await _submitLogin(context, onPress);
              }),
          // FCheckbox(
          //     value: isAccepted,
          //     onChange: (value) => setState(() => isAccepted = value),
          //     label: RichText(
          //       text: TextSpan(
          //           text: '我已阅读并同意',
          //           style: context.theme.typography.base.copyWith(fontSize: 14),
          //           children: <TextSpan>[
          //             TextSpan(
          //                 text: '《用户服务协议》',
          //                 style: TextStyle(color: Colors.blue[900])),
          //             TextSpan(
          //                 text: '《隐私协议政策》',
          //                 style: TextStyle(color: Colors.blue[900]))
          //           ]),
          //     ))
        ]).wrap(context: context),
      );

  Future<void> _submitLogin(BuildContext context, final onPress) async {
    // if (!isAccepted) {
    //   _showAgreement(onPress);
    //   return;
    // }

    setState(() => isLoading = true);
    final String username = _accountController.value.text;
    final String password = _passwordController.value.text;

    final result = await performLogin(username, password);
    if (context.mounted && result.status == Status.ok) {
      setState(() => isLoading = false);
      pushTo(context, const MainPage());
    } else {
      _showLoginFailedDialog(result.value, onPress);
    }
  }

  void _showAgreement(final onPress) => showAdaptiveDialog(
      context: context,
      builder: (context) => FDialog(
              direction: Axis.horizontal,
              title: const Text('服务协议及隐私保护'),
              body: Text(Values.agreementPrompt),
              actions: [
                FButton(
                  onPress: onPress,
                  label: Text(
                    '不同意',
                    style: Values.dialogButtonTextStyle,
                  ),
                  style: FButtonStyle.outline,
                ),
                FButton(
                    onPress: () {
                      onPress();
                      setState(() => isAccepted = true);
                    },
                    label: Text('同意', style: Values.dialogButtonTextStyle))
              ]));

  void _showLoginFailedDialog(final String? message, final onPress) {
    showAdaptiveDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (context) => FDialog(
                direction: Axis.horizontal,
                title: const Text('登录失败'),
                body: Text('无法登录到一站式服务系统：${message ?? '未知错误'}'),
                actions: [
                  FButton(
                      onPress: () {
                        onPress();
                        setState(() => isLoading = false);
                      },
                      label: Text('好的', style: Values.dialogButtonTextStyle))
                ]));
  }
}
