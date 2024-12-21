import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/home/todo_row.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/entity/todo.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/utils/color.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TodoPage extends StatefulWidget {
  const TodoPage(
      {super.key, required this.isExpanded, required this.animation});

  final bool isExpanded;
  final Animation<double>? animation;

  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    List<dynamic>? cached = BoxService.todoListBox.get('todos');
    if (cached != null) {
      setState(() => _todos = cached.cast());
      return;
    }
  }

  List<Todo> _generateRandomTodos(int count) {
    final random = Random();
    return List.generate(count, (index) {
      String title = '*' * (random.nextInt(10) + 5);
      return Todo(
        title: title,
        color: Color(randomColor()).withOpacity(0.8).value,
        isFinished: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.animation?.value ?? 0;
    final safeHeightRatio = 1 - (widget.isExpanded ? 1 - v : v);
    return Column(
      children: [
        // 约等于 SafeArea，但高度可控
        SizedBox(height: 40 * safeHeightRatio.abs()),
        Stack(
          children: [
            PaddingContainer(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FIcon(
                      FAssets.icons.listTodo,
                      size: 24,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Transform(
                      transform: Matrix4.translationValues(0, -2, 0),
                      child: const Row(
                        children: [
                          Text(
                            '代办',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Skeletonizer(
                    enabled: _isLoading,
                    child: Column(
                      children: joinPlaceholder(
                          gap: 8.0,
                          widgets: (_todos.isNotEmpty
                                  ? _todos
                                  : _generateRandomTodos(5))
                              .map((todo) => TodoRow(todo: todo))
                              .toList()),
                    ))
              ],
            )),
            Align(
              alignment: Alignment.topCenter, // 居中对齐顶部
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Transform(
                  transform: Matrix4.translationValues(0, 4, 0),
                  child: Container(
                    width: 60, // 宽度
                    height: 4, // 高度
                    decoration: BoxDecoration(
                      color: Colors.grey[400], // 颜色
                      borderRadius: BorderRadius.circular(3), // 圆角
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
