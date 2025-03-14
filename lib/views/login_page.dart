import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/entity/button_state.dart';
import 'package:swustmeow/components/login_pages/login_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/views/main_page.dart';

import '../components/utils/back_again_blocker.dart';
import '../data/values.dart';
import '../entity/account.dart';
import '../services/boxes/course_box.dart';
import '../services/boxes/soa_box.dart';
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
  bool _isReviewMode = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _loadReviewMode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReviewMode() async {
    final r = GlobalService.reviewAuthResult;
    if (r == null) return;

    if (r.status == Status.ok) {
      setState(() {
        _isReviewMode = true;
      });
    } else if (r.status != Status.notAuthorized) {
      showErrorToast(r.value ?? '未知错误');
    }
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
                width: 400,
                height: 450,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage('assets/images/gradient_circle.jpg'),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildContent(),
                  _buildFooter(),
                ],
              ),
            ),
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
            if (_isReviewMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: FButton(
                        onPress: () async {
                          await _loginGuest();

                          if (!mounted) return;
                          pushReplacement(context,
                              const BackAgainBlocker(child: MainPage()));
                        },
                        label: const Text('游客模式'),
                        style: FButtonStyle.secondary,
                      ),
                    ),
                  ],
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

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: RichText(
        text: TextSpan(
          text: '登录遇到问题？',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: '点击进入官方 QQ 群反馈',
              style: TextStyle(color: MTheme.primary2),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final flag = await launchLink(Values.qunUrl);
                  if (!flag) {
                    showErrorToast('无法跳转到网页');
                  }
                },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginGuest() async {
    final map = GlobalService.reviewAuthResult!.value!;
    final tgc = map['tgc'] as String;
    final userId = map['user_id'] as String;

    GlobalService.soaService?.isLoginNotifier.value = true;
    await SOABox.put('isLogin', true);
    await SOABox.put('tgc', tgc);
    await SOABox.put('username', userId);
    await SOABox.put('remember', false);
    await SOABox.put('isGuest', true);

    final account = Account(account: userId, password: '', isGuest: true);
    await SOABox.put('account', account);

    await SOABox.clearCache();
    await CourseBox.clearCache();
  }
}
