import 'dart:ui';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/components/instruction/button_state.dart';
import 'package:swustmeow/components/instruction/pages/login_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/main_page.dart';

import '../components/utils/back_again_blocker.dart';
import '../data/values.dart';
import '../services/global_service.dart';
import '../services/value_service.dart';
import '../utils/widget.dart';

class InstructionPage extends StatefulWidget {
  const InstructionPage({super.key, this.loadPage});

  final LoginPage Function({
    required ButtonStateContainer sc,
    required Function(ButtonStateContainer sc) onStateChange,
    required Function() onComplete,
    required bool onlyThis,
  })? loadPage;

  @override
  State<StatefulWidget> createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  ButtonStateContainer _sc =
      const ButtonStateContainer(ButtonState.dissatisfied);
  int _currentPage = 0;
  late PageController _pageController;
  List<Widget> _pageList = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // 如果没有单独指定页面，则为下面的列表长度，否则为一个
    final count = widget.loadPage == null ? GlobalService.services.length : 1;

    onStateChange(ButtonStateContainer sc) => _refresh(() => _sc = sc);
    onComplete() {
      if (_currentPage >= count - 1) {
        pushReplacement(context, const BackAgainBlocker(child: MainPage()));
        return;
      }

      _refresh(() {
        _currentPage++;
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });
    }

    var pages = GlobalService.services
        .map(
          (service) => service.getLoginPage(
              sc: _sc,
              onStateChange: onStateChange,
              onComplete: onComplete,
              onlyThis: widget.loadPage != null),
        )
        .toList();

    if (widget.loadPage != null) {
      pages = [
        widget.loadPage!(
            sc: _sc,
            onStateChange: onStateChange,
            onComplete: onComplete,
            onlyThis: true)
      ];
    }

    _pageList = pages;

    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      MTheme.primary2.withValues(alpha: 0.3),
                      MTheme.primary3.withValues(alpha: 0.2),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 40,
                    sigmaY: 40,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SafeArea(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(MTheme.radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: joinGap(
          gap: 12,
          axis: Axis.vertical,
          widgets: [
            _buildHeader(),
            Flexible(
              child: ExpandablePageView.builder(
                itemCount: _pageList.length,
                itemBuilder: (context, index) {
                  final page = _pageList[index];
                  return page;
                },
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello!',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: MTheme.primary1,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            '欢迎来到${Values.name}',
            style: TextStyle(
              fontSize: 20,
              color: MTheme.primary1,
            ),
          ),
        ],
      ),
    );
  }
}
