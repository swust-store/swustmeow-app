import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/text.dart';

import '../../data/m_theme.dart';
import '../../data/values.dart';
import '../../services/value_service.dart';
import '../../utils/router.dart';
import '../../utils/widget.dart';
import '../agreements/privacy_page.dart';
import '../agreements/tos_Page.dart';

class SettingsAboutDetailsPage extends StatefulWidget {
  const SettingsAboutDetailsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsAboutDetailsPageState();
}

class _SettingsAboutDetailsPageState extends State<SettingsAboutDetailsPage>
    with SingleTickerProviderStateMixin {
  int _logoTapCount = 0;
  bool _isEasterEggActive = false;
  late AnimationController _logoAnimationController;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final components = _getComponents();

    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '关于'.meow,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(MTheme.radius),
                    child: Column(children: components),
                  ),
                ),
              ),
              _getFooter(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getComponents() {
    final titleStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );
    final contentStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
    return joinGap(
      gap: 60,
      axis: Axis.vertical,
      widgets: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: joinGap(
            gap: 8,
            axis: Axis.vertical,
            widgets: [
              Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _logoTapCount++;
                          if (_logoTapCount >= 10 && !_isEasterEggActive) {
                            _isEasterEggActive = true;
                            _logoAnimationController.forward();
                            ValueService.isMeowEnabled.value = true;
                            showInfoToast(context, '喵' * 30, seconds: 10);
                          }
                        });
                      },
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.asset('assets/icon/icon.png'),
                      )
                          .animate(
                              controller: _logoAnimationController,
                              onPlay: (controller) => controller.stop())
                          .shake(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    Values.name.meow,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color:
                          _isEasterEggActive ? MTheme.primary2 : Colors.black,
                    ),
                  ),
                  Text(
                    '版本：v${Values.version}'.meow,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontSize: 14),
                  )
                ],
              ),
              Text('关于应用'.meow, style: titleStyle),
              Text(Values.instruction.meow, style: contentStyle),
              Text('广告位招租'.meow, style: titleStyle),
              Text(Values.adInstruction.meow, style: contentStyle),
              Text('联系我们'.meow, style: titleStyle),
              Text('西科喵官方 QQ 交流群：1030083864'.meow, style: contentStyle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getFooter() {
    return Column(
      children: joinGap(
        gap: 4,
        axis: Axis.vertical,
        widgets: [
          Text(
            '版权所有 © 2025 swust.store'.meow,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          RichText(
            text: TextSpan(
              text: '《用户协议》'.meow,
              style: TextStyle(
                color: MTheme.primary2,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  pushTo(context, TOSPage());
                  setState(() {});
                },
              children: [
                TextSpan(text: '与'.meow, style: TextStyle(color: Colors.grey)),
                TextSpan(
                  text: '《隐私政策》'.meow,
                  style: TextStyle(color: MTheme.primary2),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      pushTo(context, PrivacyPage());
                      setState(() {});
                    },
                ),
              ],
            ),
          ),
          Text(
            'by FoliageOwO'.meow,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
