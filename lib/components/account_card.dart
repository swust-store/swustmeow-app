import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/divider_with_text.dart';
import 'package:swustmeow/components/utils/back_again_blocker.dart';
import 'package:swustmeow/entity/account.dart';
import 'package:swustmeow/services/account/account_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/widget.dart';
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
  Account? _isSwitching;

  @override
  void initState() {
    super.initState();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.service.isLogin;
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      // color: widget.color.withValues(alpha: 0.7),
      fontSize: 14,
    );

    final currentAccount = widget.service.currentAccount;
    final accounts = widget.service.savedAccounts;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 12.0,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    // color: widget.color,
                  ),
                ),
                SizedBox(height: 8),
                accounts.isNotEmpty
                    ? DividerWithText(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        child: Text(
                          '已保存的账号',
                          style: style.copyWith(
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : Text(
                        '未保存任何账号信息',
                        style: style.copyWith(
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: joinGap(
                    gap: 4,
                    axis: Axis.vertical,
                    // child: Divider(),
                    widgets: [
                      ...accounts.map(
                        (account) {
                          final isCurrent =
                              currentAccount?.equals(account) ?? false;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    (account.username ?? account.account) +
                                        (isCurrent ? '（当前）' : ''),
                                    style: style.copyWith(
                                      color: isCurrent
                                          ? Colors.green.withValues(alpha: 0.8)
                                          : Colors.black.withValues(alpha: 0.6),
                                    ),
                                    maxLines: 1,
                                    minFontSize: 6,
                                  ),
                                ),
                                if (!isCurrent && isLogin)
                                  FTappable(
                                    onPress: () async {
                                      _refresh(() => _isSwitching = account);
                                      await _switch(account, '切换');
                                      _refresh(() => _isSwitching = account);
                                    },
                                    child: Text(
                                      _isSwitching == null ||
                                              _isSwitching != account
                                          ? '切换'
                                          : '切换中...',
                                      style: style.copyWith(
                                          color: MTheme.primary2),
                                    ),
                                  ),
                                if (!isCurrent && !isLogin)
                                  FTappable(
                                    onPress: () async =>
                                        await _switch(account, '登录'),
                                    child: Text(
                                      '登录',
                                      style:
                                          style.copyWith(color: Colors.green),
                                    ),
                                  ),
                                if (isCurrent)
                                  FTappable(
                                    onPress: () async => await _logout(),
                                    child: Text(
                                      '退出',
                                      style: style.copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                if (!isCurrent) ...[
                                  SizedBox(width: 8),
                                  FTappable(
                                    onPress: () async => await _delete(account),
                                    child: Text(
                                      '删除',
                                      style: style.copyWith(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                FButton(
                  onPress: () async => await _addAccount(),
                  label: Text('添加账号'),
                  style: FButtonStyle.ghost,
                )
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                isLogin ? '已登录' : '未登录',
                style: TextStyle(
                  color: isLogin ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switch(Account account, String type) async {
    final r = await widget.service.switchTo(account);
    if (!mounted) return;
    if (r.status == Status.ok) {
      showSuccessToast(context, '$type成功！');
      setState(() {});
    } else {
      showErrorToast(context, '$type失败：${r.value}');
    }
  }

  Future<void> _delete(Account account) async {
    await widget.service.deleteAccount(account);
    setState(() {});
    if (!mounted) return;
    showSuccessToast(context, '删除成功！');
  }

  Future<void> _addAccount() async {
    pushReplacement(
      context,
      InstructionPage(loadPage: widget.service.getLoginPage),
      pushInto: true,
    );
  }

  Future<void> _logout() async {
    await widget.service.logout(notify: true);
    setState(() {});

    if (!mounted) return;
    showSuccessToast(context, '退出成功！');
    if (GlobalService.soaService?.isLogin != true) {
      pushReplacement(
        context,
        BackAgainBlocker(
          child: InstructionPage(loadPage: widget.service.getLoginPage),
        ),
        pushInto: true,
      );
    }
  }
}
