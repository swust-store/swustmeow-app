import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BaseHeader extends StatefulWidget {
  const BaseHeader({
    super.key,
    required this.title,
    this.suffixIcons,
    this.showBackButton = true,
  });

  final Widget title;
  final List<Widget>? suffixIcons;
  final bool showBackButton;

  @override
  State<StatefulWidget> createState() => _BaseHeaderState();
}

class _BaseHeaderState extends State<BaseHeader> {
  final _mainRowKey = GlobalKey();
  double? _mainRowHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _mainRowKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _mainRowHeight = renderBox.size.height;
        });
      }
    });

    return Stack(
      children: [
        Row(
          key: _mainRowKey,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.showBackButton
                ? IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: FaIcon(
                      FontAwesomeIcons.angleLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : IgnorePointer(
                    child: IconButton(
                      onPressed: () {},
                      icon: SizedBox(),
                    ),
                  ),
            Spacer(),
            Expanded(
              flex: 3,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                  child: widget.title,
                ),
              ),
            ),
            Spacer(),
            Expanded(child: SizedBox())
          ],
        ),
        AnimatedOpacity(
          opacity: _mainRowHeight == null ? 0 : 1,
          duration: Duration.zero,
          child: SizedBox(
            height: _mainRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: widget.suffixIcons ?? [],
            ),
          ),
        )
      ],
    );
  }
}
