import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/open_animated_container.dart';
import 'package:miaomiaoswust/views/todo_page.dart';

class TodoCard extends StatefulWidget {
  const TodoCard({super.key, required this.setNavbarOpacity});

  final Function(double) setNavbarOpacity;

  @override
  State<StatefulWidget> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  static const _translateYDefault = 176.0;
  bool _isExpanded = false;
  double _translateY = _translateYDefault;
  Animation<double>? _animation;

  void _toggleCard() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < -100) {
            if (!_isExpanded) _toggleCard();
          } else if (details.primaryVelocity! > 100) {
            if (_isExpanded) _toggleCard();
          }
        },
        child: _buildAnimatedContainer(),
      ),
    );
  }

  Widget _buildAnimatedContainer() {
    final size = MediaQuery.of(context).size;
    final collapsedHeight = size.height * 0.36;

    return Transform(
        transform: Matrix4.translationValues(0, _translateY, 0),
        child: OpenAnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            curve: const ElasticOutCurve(0.9),
            width: _isExpanded
                ? size.width
                : (size.width - context.theme.style.pagePadding.top * 6),
            height: _isExpanded ? size.height : collapsedHeight,
            decoration: BoxDecoration(
              border: Border.all(color: context.theme.colorScheme.border),
              borderRadius: BorderRadius.all(
                Radius.circular(_isExpanded ? 0 : 8),
              ),
            ),
            onEnd: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(
                    () => _translateY = _isExpanded ? 0 : _translateYDefault);
              });
            },
            onAnimation: (animation) {
              if (animation.value <= 0.0 || animation.value >= 1.0) {
                return;
              }

              widget.setNavbarOpacity(
                  _isExpanded ? (1 - animation.value) : animation.value);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _animation = animation;
                  if (_isExpanded) {
                    _translateY = (1 - animation.value) * _translateYDefault;
                  } else {
                    _translateY = animation.value * _translateYDefault;
                  }
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
                child: TodoPage(isExpanded: _isExpanded, animation: _animation),
              ),
            )));
  }
}
