import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/will_pop_scope_blocker.dart';
import 'package:miaomiaoswust/services/account/account_service.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/views/instruction_page.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({super.key, required this.service});

  final AccountService service;

  @override
  State<StatefulWidget> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  Widget build(BuildContext context) {
    final isLogin = widget.service.isLogin;

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: context.theme.colorScheme.border),
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.service.name,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                isLogin ? '已登录：${widget.service.usernameDisplay}' : '未登录',
                style: TextStyle(fontSize: 14),
              )
            ],
          )),
          FButton(
            onPress: () async => isLogin ? await logout() : await login(),
            label: Text(
              isLogin ? '退出' : '登录',
              style: TextStyle(
                  color: isLogin ? Colors.red : Colors.green, fontSize: 14),
            ),
            prefix: FIcon(
              isLogin ? FAssets.icons.logOut : FAssets.icons.logIn,
              color: isLogin ? Colors.red : Colors.green,
              size: 16,
            ),
            style: FButtonStyle.outline,
          )
        ],
      ),
    );
  }

  Future<void> login() async {
    pushReplacement(
        context, const WillPopScopeBlocker(child: InstructionPage()));
  }

  Future<void> logout() async {
    await widget.service.logout();
    setState(() => {});

    if (!mounted) return;
    if (GlobalService.soaService?.isLogin != true) {
      pushReplacement(
          context,
          WillPopScopeBlocker(
              child: InstructionPage(
            page: widget.service.loginPage,
          )));
    }
  }
}
