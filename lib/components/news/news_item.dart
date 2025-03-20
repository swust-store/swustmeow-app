import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/simple_webview_page.dart';

class NewsItem extends StatelessWidget {
  final Map<dynamic, dynamic> news;
  final bool modern;
  final bool pushInto;

  const NewsItem({
    super.key,
    required this.news,
    this.modern = false,
    this.pushInto = true,
  });

  @override
  Widget build(BuildContext context) {
    final title = news['title'] as String;
    final link = news['link'] as String;
    final category = news['category'] as String? ?? '校园新闻';
    final tags = news['tags'] != null
        ? (news['tags'] as List<dynamic>).cast<String>()
        : <String>[];
    final time = news['time'] as String? ?? '';

    return FTappable(
      onPress: () async => await _launch(context, url: link, title: title),
      child: modern
          ? _buildModernLayout(title, category, time, tags)
          : _buildClassicLayout(title, category, time, tags),
    );
  }

  Widget _buildClassicLayout(
      String title, String category, String time, List<String> tags) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MTheme.radius),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: MTheme.primary1.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          MTheme.primary1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          Colors.black45,
                    ),
                  ),
                ],
                const Spacer(),
                if (tags.isNotEmpty)
                  ...tags.take(2).map(
                        (tag) => Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLayout(
      String title, String category, String time, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: MTheme.primary1.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          color: MTheme.primary1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    if (tags.isNotEmpty)
                      ...tags.take(1).map((tag) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(BuildContext context,
      {required String url, required String title}) async {
    final page = SimpleWebViewPage(initialUrl: url, title: title);
    pushTo(context, '/news-$url-$title', page, pushInto: pushInto);
  }
}
