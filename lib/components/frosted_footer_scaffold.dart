import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// 修改自 [FScaffold]
class FrostedFooterScaffold extends StatelessWidget {
  final Widget content;
  final Widget? header;
  final Widget? footer;
  final bool contentPad;
  final FScaffoldStyle? style;

  const FrostedFooterScaffold({
    required this.content,
    this.header,
    this.footer,
    this.contentPad = true,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.scaffoldStyle;
    Widget content = this.content;

    if (contentPad) {
      content = Padding(padding: style.contentPadding, child: content);
    }

    return ColoredBox(
      color: style.backgroundColor,
      child: Column(
        children: [
          if (header != null)
            DecoratedBox(decoration: style.headerDecoration, child: header!),
          Expanded(
              child: Stack(
            children: [
              content,
              if (footer != null)
                Align(
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: style.footerDecoration,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Opacity(
                            opacity: 0.75,
                            child: footer!,
                          ),
                        ),
                      ),
                    )),
            ],
          )),
        ],
      ),
    );
  }
}
