import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/home/todo_row.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/entity/todo.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TodoPage extends StatefulWidget {
  const TodoPage(
      {super.key,
      required this.isExpanded,
      required this.animation,
      required this.todos,
      required this.isLoading});

  final bool isExpanded;
  final Animation<double>? animation;
  final List<Todo> todos;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  Widget build(BuildContext context) {
    final v = widget.animation?.value ?? 1;
    final safeHeightRatio = widget.isExpanded ? v : 1 - v;
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
                            '待办',
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
                    enabled: widget.isLoading,
                    child: SingleChildScrollView(
                      child: Column(
                        children: joinPlaceholder(
                            gap: 8.0,
                            widgets: widget.todos
                                .map((todo) => TodoRow(todo: todo))
                                .toList()),
                      ),
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
