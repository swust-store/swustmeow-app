import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'horizontal_card_list.dart';

typedef PageChangedCallback = void Function(double page);
typedef PageSelectedCallback = void Function(int index);

class HorizontalCardPager extends StatefulWidget {
  const HorizontalCardPager(
      {super.key,
      required this.children,
      this.onPageChanged,
      this.initialPage = 0,
      this.onSelectedItem,
      this.onPress});

  final List<Widget> children;
  final PageChangedCallback? onPageChanged;
  final PageSelectedCallback? onSelectedItem;
  final int initialPage;
  final Function()? onPress;

  @override
  State<StatefulWidget> createState() => _HorizontalCardPagerState();
}

class _HorizontalCardPagerState extends State<HorizontalCardPager> {
  bool _isScrolling = false;
  double? _currentPosition;
  PageController? _controller;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPage.toDouble();
    _controller = PageController(initialPage: widget.initialPage);
    _controller!.addListener(() {
      _refresh(() {
        _currentPosition = _controller!.page;
        if (widget.onPageChanged != null) {
          Future(() => widget.onPageChanged!(_currentPosition!));
        }
      });
    });
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = MediaQuery.of(context).size;
      double viewWidth = size.width * 2;
      double viewHeight = viewWidth / 3;

      double cardMaxWidth = viewHeight;
      double cardMaxHeight = cardMaxWidth;

      return GestureDetector(
          onHorizontalDragEnd: (details) {
            _isScrolling = false;
          },
          onHorizontalDragStart: (details) {
            _isScrolling = true;
          },
          onTap: widget.onPress,
          onTapUp: (details) {
            if (_isScrolling == true) {
              return;
            }

            if ((_currentPosition! - _currentPosition!.floor()).abs() <= 0.15) {
              int selectedIndex = _onTapUp(
                  context, viewHeight, viewWidth, _currentPosition, details);

              if (selectedIndex == 2) {
                if (widget.onSelectedItem != null) {
                  Future(
                      () => widget.onSelectedItem!(_currentPosition!.round()));
                }
              } else if (selectedIndex >= 0) {
                int goToPage = _currentPosition!.toInt() + selectedIndex - 2;
                _controller!.animateToPage(goToPage,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              }
            }
          },
          child: HorizontalCardList(
            controller: _controller,
            viewWidth: viewWidth,
            selectedIndex: _currentPosition,
            cardMaxHeight: cardMaxHeight,
            cardMaxWidth: cardMaxWidth,
            getStartPosition: _getStartPosition,
            getCardSize: _getCardSize,
            children: widget.children,
          ));
    });
  }

  int _onTapUp(context, cardMaxWidth, viewWidth, currentPosition, details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    double dx = localOffset.dx;

    for (int i = 0; i < 5; i++) {
      double cardWidth = _getCardSize(cardMaxWidth, i, 2.0);
      double left =
          _getStartPosition(cardWidth, cardMaxWidth, viewWidth, i, 2.0);

      if (left <= dx && dx <= left + cardWidth) {
        return i;
      }
    }
    return -1;
  }

  double _getStartPosition(double cardWidth, double? cardMaxWidth,
      double viewWidth, int cardIndex, double selectedIndex) {
    double diff = (selectedIndex - cardIndex);
    double diffAbs = diff.abs();

    double basePosition = (viewWidth / 2) - (cardWidth * 0.5);

    if (diffAbs == 0) {
      return basePosition;
    }
    if (diffAbs > 0.0 && diffAbs <= 1.0) {
      if (diff >= 0) {
        return basePosition - (cardMaxWidth! * 1.0) * diffAbs;
      } else {
        return basePosition + (cardMaxWidth! * 1.0) * diffAbs;
      }
    } else if (diffAbs > 1.0 && diffAbs < 2.0) {
      if (diff >= 0) {
        return basePosition -
            (cardMaxWidth! * 1.0) -
            cardMaxWidth * 0.8 * (diffAbs - diffAbs.floor()).abs();
      } else {
        return basePosition +
            (cardMaxWidth! * 1.0) +
            cardMaxWidth * 0.8 * (diffAbs - diffAbs.floor()).abs();
      }
    } else {
      if (diff >= 0) {
        return basePosition - cardMaxWidth! * 2;
      } else {
        return basePosition + cardMaxWidth! * 2;
      }
    }
  }

  double _getCardSize(
      double? cardMaxWidth, int cardIndex, double selectedIndex) {
    double diff = (selectedIndex - cardIndex).abs();
    double ratio = 1 / 10;

    if (diff >= 0.0 && diff < 1.0) {
      return cardMaxWidth! - cardMaxWidth * ratio * ((diff - diff.floor()));
    } else if (diff >= 1.0 && diff < 2.0) {
      return cardMaxWidth! -
          cardMaxWidth * ratio -
          10 * ((diff - diff.floor()));
    } else if (diff >= 2.0 && diff < 3.0) {
      final size = cardMaxWidth! -
          cardMaxWidth * ratio -
          10 -
          5 * ((diff - diff.floor()));
      return size > 0 ? size : 0;
    } else {
      final size = cardMaxWidth! - cardMaxWidth * ratio - 15;
      return size > 0 ? size : 0;
    }
  }
}
