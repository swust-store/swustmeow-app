import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/core/values.dart';

class Loading extends StatefulWidget {
  const Loading({this.child, super.key});

  final Widget? child;

  @override
  State<StatefulWidget> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: AlignmentDirectional.center,
        decoration: const BoxDecoration(color: Colors.black54),
        child: Container(
          decoration: BoxDecoration(
              color: context.theme.colorScheme.primaryForeground,
              borderRadius: const BorderRadius.all(Radius.circular(14))),
          margin: const EdgeInsets.all(120),
          padding: const EdgeInsets.fromLTRB(36, 30, 30, 30), // 平衡视觉
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              Image(
                image: Values.catLoadingGif,
              ),
              if (widget.child != null)
                Placeholder(
                  fallbackHeight: 12,
                  color: context.theme.colorScheme.primaryForeground,
                ),
              if (widget.child != null) widget.child!
            ],
          ),
        ));
  }
}
