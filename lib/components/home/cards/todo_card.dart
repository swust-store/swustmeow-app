import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/open_animated_container.dart';
import 'package:miaomiaoswust/entity/todo.dart';
import 'package:miaomiaoswust/views/todo_page.dart';

import '../../../services/box_service.dart';
import '../../../utils/color.dart';

class TodoCard extends StatefulWidget {
  const TodoCard({super.key, required this.setNavbarOpacity});

  final Function(double) setNavbarOpacity;

  @override
  State<StatefulWidget> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  static const _translateYDefault = -84.0;
  bool _isExpanded = false;
  double _translateY = _translateYDefault;
  double? _cardWidth;
  Animation<double>? _animation;
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
      setState(() {
        _todos = cached.cast();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _todos = [];
      _isLoading = false;
    });
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

  void _toggleCard() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: _buildAnimatedContainer(),
    );
  }

  Widget _buildAnimatedContainer() {
    final size = MediaQuery.of(context).size;
    final collapsedHeight = size.height * 0.36;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: Transform(
                transform: Matrix4.translationValues(0, _translateY, 0),
                child: OpenAnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: const ElasticOutCurve(0.9),
                    width: _isExpanded
                        ? size.width
                        : (size.width -
                            context.theme.style.pagePadding.top * 6),
                    height: _isExpanded ? size.height : collapsedHeight,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: context.theme.colorScheme.border),
                      borderRadius: BorderRadius.all(
                        Radius.circular(_isExpanded ? 0 : 8),
                      ),
                    ),
                    onEnd: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() =>
                            _translateY = _isExpanded ? 0 : _translateYDefault);
                      });
                    },
                    onAnimation: (animation) {
                      if (animation.value <= 0.0 || animation.value >= 1.0) {
                        return;
                      }

                      widget.setNavbarOpacity(_isExpanded
                          ? (1 - animation.value)
                          : animation.value);

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _animation = animation;
                          if (_isExpanded) {
                            _translateY =
                                (1 - animation.value) * _translateYDefault;
                          } else {
                            _translateY = animation.value * _translateYDefault;
                          }
                        });
                      });
                    },
                    onSize: (size) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _cardWidth = size.width;
                        });
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(_isExpanded ? 0 : 8),
                      ),
                      child: Container(
                        color: _isExpanded
                            ? context.theme.colorScheme.background
                            : context.theme.colorScheme.primaryForeground,
                        child: TodoPage(
                            isExpanded: _isExpanded,
                            animation: _animation,
                            todos:
                                _isLoading ? _generateRandomTodos(5) : _todos,
                            isLoading: _isLoading),
                      ),
                    )),
              ),
            )
          ],
        ),
        Center(
          child: Transform(
            transform: Matrix4.translationValues(0, _isExpanded ? -335 : 55, 0),
            child: SizedBox(
              height: 50,
              width: _cardWidth ?? 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: (details) {
                  if (_isLoading) return;
                  if (details.primaryVelocity! < -100) {
                    if (!_isExpanded) _toggleCard();
                  } else if (details.primaryVelocity! > 100) {
                    if (_isExpanded) _toggleCard();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
