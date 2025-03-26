import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/qun/qun_add_sheet.dart';
import 'package:swustmeow/components/qun/qun_card.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';
import 'dart:async';

class QunResourcePage extends StatefulWidget {
  const QunResourcePage({super.key});

  @override
  State<StatefulWidget> createState() => _QunResourcePageState();
}

class _QunResourcePageState extends State<QunResourcePage> {
  List<Map<String, dynamic>> _qun = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredQun = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterQun);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQunData();
    });
  }

  Future<void> _loadQunData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    await Future.delayed(Duration(milliseconds: 200));

    final qunData = await Future.microtask(() {
      return GlobalService.serverInfo?.qun ?? [];
    });

    if (mounted) {
      setState(() {
        _qun = qunData.cast();
        _filteredQun = qunData.cast();
        _isLoading = false;
      });
    }
  }

  final _debouncer = Debouncer(milliseconds: 300);

  void _filterQun() {
    final query = _searchController.text.toLowerCase();
    _debouncer.run(() {
      if (!mounted) return;
      setState(() {
        if (query.isEmpty) {
          _filteredQun = _qun;
        } else {
          _filteredQun = _qun.where((qun) {
            return qun['name']!.toLowerCase().contains(query) ||
                qun['qid']!.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSubmitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => const QunAddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(title: '群聊导航'),
      content: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '加载群聊信息中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          _buildContent(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FloatingActionButton(
                onPressed: _showSubmitDialog,
                backgroundColor: MTheme.primary2,
                child: FIcon(
                  FAssets.icons.plus,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_qun.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.userGroup,
              size: 60,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            SizedBox(height: 16),
            Text(
              '暂无群聊信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                '群聊列表正在加载中，请稍后再试',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showSubmitDialog,
              icon: FaIcon(FontAwesomeIcons.plus, size: 16),
              label: Text('提交新群聊'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MTheme.primary2,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 搜索框
        Padding(
          padding: EdgeInsets.fromLTRB(
              MTheme.radius, MTheme.radius, MTheme.radius, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(MTheme.radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索群聊...',
                  prefixIcon: Icon(Icons.search, color: MTheme.primary2),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
        ),

        // 群聊列表
        Expanded(
          child: _filteredQun.isEmpty
              ? _buildEmptySearchResult()
              : ListView.separated(
                  padding: EdgeInsets.only(
                    left: MTheme.radius,
                    right: MTheme.radius,
                    bottom: 80,
                  ),
                  itemCount: _filteredQun.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final qun = _filteredQun[index];
                    return QunCard(
                      name: qun['name']!,
                      qid: qun['qid']!,
                      link: qun['link']!,
                      iosLink: qun['ios_link'],
                      description: qun['description'],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptySearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 40,
            color: Colors.black.withValues(alpha: 0.7),
          ),
          SizedBox(height: 16),
          Text(
            '没有找到相关群聊',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '请尝试其他关键词',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '或点击右下角来提交新群聊',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
