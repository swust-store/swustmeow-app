import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/data/tools.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/tool.dart';
import 'package:swustmeow/services/tool_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/views/simple_webview_page.dart';
import 'package:vibration/vibration.dart';
import '../utils/router.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key, required this.padding});

  final double padding;

  @override
  State<StatefulWidget> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  bool _isEditMode = false;
  List<Tool> _tools = [];
  List<String> _visibleToolIds = [];
  List<String> _recentToolIds = [];

  @override
  void initState() {
    super.initState();
    _tools = Tools.tools.value;
    _visibleToolIds =
        _tools.where((tool) => tool.isVisible).map((tool) => tool.id).toList();
    _loadRecentTools();
  }

  Future<void> _loadRecentTools() async {
    final recentIds = await ToolService.getRecentTools();
    setState(() {
      _recentToolIds = recentIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(
        title: '工具',
        suffixIcons: [
          if (_isEditMode)
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.rotateRight,
                color: MTheme.backgroundText,
              ),
              onPressed: () async {
                await ToolService.resetToDefault();
                setState(() {
                  _tools = Tools.tools.value;
                  _visibleToolIds = _tools
                      .where((tool) => tool.isVisible)
                      .map((tool) => tool.id)
                      .toList();
                });
                showSuccessToast('工具布局已重置');
              },
            ),
          IconButton(
            icon: FaIcon(
              _isEditMode ? FontAwesomeIcons.check : FontAwesomeIcons.pen,
              color: MTheme.backgroundText,
            ),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),
      content: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildGrid(),
          SizedBox(height: 24),
          _buildRecentUsed(),
          SizedBox(height: 24),
          if (!Values.showcaseMode) ...[
            _buildWebsites(),
            SizedBox(height: 48),
          ]
        ],
      ),
    );
  }

  Widget _buildGrid() {
    int columns = _visibleToolIds.length <= 6 ? 3 : 4;
    final tools = Tools.tools.value
        .where(
            (tool) => Values.showcaseMode ? !tool.hiddenInShowcaseMode : true)
        .toList();

    return Padding(
      padding: EdgeInsets.all(8),
      child: ReorderableGrid(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          final service =
              tool.serviceGetter != null ? tool.serviceGetter!() : null;
          final isLogin = service == null ? true : service.isLogin;
          final isVisible = _visibleToolIds.contains(tool.id);

          return Container(
            key: Key(tool.id),
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(MTheme.radius),
            ),
            child: ReorderableGridDelayedDragStartListener(
              index: index,
              child: Stack(
                children: [
                  Center(
                    child: FTappable(
                      onPress: () => _onToolPressed(tool),
                      child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: tool.color,
                              builder: (context, color, _) => FaIcon(
                                tool.icon,
                                color: isLogin
                                    ? color.withValues(alpha: 1)
                                    : Colors.grey.withValues(alpha: 0.4),
                                size: 26,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            AutoSizeText(
                              tool.name,
                              minFontSize: 6,
                              maxFontSize: 12,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isEditMode)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _toggleToolVisibility(tool.id),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isVisible
                                ? Colors.green.withValues(alpha: 0.9)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                          child: isVisible
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (int oldIndex, int newIndex) async {
          final widget = _tools.removeAt(oldIndex);
          _tools.insert(newIndex, widget);
          await ToolService.updateToolOrder(_tools);
          setState(() {});
        },
        onReorderStart: (_) async {
          if (await Vibration.hasVibrator()) {
            Vibration.vibrate(duration: 100, sharpness: 0.2);
          }
        },
        proxyDecorator: (child, index, animation) => AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue =
                Curves.easeInOut.transform(animation.value);
            final double elevation = lerpDouble(0, 6, animValue)!;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MTheme.radius),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: 0.12 + elevation * 0.04),
                    blurRadius: 3.0 + elevation * 1.5,
                    spreadRadius: -1.0 + elevation * 0.5,
                    offset: Offset(0, 1.0 + elevation * 0.5),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: child,
        ),
      ),
    );
  }

  Future<void> _toggleToolVisibility(String toolId) async {
    final isVisible = _visibleToolIds.contains(toolId);

    setState(() {
      if (isVisible) {
        _visibleToolIds.remove(toolId);
        ToolService.updateToolVisibility(toolId, false);
      } else {
        _visibleToolIds.add(toolId);
        ToolService.updateToolVisibility(toolId, true);
      }
    });
  }

  void _onToolPressed(Tool tool) async {
    final service = tool.serviceGetter != null ? tool.serviceGetter!() : null;
    final isLogin = service == null ? true : service.isLogin;

    if (_isEditMode) {
      _toggleToolVisibility(tool.id);
      return;
    }

    if (!isLogin) {
      showErrorToast('未登录${service.name}');
      return;
    }

    if (!mounted) return;
    pushTo(context, tool.path, tool.pageBuilder(), pushInto: true);

    await ToolService.recordToolUsage(tool.id);
    _loadRecentTools();
    setState(() {});
  }

  Widget _buildRecentUsed() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近使用',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MTheme.primaryText,
                ),
              ),
              if (_recentToolIds.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    await ToolService.clearRecentTools();
                    _loadRecentTools();
                  },
                  child: Text(
                    '清除记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: MTheme.primary2,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          _recentToolIds.isEmpty
              ? Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(MTheme.radius),
                  ),
                  child: Center(
                    child: Text(
                      '暂无使用记录',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              : SizedBox(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _recentToolIds.length > 4 ? 4 : _recentToolIds.length,
                      (index) {
                        final toolId = _recentToolIds[index];
                        final tool = _tools.firstWhere(
                          (t) => t.id == toolId,
                          orElse: () => _tools.first,
                        );

                        final service = tool.serviceGetter != null
                            ? tool.serviceGetter!()
                            : null;
                        final isLogin =
                            service == null ? true : service.isLogin;

                        return Container(
                          width: (MediaQuery.of(context).size.width - 60) / 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(MTheme.radius),
                          ),
                          child: FTappable(
                            onPress: () => _onToolPressed(tool),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: tool.color,
                                  builder: (context, color, _) => FaIcon(
                                    tool.icon,
                                    color: isLogin
                                        ? color.withValues(alpha: 1)
                                        : Colors.grey.withValues(alpha: 0.4),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(height: 4),
                                AutoSizeText(
                                  tool.name,
                                  minFontSize: 6,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWebsites() {
    final columns = 4;
    final websites = [
      _buildWebsiteItem(
        FontAwesomeIcons.school,
        '学校主页',
        'https://www.swust.edu.cn/',
        Colors.red,
      ),
      _buildWebsiteItem(
        FontAwesomeIcons.buildingColumns,
        '一站式大厅',
        'https://soa.swust.edu.cn/sys/portal/page.jsp',
        Colors.blue,
      ),
      _buildWebsiteItem(
        FontAwesomeIcons.userGraduate,
        '数字学工',
        'https://yzs.swust.edu.cn/xg/mobile',
        Colors.teal,
      ),
      _buildWebsiteItem(
        FontAwesomeIcons.calendarDay,
        '课表与选课',
        'https://matrix.dean.swust.edu.cn/acadmicManager/index.cfm?event=studentPortal:DEFAULT_EVENT',
        Colors.orange,
      ),
      _buildWebsiteItem(
        FontAwesomeIcons.flask,
        '实践教学',
        'https://sjjx.dean.swust.edu.cn/swust',
        Colors.indigo,
      ),
      _buildWebsiteItem(
        FontAwesomeIcons.bookOpen,
        '图书馆',
        'https://lib.swust.edu.cn/',
        Colors.green,
      ),
      _buildWebsiteItem(
        FontAwesomeIcons.bed,
        '公寓中心',
        'http://gydb.swust.edu.cn/sgH5/',
        Colors.brown,
      ),
      _buildWebsiteItem(
        FontAwesomeIcons.solidCreditCard,
        '一卡通',
        'http://ykt.swust.edu.cn/plat/shouyeUser',
        Colors.teal,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '官方网站',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(MTheme.radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.circleInfo,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '部分网站支持自动登录，可能会需要在重新登录后才生效',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 1,
            ),
            itemCount: websites.length,
            itemBuilder: (context, index) => websites[index],
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteItem(
    IconData icon,
    String name,
    String url,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: FTappable(
        onPress: () {
          pushTo(
            context,
            '/websites/$name-$url',
            SimpleWebViewPage(initialUrl: url),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: color.withValues(alpha: 0.8),
              size: 24,
            ),
            SizedBox(height: 4.0),
            AutoSizeText(
              name,
              minFontSize: 6,
              maxFontSize: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
