import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/keyboard_fixer.dart';
import 'package:swustmeow/utils/widget.dart';

class TodoEditingSheet extends StatefulWidget {
  const TodoEditingSheet({
    super.key,
    required this.textController,
    required this.textNotifier,
    required this.finishEditing,
  });

  final TextEditingController textController;
  final ValueNotifier<String> textNotifier;
  final Function() finishEditing;

  @override
  State<StatefulWidget> createState() => TodoEditingSheetState();
}

class TodoEditingSheetState extends State<TodoEditingSheet> {
  late final String _originText;
  bool _isNormalSave = false;

  @override
  void initState() {
    super.initState();
    _originText = widget.textController.text;
  }

  @override
  void dispose() {
    if (!_isNormalSave) {
      widget.textController.text = _originText;
    }

    widget.finishEditing();
    super.dispose();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.textNotifier,
      builder: (context, value, child) {
        double extraHeight = widget.textNotifier.value.split('\n').length *
            (context.theme.typography.base.fontSize! +
                context.theme.typography.base.height!);

        return KeyboardFixer(
          child: Container(
            width: double.infinity,
            height: 200 + extraHeight,
            decoration: BoxDecoration(
                color: context.theme.colorScheme.background,
                border: Border.symmetric(
                  horizontal:
                      BorderSide(color: context.theme.colorScheme.border),
                ),
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: _buildForm(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(
        '编辑待办',
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
                controller: widget.textController,
                autofocus: true,
                onChange: (value) {
                  _refresh(() {
                    widget.textNotifier.value = value;
                  });
                },
              ),
              const SizedBox(
                height: 24.0,
              ),
              Row(
                children: joinGap(gap: 12.0, axis: Axis.horizontal, widgets: [
                  Expanded(
                      child: FButton(
                    onPress: () {
                      Navigator.of(context).pop();
                    },
                    label: const Text('取消'),
                    style: FButtonStyle.secondary,
                    prefix: FaIcon(
                      FontAwesomeIcons.xmark,
                      size: 16,
                    ),
                  )),
                  Expanded(
                      child: FButton(
                    onPress: () {
                      _refresh(() {
                        _isNormalSave = true;
                      });
                      widget.finishEditing();
                      Navigator.of(context).pop();
                    },
                    label: const Text('保存'),
                    style: FButtonStyle.primary,
                    prefix: FaIcon(
                      FontAwesomeIcons.floppyDisk,
                      color: Colors.white,
                    ),
                  ))
                ]),
              )
            ],
          )),
    ]);
  }
}
