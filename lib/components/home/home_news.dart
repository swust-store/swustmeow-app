import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/empty.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/simple_webview_page.dart';

class HomeNews extends StatefulWidget {
  const HomeNews({super.key});

  @override
  State<StatefulWidget> createState() => _HomeNewsState();
}

class _HomeNewsState extends State<HomeNews> {
  List<Map<String, dynamic>> _headings = [];
  List<Map<String, dynamic>> _commons = [];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
    final info = GlobalService.serverInfo;
    if (info == null) return;

    final news = info.news;
    List<Map<String, dynamic>> heading =
        (news['heading'] as List<dynamic>).cast();
    List<Map<String, dynamic>> common =
        (news['common'] as List<dynamic>).cast();
    _headings = heading;
    _commons = common;
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Transform.translate(
              offset: Offset(0, 2),
              child: FaIcon(
                FontAwesomeIcons.newspaper,
                color: MTheme.primary1,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '校园资讯',
              style: TextStyle(
                fontSize: 16,
                color: MTheme.primary1,
              ),
            )
          ],
        ),
        SizedBox(height: 8),
        _buildHeading(),
        _buildCommonList(),
      ],
    );
  }

  Widget _buildHeading() {
    if (_headings.length < 2) return const Empty();
    return Row(
      children: [
        Expanded(child: _buildHeadingCard(_headings.first)),
        SizedBox(width: 16),
        Expanded(child: _buildHeadingCard(_headings.last)),
      ],
    );
  }

  Widget _buildHeadingCard(Map<String, dynamic> data) {
    final title = data['title']!;
    final link = data['link']!;
    final image = data['image']!;
    final size = MediaQuery.of(context).size;
    final width = size.width / 2 - (2 * 16);
    final height = width / 2;
    return FTappable(
      onPress: () async => await _launch(url: link, title: title),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(MTheme.radius),
            child: SizedBox(
              width: width,
              height: height,
              child: Image.network(
                image,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.8),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommonList() {
    return Column(
      children: [],
    );
  }

  Future<void> _launch({required String url, required String title}) async {
    // final result = await launchLink(url);
    // if (!result) {
    //   if (!mounted) return;
    //   showErrorToast(context, '无法启动相关应用');
    // }
    final page = SimpleWebViewPage(initialUrl: url, title: title);
    pushTo(context, page, pushInto: true);
    setState(() {});
  }
}
