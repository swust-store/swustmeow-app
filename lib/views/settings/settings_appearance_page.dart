import 'package:flutter/material.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/boxes/common_box.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/common.dart';

import '../../utils/color.dart';

class SettingsAppearancePage extends StatefulWidget {
  final Function() onSelectColor;

  const SettingsAppearancePage({
    super.key,
    required this.onSelectColor,
  });

  @override
  State<SettingsAppearancePage> createState() => _SettingsAppearancePageState();
}

class _SettingsAppearancePageState extends State<SettingsAppearancePage> {
  Color? _selectedColor;
  bool _isSaving = false;

  // 预设主题色列表
  final List<Color> _presetColors = [
    const Color(0xFF1B7ADE), // 默认蓝色
    const Color(0xFF00BFA5), // 薄荷绿
    const Color(0xFFFF5252), // 珊瑚红
    const Color(0xFF7E57C2), // 丁香紫
    const Color(0xFFFFAB40), // 琥珀橙
    const Color(0xFF1565C0), // 普鲁士蓝
    const Color(0xFF00ACC1), // 青绿色
    const Color(0xFFFFD740), // 玉米黄
    const Color(0xFF303F9F), // 靛蓝色
    const Color(0xFF558B2F), // 苔藓绿
    const Color(0xFFC62828), // 赭石红
    const Color(0xFF6A1B9A), // 梅子紫
    const Color(0xFFE6A8A8), // 玫瑰金
    const Color(0xFF4CAF50), // 深橄榄绿
    const Color(0xFF455A64), // 深灰色
    const Color(0xFF673AB7), // 绛紫色
    const Color(0xFFEC407A), // 粉红色
    const Color(0xFF795548), // 青铜色
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  // 加载当前主题色
  Future<void> _loadCurrentTheme() async {
    final colorInt = CommonBox.get('themeColor') as int?;
    setState(() {
      _selectedColor = Color(colorInt ?? 0xFF1B7ADE);
    });
  }

  // 保存主题设置
  Future<void> _saveThemeSettings() async {
    if (_selectedColor == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await CommonBox.put('themeColor', _selectedColor?.toInt());

      // 更新应用主题色
      final colors = generatePrimaryColors(_selectedColor!);
      MTheme.primary1 = colors[0];
      MTheme.primary2 = colors[1];
      MTheme.primary3 = colors[2];
      MTheme.primary4 = colors[3];

      widget.onSelectColor();
      showSuccessToast('主题设置已保存');
    } catch (e) {
      showErrorToast('保存失败: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // 生成主题预览
  List<Color> _getThemePreview(Color baseColor) {
    return generatePrimaryColors(baseColor);
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
            '主题设置',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        content: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.all(MTheme.radius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 颜色选择区域标题
                Text(
                  '预设主题色',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                // 颜色网格选择器
                _buildColorGridSelector(),
                const SizedBox(height: 24),
                // 主题预览区域
                if (_selectedColor != null) _buildThemePreview(_selectedColor!),
                const Spacer(),
                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveThemeSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MTheme.primary2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '应用主题',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 主题色预览区域
  Widget _buildThemePreview(Color baseColor) {
    final previewColors = _getThemePreview(baseColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '预览效果',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),

        // 颜色条展示
        Row(
          children: List.generate(
            previewColors.length,
            (index) => Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: previewColors[index],
                  borderRadius: index == 0
                      ? BorderRadius.horizontal(left: Radius.circular(8))
                      : index == previewColors.length - 1
                          ? BorderRadius.horizontal(right: Radius.circular(8))
                          : null,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // UI元素预览
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: previewColors[1],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '按钮',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: previewColors[1],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 24,
              decoration: BoxDecoration(
                color: previewColors[2],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 颜色网格选择器
  Widget _buildColorGridSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      padding: EdgeInsets.symmetric(vertical: 16),
      itemCount: _presetColors.length,
      itemBuilder: (context, index) {
        final color = _presetColors[index];
        final isSelected = _selectedColor?.toInt() == color.toInt();

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        spreadRadius: 1,
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
