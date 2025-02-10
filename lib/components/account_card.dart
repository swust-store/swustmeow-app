import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/will_pop_scope_blocker.dart';
import 'package:swustmeow/services/account/account_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/instruction_page.dart';

import '../data/m_theme.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({
    super.key,
    required this.service,
    required this.color,
  });

  final AccountService service;
  final Color color;

  @override
  State<StatefulWidget> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.service.isLogin;
    final style = TextStyle(
      fontWeight: FontWeight.w500,
      color: widget.color.withValues(alpha: 0.7),
      fontSize: 14,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: widget.color),
        borderRadius: BorderRadius.circular(MTheme.radius),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: widget.color),
                ),
                Text(
                  isLogin ? '已登录：${widget.service.usernameDisplay}' : '未登录',
                  style: style,
                ),
              ],
            ),
          ),
          FButton.icon(
            onPress: () async => isLogin ? await logout() : await login(),
            style: FButtonStyle.ghost,
            child: FaIcon(
              isLogin
                  ? FontAwesomeIcons.arrowRightFromBracket
                  : FontAwesomeIcons.arrowRightToBracket,
              color: isLogin ? Colors.red : Colors.green,
            ),
          )
        ],
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
