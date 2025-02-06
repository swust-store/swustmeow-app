import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/will_pop_scope_blocker.dart';
import 'package:swustmeow/services/account/account_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/instruction_page.dart';

class AccountCard extends StatefulWidget with FTileMixin {
  const AccountCard({super.key, required this.service});

  final AccountService service;

  @override
  State<StatefulWidget> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  Widget build(BuildContext context) {
    final isLogin = widget.service.isLogin;

    return FTile(
      title: Text(widget.service.name),
      subtitle: Text(isLogin ? '已登录：${widget.service.usernameDisplay}' : '未登录'),
      suffixIcon: SizedBox(
        width: 84,
        child: FButton(
          onPress: () async => isLogin ? await logout() : await login(),
          label: Text(
            isLogin ? '退出' : '登录',
            style: TextStyle(
                color: isLogin ? Colors.red : Colors.green, fontSize: 14),
          ),
          prefix: FIcon(
            isLogin ? FAssets.icons.logOut : FAssets.icons.logIn,
            color: isLogin ? Colors.red : Colors.green,
            size: 14,
          ),
          style: FButtonStyle.outline,
        ),
      ),
    );
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  Future<void> login() async {
    pushReplacement(
        context,
        WillPopScopeBlocker(
            child: InstructionPage(page: widget.service.loginPage)),
        pushInto: true);
  }

  Future<void> logout() async {
    await widget.service.logout();
    _refresh();

    if (!mounted) return;
    if (GlobalService.soaService?.isLogin != true) {
      pushReplacement(
          context,
          WillPopScopeBlocker(
              child: InstructionPage(
            page: widget.service.loginPage,
          )),
          pushInto: true);
    }
  }
}
