import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';

import '../../entity/todo.dart';

class AnimatedTodoItem extends StatefulWidget {
  const AnimatedTodoItem(
      {super.key,
      required this.todo,
      required this.isEditing,
      required this.onDelete,
      required this.onFinishEdit,
      required this.onEdit,
      required this.onFinish});

  final Todo todo;
  final bool isEditing;
  final VoidCallback onDelete;
  final Function(String) onFinishEdit;
  final Function() onEdit;
  final Function() onFinish;

  @override
  State<StatefulWidget> createState() => _AnimatedTodoItemState();
}

class _AnimatedTodoItemState extends State<AnimatedTodoItem>
    with TickerProviderStateMixin {
  late bool _isEditing;
  late AnimationController _controller;
  late Animation<double> _animation;
  late TextEditingController _textController;
  late SlidableController _slidableController;
  double _slidableAnimationValue = 0.0;
  late final ValueNotifier<String> _textNotifier;
  bool _isEditingSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
    _textController = TextEditingController();
    _textController.text = widget.todo.content;
    _textNotifier = ValueNotifier<String>(_textController.text);
    _slidableController = SlidableController(this);
    _slidableController.animation.addListener(() => setState(() =>
        _slidableAnimationValue = _slidableController.animation.value * 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _slidableController.dispose();
    super.dispose();
  }

  void _startEditing() {
    if (widget.todo.isFinished) return;

    _showEditingSheet();
    widget.onEdit();
  }

  void _showEditingSheet() {
    showFSheet(
        context: context,
        builder: (context) => _EditingSheet(
              textController: _textController,
              textNotifier: _textNotifier,
              finishEditing: _finishEditing,
            ),
        side: FLayout.btt,
        mainAxisMaxRatio: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isEditing = true;
        _isEditingSheetOpen = true;
      });
    });
  }

  void _finishEditing() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isEditing = false;
        _isEditingSheetOpen = false;
      });
    });

    final newContent = _textController.text.trim();
    if (newContent != widget.todo.content) {
      widget.onFinishEdit(newContent);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && !_isEditingSheetOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEditingSheet();
      });
    }

    final isNew = widget.todo.isNew;
    widget.todo.isNew = false;

    final container = Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Slidable(
          key: ValueKey(widget.todo.uuid),
          controller: _slidableController,
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => widget.onDelete(),
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
                icon: Icons.delete,
              ),
            ],
          ),
          child: GestureDetector(
            onDoubleTap: _startEditing,
            child: _buildRow(),
          ),
        ));
    return isNew
        ? FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: _animation,
              child: container,
            ),
          )
        : container;
  }

  Widget _buildRow() {
    final isEmpty = widget.todo.content.isEmpty || widget.todo.isNew;
    final textStyle = context.theme.typography.base.copyWith(
        fontSize: 18,
        color: Colors.black.withOpacity(isEmpty ? 0.6 : 1),
        fontWeight: FontWeight.bold);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(widget.todo.color),
        borderRadius: BorderRadius.horizontal(
            left: const Radius.circular(8),
            right: Radius.circular(8 * (1 - _slidableAnimationValue))),
      ),
      child: Row(
        children: [
          Transform(
              transform: Matrix4.translationValues(0, 2, 0),
              child: _buildCheckButton()),
          const SizedBox(
            width: 8,
          ),
          Expanded(
              child: Text(
            isEmpty ? '(空待办)' : widget.todo.content,
            style: textStyle,
          ))
        ],
      ),
    );
  }

  Widget _buildCheckButton() {
    return Clickable(
        onPress: widget.onFinish,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              color: widget.todo.isFinished || _isEditing
                  ? Colors.transparent
                  : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              border: widget.todo.isFinished || _isEditing
                  ? null
                  : Border.all(color: Colors.black, width: 2)),
          child: widget.todo.isFinished
              ? FIcon(
                  FAssets.icons.check,
                  color: Colors.black,
                )
              : _isEditing
                  ? FIcon(FAssets.icons.pencil, color: Colors.black)
                  : null,
        ));
  }
}

class _EditingSheet extends StatefulWidget {
  const _EditingSheet(
      {required this.textController,
      required this.textNotifier,
      required this.finishEditing});

  final TextEditingController textController;
  final ValueNotifier<String> textNotifier;
  final Function() finishEditing;

  @override
  State<StatefulWidget> createState() => _EditingSheetState();
}

class _EditingSheetState extends State<_EditingSheet> {
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
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '编辑待办',
                                style: context.theme.typography.base,
                              ),
                              const SizedBox(
                                height: 24.0,
                              ),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      24.0, 0.0, 24.0, 0.0),
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
                            ]),
                      ),
                    )),
              );
            },
          );
        });
  }
}
