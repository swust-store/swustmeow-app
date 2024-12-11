import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';

import '../components/m_scaffold.dart';
import '../components/padding_container.dart';
import '../components/stroked_gradient_text.dart';
import '../data/values.dart';
import '../utils/color.dart';
import '../utils/router.dart';
import '../utils/widget.dart';
import 'main_page.dart';

class InstructionPage extends StatefulWidget {
  const InstructionPage({super.key});

  @override
  State<StatefulWidget> createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  @override
  Widget build(BuildContext context) {
    return MScaffold(
      safeArea: false,
      child: PaddingContainer(
        decoration: BoxDecoration(
            image:
                DecorationImage(image: Values.loginBgImage, fit: BoxFit.fill)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: joinPlaceholder(gap: 30, widgets: [
              StrokedGradientText(
                'Hello，\n欢迎来到喵喵西科',
                gradient: LinearGradient(colors: [
                  hexToColor('#FF3CAC'),
                  hexToColor('#784BA0'),
                  hexToColor('#2B86C5')
                ], transform: const GradientRotation(math.pi / 3)),
                strokeWidth: 1,
                style: const TextStyle(fontSize: 34),
              ),
              Text(Values.instruction, style: const TextStyle(fontSize: 14)),
              FButton(
                  onPress: () =>
                      setState(() => pushTo(context, const MainPage())),
                  label: const Text('开始西科之旅 -->')
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                          duration: 1.5.seconds,
                          delay: 0.5.seconds,
                          color: Colors.grey))
            ])).wrap(context: context),
      ),
    );
  }
}
