import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/m_theme.dart';
import '../../utils/common.dart';
import '../../api/smeow_api.dart';
import '../../utils/status.dart';

class QunAddSheet extends StatefulWidget {
  const QunAddSheet({super.key});

  @override
  State<StatefulWidget> createState() => _QunAddSheetState();
}

class _QunAddSheetState extends State<QunAddSheet> {
  final _nameController = TextEditingController();
  final _qidController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: MTheme.primary2,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.userGroup,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '提交群聊',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MTheme.primary2.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: MTheme.primary2.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.circleInfo,
                                size: 14,
                                color: MTheme.primary2,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '提交须知',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: MTheme.primary2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• 请确保提交的群聊信息准确无误\n'
                            '• 提交后需经过审核才会显示\n'
                            '• 群号必须为纯数字\n'
                            '• 链接必须以 https:// 或 http:// 开头',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF34495E),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.triangleExclamation,
                                size: 14,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '严禁提交任何违法违规内容，违规者将承担相应法律责任！',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildInputField(
                      '群名称',
                      '请输入群聊名称',
                      _nameController,
                      FontAwesomeIcons.users,
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      '群号',
                      '请输入QQ群号（纯数字）',
                      _qidController,
                      FontAwesomeIcons.idCard,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      'QQ群链接',
                      '请输入QQ加群链接',
                      _linkController,
                      FontAwesomeIcons.link,
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      '群描述',
                      '请简要描述这个群的用途和内容',
                      _descriptionController,
                      FontAwesomeIcons.fileLines,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MTheme.primary2,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isLoading ? '提交中...' : '提交群聊',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF34495E),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 16, color: Color(0xFF95A5A6)),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final validateFlag = _validate();
    if (!validateFlag) return;

    setState(() {
      _isLoading = true;
    });

    // 调用 API 服务提交群聊信息
    final result = await SMeowApiService.submitQQGroup(
      name: _nameController.text,
      qid: _qidController.text,
      link: _linkController.text,
      description: _descriptionController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result.status != Status.ok) {
      showErrorToast(result.value ?? '未知错误');
      return;
    }

    Navigator.pop(context);

    // 显示成功提示
    showSuccessToast('提交成功，等待审核');
  }

  bool _validate() {
    final name = _nameController.text;
    final qid = _qidController.text;
    final link = _linkController.text;

    if (name.isEmpty || qid.isEmpty || link.isEmpty) {
      showErrorToast('请填写必填字段');
      return false;
    }

    // 验证群号是否为纯数字
    if (!RegExp(r'^\d+$').hasMatch(qid)) {
      showErrorToast('群号必须为纯数字');
      return false;
    }

    // 验证链接格式
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      showErrorToast('链接必须以http://或https://开头');
      return false;
    }

    return true;
  }
}
