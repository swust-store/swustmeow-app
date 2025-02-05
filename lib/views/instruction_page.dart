import 'package:flutter/material.dart';
import 'package:swustmeow/components/instruction/button_state.dart';
import 'package:swustmeow/components/instruction/pages/duifene_login_page.dart';
import 'package:swustmeow/components/instruction/pages/soa_login_page.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/main_page.dart';

import '../components/m_scaffold.dart';
import '../components/will_pop_scope_blocker.dart';
import '../data/values.dart';
import '../utils/widget.dart';

class InstructionPage extends StatefulWidget {
  const InstructionPage({super.key, this.page});

  final Type? page;

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

  @override
  Widget build(BuildContext context) {
    // 如果没有单独指定页面，则为下面的列表长度，否则为一个
    final count = widget.page == null ? 2 : 1;

    onStateChange(ButtonStateContainer sc) => setState(() => _sc = sc);
    onComplete() {
      if (_currentPage >= count - 1) {
        pushReplacement(context, const WillPopScopeBlocker(child: MainPage()));
        return;
      }

      setState(() {
        _currentPage++;
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });
    }

    var pages = <Widget>[
      SOALoginPage(
          sc: _sc,
          onStateChange: onStateChange,
          onComplete: onComplete,
          onlyThis: widget.page != null),
      DuiFenELoginPage(
          sc: _sc,
          onStateChange: onStateChange,
          onComplete: onComplete,
          onlyThis: widget.page != null)
    ];

    final pageMatched = pages.where((p) => p.runtimeType == widget.page);

    if (widget.page != null && pageMatched.isNotEmpty) {
      pages = [pageMatched.first];
    }

    _pageList = pages;

    return Transform.flip(
        flipX: Values.isFlipEnabled.value,
        flipY: Values.isFlipEnabled.value,
        child: MScaffold(
            safeArea: false,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: joinGap(gap: 12, axis: Axis.vertical, widgets: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '欢迎来到${Values.name}',
                          style: TextStyle(fontSize: 34),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          '一个为西科大学子服务的易用、简单、舒适的校园一站式工具软件',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: PageView.builder(
                      itemCount: _pageList.length,
                      itemBuilder: (context, index) {
                        return _pageList[index];
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                    ),
                  )
                ])).wrap(context: context)));
  }
}
