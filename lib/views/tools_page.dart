import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/tool.dart';
import 'package:swustmeow/services/tool_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:vibration/vibration.dart';
import '../services/value_service.dart';
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
    _tools = Values.tools.value;
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
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '工具',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          suffixIcons: [
            if (_isEditMode)
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.rotateRight,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await ToolService.resetToDefault();
                  setState(() {
                    _tools = Values.tools.value;
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
                color: Colors.white,
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
            _buildSuggestions(),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    int columns = _visibleToolIds.length <= 6 ? 3 : 4;

    return ReorderableGrid(
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: Values.tools.value.length,
      itemBuilder: (context, index) {
        final tool = Values.tools.value[index];
        final service =
            tool.serviceGetter != null ? tool.serviceGetter!() : null;
        final isLogin = service == null ? true : service.isLogin;
        final isVisible = _visibleToolIds.contains(tool.id);

        return Container(
          key: Key(tool.id),
          decoration: BoxDecoration(
            color: Colors.white,
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
                          FaIcon(
                            tool.icon,
                            color: isLogin
                                ? tool.color.withValues(alpha: 1)
                                : Colors.grey.withValues(alpha: 0.4),
                            size: 26,
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
        HapticFeedback.heavyImpact();
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 100, sharpness: 0.2);
        }
      },
      proxyDecorator: (child, index, animation) => AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
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
    );
  }

  Future<void> _toggleToolVisibility(String toolId) async {
    final isVisible = _visibleToolIds.contains(toolId);

    setState(() {
      if (isVisible) {
        // 确保至少有一个工具是可见的
        if (_visibleToolIds.length > 1) {
          _visibleToolIds.remove(toolId);
          ToolService.updateToolVisibility(toolId, false);
        } else {
          showErrorToast('至少需要保留一个工具');
        }
      } else {
        // 确保不超过9个工具
        if (_visibleToolIds.length < 9) {
          _visibleToolIds.add(toolId);
          ToolService.updateToolVisibility(toolId, true);
        } else {
          showErrorToast('最多只能显示9个工具');
        }
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
    pushTo(context, tool.pageBuilder(), pushInto: true);

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
                  color: Colors.black87,
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
                      fontSize: 12,
                      color: Colors.blue,
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
                                FaIcon(
                                  tool.icon,
                                  color: isLogin
                                      ? tool.color.withValues(alpha: 1)
                                      : Colors.grey.withValues(alpha: 0.4),
                                  size: 24,
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

  Widget _buildSuggestions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐工具',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MTheme.radius),
            ),
            child: Center(
              child: Text(
                '即将推出更多工具',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
