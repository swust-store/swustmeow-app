import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';

class HomeAd extends StatefulWidget {
  const HomeAd({super.key, required this.ads});

  final List<Map<String, String>> ads;

  @override
  State<StatefulWidget> createState() => _HomeAdState();
}

class _HomeAdState extends State<HomeAd> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  DateTime _lastInteraction = DateTime.now();
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _width = GlobalService.size!.width - (2 * 24);
    _height = _width / 3;

    _pageController = PageController(initialPage: 0);
    if (widget.ads.length > 1) _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final timeSinceLastInteraction =
          now.difference(_lastInteraction).inSeconds;

      if (timeSinceLastInteraction >= 15 ||
          (timeSinceLastInteraction >= 10 &&
              _currentPage != _pageController.page?.round())) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
        _lastInteraction = now;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (_) => _lastInteraction = DateTime.now(),
      child: SizedBox(
        width: _width,
        height: _height,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(MTheme.radius),
              child: _buildImagePages(),
            ),
            if (widget.ads.length > 1)
              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: widget.ads.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: MTheme.primary2,
                      dotColor: Colors.black.withValues(alpha: 0.5),
                      dotHeight: 6,
                      dotWidth: 6,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePages() {
    return PageView.builder(
      controller: _pageController,
      physics: widget.ads.length > 1
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final adjustedIndex = index % widget.ads.length;
        final data = widget.ads[adjustedIndex];
        final url = data['url'] as String;
        final href = data['href'] as String;
        final iosHref = data['iosHref'];

        launch() async {
          bool result;
          if (Platform.isIOS && iosHref != null) {
            result = await launchLink(iosHref);
          } else {
            result = await launchLink(href);
          }
          if (!result) {
            showErrorToast('无法启动相关应用');
          }
        }

        return Image.network(
          url,
          fit: BoxFit.cover,
          color: MTheme.primary3,
          colorBlendMode: BlendMode.color,
          width: _width,
          height: _height,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return FTappable(
                onPress: launch,
                child: child,
              );
            }

            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: MTheme.primary2,
              ),
            );
          },
          errorBuilder: (context, child, err) {
            return Container(
              color: Colors.grey.withValues(alpha: 0.2),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.circleExclamation,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '图片被猫猫啃掉了~',
                      style:
                          TextStyle(color: Colors.red.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
      },
    );
  }
}
