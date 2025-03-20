import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:swustmeow/components/simple_setting_item.dart';
import 'package:swustmeow/components/simple_settings_group.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/entity/soa/course/courses_container.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../../api/swuststore_api.dart';
import '../../../data/values.dart';
import '../../../services/boxes/course_box.dart';
import '../../../utils/common.dart';
import 'course_share_permissions_page.dart';

class CourseShareSettingsPage extends StatefulWidget {
  const CourseShareSettingsPage({super.key});

  @override
  State<CourseShareSettingsPage> createState() =>
      _CourseShareSettingsPageState();
}

class _CourseShareSettingsPageState extends State<CourseShareSettingsPage> {
  bool _isLoading = false;
  TextEditingController? _codeController;
  bool _shareEnabled = false;
  TextEditingController? _remarkController;

  @override
  void initState() {
    super.initState();
    _loadShareStatus();
  }

  @override
  void dispose() {
    // _codeController?.dispose();
    _remarkController?.dispose();
    super.dispose();
  }

  Future<void> _loadShareStatus() async {
    setState(() => _isLoading = true);

    try {
      final account = GlobalService.soaService?.currentAccount?.account;
      if (account == null) {
        showErrorToast('未登录');
        return;
      }

      final result = await SWUSTStoreApiService.getCourseShareStatus(account);
      if (result.status == Status.ok) {
        setState(() => _shareEnabled = result.value ?? false);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createShareCode() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final account = GlobalService.soaService?.currentAccount?.account;
      if (account == null) {
        showErrorToast('请先登录');
        return;
      }

      final result = await SWUSTStoreApiService.createCourseShareCode(account);

      if (result.status != Status.ok) {
        showErrorToast(result.value);
        return;
      }

      final code = result.value['code'] as String;
      final shouldUpload = result.value['should_upload'] as bool;
      final expiresAt = result.value['expires_at'] as String;

      if (shouldUpload) {
        final uploadResult = await SWUSTStoreApiService.uploadCourseTable(
          account,
          ValueService.coursesContainers,
        );
        if (uploadResult.status != Status.ok) {
          showErrorToast(uploadResult.value ?? '未知错误（1）');
          return;
        }
      }

      if (!mounted) return;
      showAdaptiveDialog(
        context: context,
        builder: (context) => FDialog(
          title: Text('你的课表分享码'),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code,
                style: TextStyle(
                  fontSize: 50,
                  color: MTheme.primary2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '有效期至：$expiresAt',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '发送给你的小伙伴，让TA在本页面的“输入分享码”中输入即可~',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            FButton(
              onPress: () => Navigator.pop(context),
              label: Text('关闭'),
              style: FButtonStyle.primary,
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleGlobalShare(bool enabled) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final account = GlobalService.soaService?.currentAccount?.account;
      if (account == null) {
        showErrorToast('未登录');
        return;
      }

      final result = await SWUSTStoreApiService.updateCourseShareStatus(
        account,
        enabled,
      );

      if (result.status != Status.ok) {
        showErrorToast(result.value ?? '未知错误（2）');
        setState(() => _shareEnabled = !enabled); // 恢复原状态
        return;
      }

      setState(() => _shareEnabled = enabled);
      showSuccessToast(enabled ? '已开启课表共享' : '已关闭课表共享');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _accessSharedCourseTable() async {
    if (_isLoading) return;
    final code = _codeController!.text;
    final remark = _remarkController!.text.emptyThenNull;
    if (code.length != 4) {
      showErrorToast('请输入完整的分享码');
      return;
    }
    if (remark == Values.name) {
      showSuccessToast('发现彩蛋，感谢支持${Values.name}~', seconds: 10);
    }

    setState(() => _isLoading = true);

    try {
      final account = GlobalService.soaService?.currentAccount?.account;
      if (account == null) {
        showErrorToast('请先登录');
        return;
      }

      final result = await SWUSTStoreApiService.accessSharedCourseTable(
        account,
        code,
      );

      if (result.status != Status.ok) {
        showErrorToast(result.value);
        return;
      }

      List<CoursesContainer> containers =
          (result.value as List<dynamic>).cast();
      final id = containers.map((c) => c.sharerId).first;

      if (id == account) {
        setState(() => _isLoading = false);
        showErrorToast('不能和自己共享课程！');
        return;
      }

      final remarkMap =
          CourseBox.get('remarkMap') as Map<dynamic, dynamic>? ?? {};
      remarkMap[id] = remark;
      await CourseBox.put('remarkMap', remarkMap);

      List<CoursesContainer>? origin =
          (CourseBox.get('sharedContainers') as List<dynamic>? ?? []).cast();
      origin.removeWhere((c) => containers.map((r) => r.id).contains(c.id));

      for (final container in containers) {
        container.remark = remark;
        origin.add(container);
      }

      await CourseBox.put('sharedContainers', origin);
      ValueService.sharedContainers = origin;

      showSuccessToast('成功获取${remark ?? id}的课表');
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(title: '课程表共享设置'),
      content: ListView(
        padding: EdgeInsets.all(16),
        children: joinGap(
          gap: 8,
          axis: Axis.vertical,
          widgets: [
            _buildShareSection(),
            _buildAccessSection(),
            _buildPermissionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSection() {
    return SimpleSettingsGroup(
      children: [
        SimpleSettingItem(
          title: '分享课表',
          subtitle: '生成一个30分钟内有效的分享码',
          icon: FontAwesomeIcons.share,
          hasSuffix: false,
          onPress: _createShareCode,
        ),
      ],
    );
  }

  Widget _buildAccessSection() {
    return SimpleSettingsGroup(
      children: [
        SimpleSettingItem(
          title: '输入分享码',
          subtitle: '通过分享码获取他人的课表',
          icon: FontAwesomeIcons.key,
          hasSuffix: false,
          onPress: () {
            showAdaptiveDialog(
              context: context,
              builder: (context) => _buildShareCodeDialog(),
            );
          },
        )
      ],
    );
  }

  Widget _buildPermissionSection() {
    return SimpleSettingsGroup(
      children: [
        SimpleSettingItem(
          title: '共享权限管理',
          subtitle: '管理谁可以查看你的课表',
          icon: FontAwesomeIcons.lock,
          onPress: () {
            pushTo(context, '/course_table/settings/permission',
                const CourseSharePermissionsPage());
          },
        ),
        SimpleSettingItem(
          title: '全局共享开关',
          subtitle: '关闭后所有人都无法查看你的课表',
          icon: FontAwesomeIcons.globe,
          suffix: FSwitch(
            value: _shareEnabled,
            onChange: _toggleGlobalShare,
          ),
          onPress: () {
            pushTo(context, '/course_table/settings/permission',
                const CourseSharePermissionsPage());
          },
        ),
      ],
    );
  }

  Widget _buildShareCodeDialog() {
    _codeController = TextEditingController();
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
          Text('输入分享码'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Material(
              color: Colors.white,
              child: PinCodeTextField(
                appContext: context,
                textInputAction: TextInputAction.done,
                length: 4,
                controller: _codeController,
                autoFocus: true,
                pastedTextStyle: TextStyle(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.bold,
                ),
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  activeFillColor: Colors.white,
                  activeColor: MTheme.primary2,
                  selectedColor: MTheme.primary2,
                  inactiveColor: Colors.black.withValues(alpha: 0.2),
                ),
                onChanged: (_) {
                  _codeController!.text = _codeController!.text.toUpperCase();
                },
              ),
            ),
            FTextField(
              hint: '备注（可选）',
              controller: _remarkController,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        FButton(
          onPress: () {
            _codeController?.clear();
            _remarkController?.clear();
            Navigator.pop(context);
          },
          style: FButtonStyle.secondary,
          label: Text('取消'),
        ),
        FButton(
          onPress: _isLoading ? null : _accessSharedCourseTable,
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
