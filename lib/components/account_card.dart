import 'package:flutter/material.dart';
import 'package:swustmeow/data/values.dart';
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                ),
              ),
              SizedBox(width: 8),
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
    final accounts = !Values.showcaseMode
        ? widget.service.savedAccounts
        : <Account>[
            currentAccount ??
                Account(account: 'testaccount', password: 'testaccount'),
          ];

    return ValueListenableBuilder(
      valueListenable: widget.service.isLoginNotifier,
      builder: (context, isLoginV, _) {
        final isLogin = isLoginV || Values.showcaseMode;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MTheme.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_circle,
                      color: widget.color,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.service.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isLogin ? Colors.green : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isLogin ? '已登录' : '未登录',
                      style: TextStyle(
                        color: isLogin ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              if (accounts.isNotEmpty) ...[
                SizedBox(height: 14),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                SizedBox(height: 14),

                // 账号列表
                ...accounts.map((account) {
                  final isCurrent =
                      (currentAccount?.equals(account) ?? false) ||
                          Values.showcaseMode;
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? widget.color.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: isCurrent
                              ? Border.all(
                                  color: widget.color.withValues(alpha: 0.2),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            // 账号信息
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    isCurrent
                                        ? Icons.check_circle
                                        : Icons.account_circle_outlined,
                                    color: isCurrent
                                        ? widget.color
                                        : Colors.grey.shade600,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      !Values.showcaseMode
                                          ? (account.username ??
                                              account.account)
                                          : '测试账号',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: isCurrent
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 操作按钮
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isCurrent &&
                                    isLogin &&
                                    !Values.showcaseMode)
                                  _buildActionButton('切换', MTheme.primary2,
                                      () async {
                                    _refresh(() => _isSwitching = account);
                                    await _switch(account, '切换');
                                    _refresh(() => _isSwitching = null);
                                  }),
                                if (!isCurrent &&
                                    !isLogin &&
                                    !Values.showcaseMode)
                                  _buildActionButton('登录', Colors.green,
                                      () => _switch(account, '登录')),
                                if (isCurrent)
                                  _buildActionButton('退出', Colors.red, _logout),
                                if (!isCurrent && !Values.showcaseMode) ...[
                                  SizedBox(width: 4),
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
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
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

              // 添加新账号按钮
              if (!Values.showcaseMode) ...[
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addAccount,
                    icon: Icon(Icons.add, size: 16, color: Colors.white),
                    label: Text('添加新账号', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _switch(Account account, String type) async {
    _refresh(() => _isSwitching = account);

    try {
      final r = await widget.service.switchTo(account);

      if (r.status == Status.ok) {
        showSuccessToast('$type成功！');
        if (!mounted) return;
        setState(() {});
      } else {
        showErrorToast('$type失败：${r.value}');
      }
    } finally {
      _refresh(() => _isSwitching = null);
    }
  }

  Future<void> _delete(Account account) async {
    await widget.service.deleteAccount(account);
    setState(() {});
    if (!mounted) return;
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
