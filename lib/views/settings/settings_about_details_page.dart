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
    _isEasterEggActive = ValueService.isMeowEnabled.value;
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
          padding: EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
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
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.black87,
    );
    final contentStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 15,
      height: 1.6,
      color: Colors.black54,
    );
    return joinGap(
      gap: 8,
      axis: Axis.vertical,
      widgets: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
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
                        showInfoToast('喵' * 30, seconds: 5);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withValues(alpha: 0.05),
                    ),
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
              ),
              SizedBox(height: 16),
              Text(
                Values.name.meow,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: _isEasterEggActive ? MTheme.primary2 : Colors.black87,
                ),
              ),
              Text(
                '版本：v${Values.version}-${Values.buildVersion}'.meow,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ..._buildInfoSections(titleStyle, contentStyle),
      ],
    );
  }

  List<Widget> _buildInfoSections(
      TextStyle titleStyle, TextStyle contentStyle) {
    return [
      _buildInfoSection(
          '关于应用'.meow, Values.instruction.meow, titleStyle, contentStyle),
      _buildInfoSection(
          '广告位招租'.meow, Values.adInstruction.meow, titleStyle, contentStyle),
      _buildInfoSection('联系我们'.meow, '西科喵官方 QQ 交流群：1030083864'.meow, titleStyle,
          contentStyle),
    ];
  }

  Widget _buildInfoSection(String title, String content, TextStyle titleStyle,
      TextStyle contentStyle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: MTheme.primary2.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              SizedBox(width: 12),
              Text(title, style: titleStyle),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 16, bottom: 24),
            child: Text(content, style: contentStyle),
          ),
        ],
      ),
    );
  }

  Widget _getFooter() {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        children: joinGap(
          gap: 8,
          axis: Axis.vertical,
          widgets: [
            Text(
              '版权所有 © 2025 s-meow.com'.meow,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            RichText(
              text: TextSpan(
                text: '《用户协议》'.meow,
                style: TextStyle(
                  color: MTheme.primary2,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    pushTo(context, '/agreements/tos', TOSPage());
                    setState(() {});
                  },
                children: [
                  TextSpan(
                      text: '与'.meow, style: TextStyle(color: Colors.grey)),
                  TextSpan(
                    text: '《隐私政策》'.meow,
                    style: TextStyle(
                      color: MTheme.primary2,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        pushTo(context, '/agreements/privacy', PrivacyPage());
                        setState(() {});
                      },
                  ),
                ],
              ),
            ),
            Text(
              '鄂ICP备2025092905号-6A'.meow,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
