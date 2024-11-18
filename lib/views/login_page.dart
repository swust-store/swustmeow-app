import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/m_scaffold.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/constants.dart';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '一站式统一身份登录',
                style: TextStyle(fontSize: 20),
              ),
              FTextField(
                controller: _accountController,
                hint: '请输入学号',
                textAlign: TextAlign.center,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    (value?.length == 10 ?? false) ? null : '请输入十位数学号',
              ),
              FTextField.password(
                controller: _passwordController,
                label: null,
                hint: '请输入密码',
                textAlign: TextAlign.center,
              ),
              FButton(
                  label: const Text('登录'),
                  onPress: () {
                    if (!_formKey.currentState!.validate()) return;

                    // TODO: 实现登录
                  }),
            ],
          ).wrap(context: context),
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: Constants(context).loginBgImage, fit: BoxFit.fill)),
      ),
      safeArea: false,
    );
  }
}
