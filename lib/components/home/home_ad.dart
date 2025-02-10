import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeAd extends StatefulWidget {
  const HomeAd({super.key});

  @override
  State<StatefulWidget> createState() => _HomeAdState();
}

class _HomeAdState extends State<HomeAd> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  DateTime _lastInteraction = DateTime.now();
  List<Map<String, String>> _ads = [];

  @override
  void initState() {
    super.initState();
    _ads = GlobalService.serverInfo?.ads ?? [];
    _pageController = PageController(initialPage: 0);
    _startTimer();
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
        height: 100,
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, index) {
            final adjustedIndex = index % _ads.length;
            final data = _ads[adjustedIndex];
            final url = data['url'] as String;
            final href = data['href'] as String;
            final uri = Uri.parse(href);

            launch() async {
              final result = await launchUrl(uri);
              if (!result && context.mounted) {
                showErrorToast(context, '无法拉起手机版 QQ');
              }
            }

            return Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
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
                  ),
                );
              },
              errorBuilder: (context, child, err) {
                return Container(
                  color: Colors.grey,
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
                          style: TextStyle(color: Colors.red),
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
        ),
      ),
    );
  }
}
