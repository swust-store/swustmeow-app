import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/entity/todo.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/views/todo_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../data/values.dart';

class TodoCard extends StatefulWidget {
  const TodoCard({super.key, required this.cardStyle});

  final FCardStyle cardStyle;

  @override
  State<StatefulWidget> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    final cached = _getCachedTodoList();
    if (cached != null) {
      setState(() {
        _todos = cached;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _todos = [];
      _isLoading = false;
    });
  }

  List<Todo>? _getCachedTodoList() {
    List<dynamic>? result = BoxService.todoListBox.get('todoList');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  @override
  Widget build(BuildContext context) {
    final unfinished =
        _todos.where((todo) => !todo.isFinished).toList().toList();

    return Clickable(
        onClick: () {
          if (!_isLoading) {
            pushTo(context, TodoPage(todos: _todos));
            setState(() {});
          }
        },
        child: FCard(
          style: widget.cardStyle,
          image: Row(
            children: [
              FIcon(FAssets.icons.listTodo),
              const SizedBox(
                width: 10,
              ),
              const Text('待办')
            ],
          ),
          child: Skeletonizer(
            enabled: _isLoading,
            effect: Values.skeletonizerEffect,
            child: unfinished.isEmpty
                ? const SizedBox(
                    height: 126,
                    child: Center(
                      child: Text(
                        '~这里什么都木有~\n   点击以查看详情',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount:
                            unfinished.length <= 3 ? unfinished.length : 3,
                        itemBuilder: (context, index) {
                          final todo = unfinished[index];
                          final isEmpty = todo.isNew || todo.content.isEmpty;

                          const textStyle = TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          );

                          return Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                            child: RichText(
                              text: TextSpan(
                                  text: '⬤ ',
                                  style: textStyle,
                                  children: [
                                    TextSpan(
                                        text: isEmpty
                                            ? '(空待办)'
                                            : todo.content
                                                .replaceAll('\n', ' '),
                                        style: textStyle.copyWith(
                                            color: context
                                                .theme.colorScheme.primary
                                                .withValues(
                                                    alpha: isEmpty ? 0.6 : 1)))
                                  ]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(
                          height: 8.0,
                        ),
                      ),
                      if (unfinished.length > 3)
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                          child: Text(
                            '...等${unfinished.length}个待办${'!' * (unfinished.length / 5).floor()}',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.theme.cardStyle.contentStyle
                                    .subtitleTextStyle.color),
                          ),
                        )
                    ],
                  ),
          ),
        ));
  }
}
