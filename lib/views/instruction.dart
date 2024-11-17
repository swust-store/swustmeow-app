import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/empty.dart';
import 'package:miaomiaoswust/constants.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/m_scaffold.dart';
import '../components/padding_container.dart';
import '../components/stroked_gradient_text.dart';
import '../components/text_placeholder.dart';
import '../utils/color.dart';
import 'loginpage.dart';

class Instruction extends StatefulWidget {
  const Instruction({super.key});

  @override
  State<StatefulWidget> createState() => _InstructionState();
}

class _InstructionState extends State<Instruction> {
  @override
  Widget build(BuildContext context) {
    return MScaffold(
      PaddingContainer(
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              const TextPlaceholder(1),
              Text(Constants(context).instruction,
                  style: const TextStyle(fontSize: 14)),
              const TextPlaceholder(1),
              FButton(
                  onPress: () =>
                      setState(() => pushTo(context, const LoginPage())),
                  label: const Text('开始西科之旅 -->')
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                          duration: 1.5.seconds,
                          delay: 0.5.seconds,
                          color: Colors.grey))
            ]),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/instruction1.jpg'),
                fit: BoxFit.cover)),
      ).animate().fadeIn(duration: 1.5.seconds, curve: Curves.easeOutQuad),
      safeArea: false,
    );
  }
}
