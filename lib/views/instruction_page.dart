import 'package:flutter/material.dart';
import 'package:miaomiaoswust/components/instruction/button_state.dart';
import 'package:miaomiaoswust/components/instruction/pages/duifene_login_page.dart';
import 'package:miaomiaoswust/components/instruction/pages/soa_login_page.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/views/main_page.dart';

import '../components/m_scaffold.dart';
import '../data/values.dart';
import '../utils/widget.dart';

class InstructionPage extends StatefulWidget {
  const InstructionPage({super.key});

  @override
  State<StatefulWidget> createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  ButtonStateContainer _sc =
      const ButtonStateContainer(ButtonState.dissatisfied);
  int _currentPage = 0;
  static const _pages = 2;
  late PageController _pageController;

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

  @override
  Widget build(BuildContext context) {
    onStateChange(ButtonStateContainer sc) => setState(() => _sc = sc);
    onComplete() {
      if (_currentPage >= _pages - 1) {
        pushTo(context, const MainPage());
        return;
      }

      setState(() {
        _currentPage++;
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });
    }

    final pages = [
      SOALoginPage(
          sc: _sc, onStateChange: onStateChange, onComplete: onComplete),
      DuiFenELoginPage(
          sc: _sc, onStateChange: onStateChange, onComplete: onComplete)
    ];

    return Transform.flip(
        flipX: Values.isFlipEnabled.value,
        flipY: Values.isFlipEnabled.value,
        child: MScaffold(
            safeArea: false,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: joinPlaceholder(gap: 12, widgets: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '欢迎来到喵喵西科',
                          style: TextStyle(fontSize: 34),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          '一个易用、简单、舒适的西科大校园一站式服务平台',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return pages[index];
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                    ),
                  )
                ])).wrap(context: context)));
  }
}
