import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:forui/forui.dart';

class EditingSheet extends StatefulWidget {
  const EditingSheet(
      {super.key,
      required this.textController,
      required this.textNotifier,
      required this.finishEditing});

  final TextEditingController textController;
  final ValueNotifier<String> textNotifier;
  final Function() finishEditing;

  @override
  State<StatefulWidget> createState() => EditingSheetState();
}

class EditingSheetState extends State<EditingSheet> {
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.textNotifier,
        builder: (context, value, child) {
          double extraHeight = widget.textNotifier.value.split('\n').length *
              (context.theme.typography.base.fontSize! +
                  context.theme.typography.base.height!);

          return KeyboardVisibilityBuilder(
            builder: (context, isKeyboardVisible) {
              return AnimatedContainer(
                duration: const Duration(),
                padding: EdgeInsets.only(
                  bottom: isKeyboardVisible
                      ? MediaQuery.of(context).viewInsets.bottom
                      : 0,
                ),
                child: Container(
                    width: double.infinity,
                    height: 220 + extraHeight,
                    decoration: BoxDecoration(
                        color: context.theme.colorScheme.background,
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: context.theme.colorScheme.border))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: _buildForm(),
                      ),
                    )),
              );
            },
          );
        });
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
                  setState(() {
                    widget.textNotifier.value = value;
                  });
                },
              ),
              const SizedBox(
                height: 24.0,
              ),
              FButton(
                onPress: () {
                  setState(() {
                    _isNormalSave = true;
                  });
                  widget.finishEditing();
                  Navigator.of(context).pop();
                },
                label: const Text('保存'),
              )
            ],
          )),
    ]);
  }
}
