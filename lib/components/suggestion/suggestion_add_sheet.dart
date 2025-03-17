import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/keyboard_fixer.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/widget.dart';

class SuggestionAddSheet extends StatefulWidget {
  const SuggestionAddSheet({super.key, required this.onAdd});

  final Future<String?> Function(String content) onAdd;

  @override
  State<StatefulWidget> createState() => _SuggestionAddSheetState();
}

class _SuggestionAddSheetState extends State<SuggestionAddSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, value, child) {
        final textSpan = TextSpan(
          text: value.text,
          style: context.theme.typography.base,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: null,
        );
        textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 48.0);

        int lineCount = textPainter.computeLineMetrics().length;
        lineCount = lineCount == 0 ? 1 : lineCount;

        double lineHeight = context.theme.typography.base.fontSize! *
            (context.theme.typography.base.height ?? 1.2);
        double textHeight = lineHeight * lineCount;
        double baseHeight = 220.0;
        double extraHeight =
            textHeight > lineHeight ? textHeight - lineHeight : 0;
        final radius = Radius.circular(MTheme.radius);

        return KeyboardFixer(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: baseHeight + extraHeight,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.background,
              border: Border.symmetric(
                horizontal: BorderSide(color: context.theme.colorScheme.border),
              ),
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
              ),
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: _buildForm(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '新增建议',
          style: context.theme.typography.base,
        ),
        const SizedBox(
          height: 24.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              FTextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(
                height: 24.0,
              ),
              Row(
                children: joinGap(
                  gap: 12.0,
                  axis: Axis.horizontal,
                  widgets: [
                    Expanded(
                      child: FButton(
                        onPress: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        label: const Text('取消'),
                        style: FButtonStyle.secondary,
                        prefix: FaIcon(
                          FontAwesomeIcons.xmark,
                          size: 16,
                          color: _isLoading ? Colors.grey : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FButton(
                        onPress: _isLoading
                            ? null
                            : () async {
                                final value = _controller.text;
                                if (value.isContentEmpty) {
                                  showErrorToast('建议内容不得为空');
                                  return;
                                }
                                if (value.length < 3) {
                                  showErrorToast('建议内容不得少于三个字');
                                  return;
                                }
                                if (value.length > 100) {
                                  showErrorToast('建议内容不得超过100个字');
                                  return;
                                }

                                setState(() => _isLoading = true);
                                final result = await widget.onAdd(value);
                                setState(() => _isLoading = false);

                                if (result != null) {
                                  showErrorToast(result);
                                } else {
                                  showSuccessToast('添加建议成功');
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                }
                              },
                        label: Text(
                          _isLoading ? '新增中...' : '新增',
                          style: TextStyle(
                            color: _isLoading ? Colors.grey : null,
                          ),
                        ),
                        style: FButtonStyle.primary,
                        prefix: _isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey,
                                ),
                              )
                            : FaIcon(
                                FontAwesomeIcons.plus,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
