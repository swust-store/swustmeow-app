import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/api/swuststore_api.dart';
import 'package:swustmeow/components/suggestion/suggestion_add_sheet.dart';
import 'package:swustmeow/components/suggestion/suggestion_filter_option.dart';
import 'package:swustmeow/components/suggestion/suggestion_item.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/feature_suggestion.dart';
import 'package:swustmeow/entity/feature_suggestion_status.dart';
import 'package:swustmeow/services/boxes/common_box.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/time.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../components/suggestion/suggestion_sort_option.dart';
import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../services/value_service.dart';
import '../../components/utils/simple_pagination.dart';

class SettingsFeatureSuggestionPage extends StatefulWidget {
  const SettingsFeatureSuggestionPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsFeatureSuggestionPageState();
}

class _SettingsFeatureSuggestionPageState
    extends State<SettingsFeatureSuggestionPage> with TickerProviderStateMixin {
  List<FeatureSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  int _currentPage = 1;
  static const int _perPage = 15;
  late AnimationController _refreshAnimationController;
  SuggestionSortOption _currentSort = SuggestionSortOption.timeDesc;
  SuggestionFilterOption _currentFilter = SuggestionFilterOption.all;
  late FPopoverController _sortPopoverController;
  late FPopoverController _filterPopoverController;
  int _totalPages = 1;
  int _total = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _sortPopoverController = FPopoverController(vsync: this);
    _filterPopoverController = FPopoverController(vsync: this);
    _loadSuggestions(refresh: true);
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    _sortPopoverController.dispose();
    _filterPopoverController.dispose();
    super.dispose();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  Future<void> _loadSuggestions({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
    });

    final account = GlobalService.soaService?.currentAccount?.account ?? '';
    final result = await SWUSTStoreApiService.getSuggestions(
      userId: account,
      page: _currentPage,
      perPage: _perPage,
      sort: _currentSort,
      filter: _currentFilter,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      if (result.status != Status.ok) {
        showErrorToast(result.value);
        return;
      }

      final data = result.value as Map<String, dynamic>;
      final newSuggestions = data['suggestions'] as List<FeatureSuggestion>;
      final pagination = data['pagination'] as Map<String, dynamic>;

      _suggestions = newSuggestions;
      _totalPages = pagination['total_pages'] as int;
      _total = pagination['total'] as int;
    });

    if (_scrollController.positions.isNotEmpty) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
            '建议反馈',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          suffixIcons: [
            Stack(
              children: [
                IconButton(
                  onPressed: () async {
                    if (_isLoading || _isRefreshing) return;
                    _loadSuggestions(refresh: true);
                    _refreshAnimationController.repeat();
                    await _loadSuggestions(refresh: true);
                    _refresh(() {
                      _isRefreshing = false;
                      _refreshAnimationController.stop();
                      _refreshAnimationController.reset();
                    });
                  },
                  icon: RotationTransition(
                    turns: _refreshAnimationController,
                    child: FaIcon(
                      FontAwesomeIcons.rotateRight,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                if (_isRefreshing)
                  Positioned(
                    bottom: 5,
                    left: 20 / 2,
                    child: Text(
                      '刷新中...',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        content: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: joinGap(
                      gap: 16,
                      axis: Axis.horizontal,
                      widgets: [
                        _buildSortButton(),
                        _buildFilterButton(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: MTheme.primary2,
                          ),
                        )
                      : _suggestions.isEmpty
                          ? _buildEmptyContent()
                          : _buildSuggestionList(),
                ),
              ],
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  if (_isLoading) return;
                  _showAddSheet();
                },
                backgroundColor: MTheme.primary2,
                elevation: 4,
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.lightbulb,
            size: 60,
            color: Colors.grey.withValues(alpha: 0.6),
          ),
          SizedBox(height: 16),
          Text(
            '这里什么都木有~',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              '点击右下角加号来为${Values.name}提个建议吧',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              if (_isLoading) return;
              _showAddSheet();
            },
            icon: FaIcon(
              FontAwesomeIcons.plus,
              size: 16,
              color: MTheme.primary2,
            ),
            label: Text('添加新建议'),
            style: OutlinedButton.styleFrom(
              foregroundColor: MTheme.primary2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionList() {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 80,
      ),
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemCount: _suggestions.length + (_suggestions.isNotEmpty ? 2 : 0),
      itemBuilder: (context, index) {
        if (index == _suggestions.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Center(
              child: Text(
                '共 $_total 条',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }
        if (index == _suggestions.length + 1) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: SimplePagination(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadSuggestions();
              },
            ),
          );
        }
        return SuggestionItem(
          suggestion: _suggestions[index],
          onSetSuggestionStatus: _setSuggestionStatus,
          onDeleteSuggestion: _deleteSuggestion,
          onVote: _voteSuggestion,
          onUnVote: _unVoteSuggestion,
        );
      },
    );
  }

  Widget _buildSortButton() {
    return FPopover(
      controller: _sortPopoverController,
      popoverBuilder: (context, style, _) => SizedBox(
        width: 170,
        child: FTileGroup.builder(
          divider: FTileDivider.full,
          count: SuggestionSortOption.values.length,
          tileBuilder: (context, index) {
            final option = SuggestionSortOption.values[index];
            return FTile(
              title: Text(option.description),
              prefixIcon: FIcon(
                FAssets.icons.check,
                size: 16,
                color: _currentSort == option ? null : Colors.transparent,
              ),
              onPress: () async {
                await _sortPopoverController.hide();
                if (_currentSort != option) {
                  setState(() => _currentSort = option);
                  _loadSuggestions(refresh: true);
                }
              },
            );
          },
        ),
      ),
      child: FTappable(
        onPress: () async {
          if (_isLoading || _isRefreshing) return;
          await _sortPopoverController.toggle();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentSort.description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            FIcon(FAssets.icons.chevronsUpDown),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return FPopover(
      controller: _filterPopoverController,
      popoverBuilder: (context, style, _) => SizedBox(
        width: 170,
        child: FTileGroup.builder(
          divider: FTileDivider.full,
          count: SuggestionFilterOption.values.length,
          tileBuilder: (context, index) {
            final option = SuggestionFilterOption.values[index];
            return FTile(
              title: Text(option.description),
              prefixIcon: FIcon(
                FAssets.icons.check,
                size: 16,
                color: _currentFilter == option ? null : Colors.transparent,
              ),
              onPress: () async {
                await _filterPopoverController.hide();
                if (_currentFilter != option) {
                  setState(() => _currentFilter = option);
                  _loadSuggestions(refresh: true);
                }
              },
            );
          },
        ),
      ),
      child: FTappable(
        onPress: () async {
          if (_isLoading || _isRefreshing) return;
          await _filterPopoverController.toggle();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentFilter.description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            FIcon(FAssets.icons.filter),
          ],
        ),
      ),
    );
  }

  Future<String?> _addSuggestion(String content) async {
    final userId = GlobalService.soaService?.currentAccount?.account;
    if (userId == null) {
      return '未登录';
    }

    final result = await SWUSTStoreApiService.createSuggestion(content, userId);
    if (result.status != Status.ok || result.value is String) {
      return result.value ?? '未知错误';
    }

    final suggestion = result.value as FeatureSuggestion;

    Map<String, int>? selfSuggestionCount =
        (CommonBox.get('selfSuggestionCount') as Map<dynamic, dynamic>?)
            ?.cast();
    final now = DateTime.now();
    final today = '${now.year}-${now.month.padL2}-${now.day.padL2}';

    selfSuggestionCount ??= {};

    if (selfSuggestionCount.containsKey(today)) {
      if (selfSuggestionCount[today]! >= 5 && !Values.admins.contains(userId)) {
        return '今天已达到建议数量上限';
      }

      selfSuggestionCount[today] = selfSuggestionCount[today]! + 1;
    } else {
      selfSuggestionCount[today] = 1;
    }

    CommonBox.put('selfSuggestionCount', selfSuggestionCount);
    _refresh(() => _suggestions.insert(0, suggestion));
    return null;
  }

  void _showAddSheet() {
    showFSheet(
      context: context,
      builder: (context) => SuggestionAddSheet(onAdd: _addSuggestion),
      side: FLayout.btt,
      mainAxisMaxRatio: 1,
    );
  }

  Future<void> _setSuggestionStatus(
      FeatureSuggestion suggestion, SuggestionStatus status) async {
    final account = GlobalService.soaService?.currentAccount?.account ?? '';
    final result = await SWUSTStoreApiService.setSuggestionStatus(
        suggestion.id, account, status);
    if (result.status != Status.ok) {
      showErrorToast(result.value ?? '未知错误');
    } else {
      showSuccessToast('设置状态成功');
      _refresh(() {
        _suggestions.singleWhere((s) => s.id == suggestion.id).status = status;
      });
    }
  }

  Future<void> _deleteSuggestion(FeatureSuggestion suggestion) async {
    final account = GlobalService.soaService?.currentAccount?.account ?? '';
    final result =
        await SWUSTStoreApiService.deleteSuggestion(suggestion.id, account);
    if (result.status != Status.ok) {
      showErrorToast(result.value ?? '未知错误');
    } else {
      showSuccessToast('删除成功');
      _refresh(() {
        _suggestions.removeWhere((s) => s.id == suggestion.id);
      });
    }
  }

  Future<void> _voteSuggestion(FeatureSuggestion suggestion) async {
    final account = GlobalService.soaService?.currentAccount?.account ?? '';
    final result =
        await SWUSTStoreApiService.voteSuggestion(suggestion.id, account);
    if (result.status != Status.ok) {
      showErrorToast(result.value ?? '未知错误');
    } else {
      _refresh(() {
        final r = _suggestions.singleWhere((s) => s.id == suggestion.id);
        r.hasVoted = true;
        r.votesCount++;
      });
    }
  }

  Future<void> _unVoteSuggestion(FeatureSuggestion suggestion) async {
    final account = GlobalService.soaService?.currentAccount?.account ?? '';
    final result =
        await SWUSTStoreApiService.unvoteSuggestion(suggestion.id, account);
    if (result.status != Status.ok) {
      showErrorToast(result.value ?? '未知错误');
    } else {
      _refresh(() {
        final r = _suggestions.singleWhere((s) => s.id == suggestion.id);
        r.hasVoted = false;
        r.votesCount--;
      });
    }
  }
}
