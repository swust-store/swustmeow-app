import 'package:flutter/material.dart';
import 'package:swustmeow/entity/account.dart';
import 'package:swustmeow/services/account/account_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/views/login_page.dart';

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

  Widget _buildSwitchingOverlay(Account account) {
    if (_isSwitching?.equals(account) != true) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(MTheme.radius),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '切换中...',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAccount = widget.service.currentAccount;
    final accounts = widget.service.savedAccounts;
    final isGuest = currentAccount?.isGuest == true;

    return ValueListenableBuilder(
      valueListenable: widget.service.isLoginNotifier,
      builder: (context, isLogin, _) {
        return Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MTheme.radius),
            border: Border.all(color: widget.color.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_circle, color: widget.color, size: 24),
                  SizedBox(width: 8),
                  Text(
                    widget.service.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isLogin
                              ? isGuest
                                  ? Colors.orange
                                  : Colors.green
                              : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(MTheme.radius),
                    ),
                    child: Text(
                      isLogin
                          ? isGuest
                              ? '游客'
                              : '已登录'
                          : '未登录',
                      style: TextStyle(
                        color: isLogin
                            ? isGuest
                                ? Colors.orange
                                : Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (accounts.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  '已保存账号',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                ...accounts.map((account) {
                  final isCurrent = currentAccount?.equals(account) ?? false;
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? widget.color.withValues(alpha: 0.08)
                              : Colors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(MTheme.radius),
                          border: Border.all(
                            color: isCurrent
                                ? widget.color.withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.15),
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: widget.color.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    isCurrent
                                        ? Icons.check_circle
                                        : Icons.account_circle_outlined,
                                    color:
                                        isCurrent ? widget.color : Colors.grey,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (account.username ?? account.account),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: isCurrent
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isCurrent && isLogin)
                                  _buildActionButton('切换', MTheme.primary2,
                                      () async {
                                    _refresh(() => _isSwitching = account);
                                    await _switch(account, '切换');
                                    _refresh(() => _isSwitching = null);
                                  }),
                                if (!isCurrent && !isLogin)
                                  _buildActionButton('登录', Colors.green,
                                      () => _switch(account, '登录')),
                                if (isCurrent)
                                  _buildActionButton('退出', Colors.red, _logout),
                                if (!isCurrent) ...[
                                  SizedBox(width: 8),
                                  _buildActionButton(
                                      '删除', Colors.red, () => _delete(account)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildSwitchingOverlay(account),
                    ],
                  );
                }),
              ] else
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      '暂无保存的账号',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addAccount,
                  icon: Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text('添加新账号'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MTheme.radius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MTheme.radius / 2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Future<void> _switch(Account account, String type) async {
    _refresh(() => _isSwitching = account);

    try {
      final r = await widget.service.switchTo(account);

      if (r.status == Status.ok) {
        showSuccessToast('$type成功！');
        setState(() {});
      } else {
        if (r.status == Status.manualCaptchaRequired ||
            r.status == Status.captchaFailed) {
          showErrorToast('$type失败：请手动删除并重新登录账号');
        } else {
          showErrorToast('$type失败：${r.message ?? r.value}');
        }
      }
    } finally {
      _refresh(() => _isSwitching = null);
    }
  }

  Future<void> _delete(Account account) async {
    await widget.service.deleteAccount(account);
    setState(() {});
    showSuccessToast('删除成功！');
  }

  Future<void> _addAccount() async {
    pushReplacement(
      context,
      '/login',
      LoginPage(loadPage: widget.service.getLoginPage),
      pushInto: true,
    );
  }

  Future<void> _logout() async {
    await widget.service.logout(notify: true);
    setState(() {});

    showSuccessToast('退出成功！');
  }
}
