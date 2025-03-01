import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/boxes/course_box.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../../api/swuststore_api.dart';
import '../../../utils/common.dart';

class CourseSharePermissionsPage extends StatefulWidget {
  const CourseSharePermissionsPage({super.key});

  @override
  State<CourseSharePermissionsPage> createState() =>
      _CourseSharePermissionsPageState();
}

class _CourseSharePermissionsPageState
    extends State<CourseSharePermissionsPage> {
  bool _isLoading = false;
  bool _isRefreshing = false;
  List<Map<String, dynamic>> _datas = [];
  TextEditingController? _remarkController;

  @override
  void initState() {
    super.initState();
    _loadSharedUsers(isRefresh: false);
  }

  Future<void> _loadSharedUsers({required bool isRefresh}) async {
    setState(() {
      if (isRefresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final account = GlobalService.soaService?.currentAccount?.account;
      if (account == null) {
        showErrorToast(context, '请先登录');
        return;
      }

      final result = await SWUSTStoreApiService.getSharedUsers(account);
      if (result.status != Status.ok) {
        if (!mounted) return;
        showErrorToast(context, result.value);
        return;
      }

      setState(() => _datas = result.value);
    } finally {
      setState(() {
        if (isRefresh) {
          _isRefreshing = false;
        } else {
          _isLoading = false;
        }
      });
    }
  }

  Future<void> _toggleUserPermission(String userId, bool enabled) async {
    if (_isLoading) return;

    final account = GlobalService.soaService?.currentAccount?.account;
    if (account == null) {
      showErrorToast(context, '请先登录');
      return;
    }

    final result = await SWUSTStoreApiService.controlCourseShare(
      account,
      viewerId: userId,
      enabled: enabled,
    );

    if (result.status != Status.ok) {
      if (!mounted) return;
      showErrorToast(context, result.value ?? '未知错误');
      return;
    }

    if (!mounted) return;
    showSuccessToast(
      context,
      enabled ? '已允许该用户查看课表' : '已禁止该用户查看课表',
    );

    await _loadSharedUsers(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '共享权限管理',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: MTheme.primary2,
                ),
              )
            : _datas.isEmpty
                ? _buildEmptyState()
                : _buildUserList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.userGroup,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '暂无共享用户',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '分享你的课表给其他用户后，\n他们会出现在这里',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _datas.length,
      itemBuilder: (context, index) {
        final user = _datas[index];
        final List<Map<String, dynamic>> sharedFrom =
            (user['shared_from'] as List<dynamic>).cast<Map<String, dynamic>>();
        final List<Map<String, dynamic>> sharedTo =
            (user['shared_to'] as List<dynamic>).cast<Map<String, dynamic>>();

        final bool iShared = sharedTo.isNotEmpty;
        final bool canViewMySchedule =
            sharedTo.any((share) => share['is_enabled'] == true);
        final bool iCanViewTheirSchedule =
            sharedFrom.any((share) => share['is_enabled'] == true);

        final remarkMap =
            CourseBox.get('remarkMap') as Map<dynamic, dynamic>? ?? {};
        final userId = user['user_id'];
        final remark = userId != null ? remarkMap[userId] : null;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: MTheme.border),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: joinGap(
                    gap: 16,
                    axis: Axis.horizontal,
                    widgets: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MTheme.primary2.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          color: MTheme.primary2,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (remark != null)
                              Text(
                                remark,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            Text(
                              userId,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: remark != null ? 12 : 16,
                                color:
                                    remark != null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FButton(
                        onPress: () {
                          showAdaptiveDialog(
                              context: context,
                              builder: (context) =>
                                  _buildSetRemarkDialog(userId));
                        },
                        label: Text(
                          '设置备注',
                          style: TextStyle(
                            fontSize: 14,
                            color: MTheme.primary2,
                          ),
                        ),
                        style: FButtonStyle.ghost,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 12),
                if (iShared) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '查看我的课表',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              canViewMySchedule ? '已允许' : '已禁止',
                              style: TextStyle(
                                color: canViewMySchedule
                                    ? Colors.green
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FSwitch(
                        value: canViewMySchedule,
                        onChange: (enabled) =>
                            _toggleUserPermission(user['user_id'], enabled),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '查看对方课表',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            iCanViewTheirSchedule ? '已允许' : '未授权',
                            style: TextStyle(
                              color: iCanViewTheirSchedule
                                  ? Colors.green
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetRemarkDialog(String sharerId) {
    _remarkController = TextEditingController();
    return FDialog(
      direction: Axis.horizontal,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MTheme.primary2.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              FontAwesomeIcons.key,
              color: MTheme.primary2,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Text('设置备注'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: FTextField(
          hint: '备注',
          autofocus: true,
          controller: _remarkController,
        ),
      ),
      actions: [
        FButton(
          onPress: () {
            _remarkController?.clear();
            Navigator.pop(context);
          },
          style: FButtonStyle.secondary,
          label: Text('取消'),
        ),
        FButton(
          onPress: _isLoading
              ? null
              : () async {
                  final remark = _remarkController?.text ?? '';
                  final remarkMap =
                      CourseBox.get('remarkMap') as Map<dynamic, dynamic>? ??
                          {};
                  remarkMap[sharerId] = remark;
                  await CourseBox.put('remarkMap', remarkMap);

                  final matches = ValueService.sharedContainers
                      .where((c) => c.sharerId == sharerId);
                  for (final match in matches) {
                    match.remark = remark;
                  }
                  await CourseBox.put(
                      'sharedContainers', ValueService.sharedContainers);

                  if (!mounted) return;
                  showSuccessToast(context, '设置成功！');
                  Navigator.pop(context);
                  setState(() {});
                },
          style: FButtonStyle.primary,
          label: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('确定'),
        ),
      ],
    );
  }
}
