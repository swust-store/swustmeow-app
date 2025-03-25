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
    return BasePage(
      headerPad: false,
      header: BaseHeader(title: '关于'.meow),
      content: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildAppHeader(),
            _buildInfoSections(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handleLogoTap,
            child: Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 70,
                height: 70,
                child: Image.asset('assets/icon/icon.png'),
              )
                  .animate(
                      controller: _logoAnimationController,
                      onPlay: (controller) => controller.stop())
                  .shake(duration: 500.ms),
            ),
          ),
          Text(
            Values.name.meow,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: _isEasterEggActive ? MTheme.primary2 : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MTheme.primary2.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'v${Values.version}-${Values.buildVersion}'.meow,
              style: TextStyle(
                color: MTheme.primary2.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSections() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _buildInfoSection('关于应用'.meow, Values.instruction.meow),
          _buildInfoSection('广告位招租'.meow, Values.adInstruction.meow),
          _buildInfoSection('联系我们'.meow, '易通西科喵官方 QQ 交流群：1030083864'.meow),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: MTheme.primary2,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final color = Colors.black54;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            '版权所有 © 2025 s-meow.com'.meow,
            style: TextStyle(color: color, fontSize: 13),
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: '《用户协议》'.meow,
              style: TextStyle(
                color: MTheme.primary2,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  pushTo(context, '/agreements/tos', TOSPage());
                  setState(() {});
                },
              children: [
                TextSpan(
                    text: ' 与 '.meow, style: TextStyle(color: color)),
                TextSpan(
                  text: '《隐私政策》'.meow,
                  style: TextStyle(
                    color: MTheme.primary2,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
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
          SizedBox(height: 8),
          Text(
            '蜀ICP备2025129853号-3A'.meow,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _handleLogoTap() {
    setState(() {
      _logoTapCount++;
      if (_logoTapCount >= 10 && !_isEasterEggActive) {
        _isEasterEggActive = true;
        _logoAnimationController.forward();
        ValueService.isMeowEnabled.value = true;
        showInfoToast('喵' * 30, seconds: 5);
      }
    });
  }
}
