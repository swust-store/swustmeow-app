import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/components/utils/empty.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/components/news/news_item.dart';

import '../../services/value_service.dart';

class NewsListPage extends StatefulWidget {
  final List<Map<String, dynamic>> commonNews;

  const NewsListPage({
    super.key,
    required this.commonNews,
  });

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _commons = [];

  @override
  void initState() {
    super.initState();
    _commons = widget.commonNews;
  }

  Future<void> _loadAllNews() async {
    final info = GlobalService.serverInfo;
    if (info == null) {
      showErrorToast('获取服务器信息失败');
      setState(() => _isLoading = false);
      return;
    }

    final news = info.news;
    List<Map<String, dynamic>> common =
        (news['common'] as List<dynamic>).cast();

    setState(() {
      _commons = common;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '校园资讯',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          suffixIcons: [
            IconButton(
              onPressed: () async {
                if (_isLoading) return;
                setState(() => _isLoading = true);
                await _loadAllNews();
              },
              icon: FaIcon(
                FontAwesomeIcons.rotateRight,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        content: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: MTheme.primary2),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildCommonSection(),
                ),
              ),
      ),
    );
  }

  Widget _buildCommonSection() {
    if (_commons.isEmpty) return const Empty();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 8),
      itemCount: _commons.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        return NewsItem(
          news: _commons[index],
          modern: true,
          pushInto: false,
        );
      },
    );
  }
}
