import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/news/news_item.dart';
import 'package:swustmeow/components/utils/empty.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/simple_webview_page.dart';

import '../../views/news/news_list_page.dart';

class HomeNews extends StatefulWidget {
  const HomeNews({super.key});

  @override
  State<StatefulWidget> createState() => _HomeNewsState();
}

class _HomeNewsState extends State<HomeNews> {
  List<Map<dynamic, dynamic>> _headings = [];
  List<Map<dynamic, dynamic>> _commons = [];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
    final info = GlobalService.serverInfo;
    if (info == null) return;

    final news = info.news;
    List<dynamic> heading = (news['heading'] as List<dynamic>).cast();
    List<dynamic> common = (news['common'] as List<dynamic>).cast();
    _headings = heading.cast();
    _commons = common.cast();
  }

  @override
  Widget build(BuildContext context) {
    final color = MTheme.primary1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Transform.translate(
              offset: const Offset(0, 2),
              child: FaIcon(
                FontAwesomeIcons.newspaper,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '校园资讯',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            FTappable(
              onPress: () {
                pushTo(
                  context,
                  '/news_list',
                  NewsListPage(
                    commonNews: _commons,
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    '查看更多',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: color,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildHeading(),
        const SizedBox(height: 16),
        _buildCommonList(),
      ],
    );
  }

  Widget _buildHeading() {
    if (_headings.isEmpty) return const Empty();

    final displayHeadings =
        _headings.length >= 2 ? [_headings[0], _headings[1]] : _headings;

    return Row(
      children: displayHeadings
          .map((data) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildHeadingCard(data),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildHeadingCard(Map<dynamic, dynamic> data) {
    final title = data['title']!;
    final link = data['link']!;
    final image = data['image']!;
    final size = MediaQuery.of(context).size;
    final width = (size.width - 48) / 2;
    final height = width * 0.6;

    return FTappable(
      onPress: () async => await _launch(url: link, title: title),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MTheme.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MTheme.radius),
          child: Stack(
            children: [
              SizedBox(
                width: width,
                height: height,
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: width,
                      height: height,
                      color: Colors.grey.withValues(alpha: 0.2),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: width,
                      height: height,
                      color: Colors.grey.withValues(alpha: 0.1),
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommonList() {
    if (_commons.isEmpty) return const Empty();

    return Column(
      children: _commons
          .take(5)
          .map(
            (news) => Row(
              children: [Expanded(child: NewsItem(news: news))],
            ),
          )
          .toList(),
    );
  }

  Future<void> _launch({required String url, required String title}) async {
    final page = SimpleWebViewPage(initialUrl: url, title: title);
    pushTo(context, '/news-$url-$title', page, pushInto: true);
    setState(() {});
  }
}
