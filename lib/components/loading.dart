import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatefulWidget {
  const Loading({super.key, this.child});

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
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          margin: const EdgeInsets.all(100),
          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
          // 平衡视觉
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              // Image(
              //   image: Values.catLoadingGif,
              //   height: 80,
              //   width: 80,
              // ),
              Center(
                child: LoadingAnimationWidget.flickr(
                    size: 32,
                    leftDotColor: Colors.red,
                    rightDotColor: Colors.blue),
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
