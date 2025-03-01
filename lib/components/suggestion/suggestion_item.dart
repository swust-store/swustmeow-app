import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/utils/time.dart';

import '../../data/m_theme.dart';
import '../../entity/feature_suggestion.dart';
import '../../entity/feature_suggestion_status.dart';
import '../../services/global_service.dart';
import '../utils/empty.dart';

class SuggestionItem extends StatefulWidget {
  const SuggestionItem({
    super.key,
    required this.suggestion,
    required this.onSetSuggestionStatus,
    required this.onDeleteSuggestion,
    required this.onVote,
    required this.onUnVote,
  });

  final FeatureSuggestion suggestion;
  final Future<void> Function(
          FeatureSuggestion suggestion, SuggestionStatus status)
      onSetSuggestionStatus;
  final Future<void> Function(FeatureSuggestion suggestion) onDeleteSuggestion;
  final Future<void> Function(FeatureSuggestion suggestion) onVote;
  final Future<void> Function(FeatureSuggestion suggestion) onUnVote;

  @override
  State<StatefulWidget> createState() => _SuggestionItemState();
}

class _SuggestionItemState extends State<SuggestionItem> {
  late FRadioSelectGroupController<SuggestionStatus> _statusController;

  @override
  void initState() {
    super.initState();
    _statusController = FRadioSelectGroupController<SuggestionStatus>(
        value: widget.suggestion.status);
    _statusController.addValueListener((values) {
      final status = values.first;
      widget.onSetSuggestionStatus(widget.suggestion, status);
      setState(() {
        widget.suggestion.status = status;
      });
    });
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  Color _getStatusColor(SuggestionStatus status) {
    switch (status) {
      case SuggestionStatus.completed:
        return Colors.green;
      case SuggestionStatus.working:
        return Colors.orange;
      case SuggestionStatus.noPlan:
        return Colors.grey;
      case SuggestionStatus.infeasible:
        return Colors.red;
      case SuggestionStatus.pending:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.suggestion.createdAt;
    final account = GlobalService.soaService?.currentAccount?.account ?? '';
    final isMyPost = widget.suggestion.creatorId == account;
    final isAdmin = Values.admins.contains(account);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: MTheme.border),
        borderRadius: BorderRadius.circular(MTheme.radius),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            widget.suggestion.content,
                            maxLines: 100,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isMyPost) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: MTheme.primary2.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '我的',
                              style: TextStyle(
                                color: MTheme.primary2,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IgnorePointer(
            ignoring: !isAdmin,
            child: SizedBox(
              child: FSelectMenuTile.builder(
                groupController: _statusController,
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.suggestion.status)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          widget.suggestion.status.displayName,
                          style: TextStyle(
                            color: _getStatusColor(widget.suggestion.status),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    if (isAdmin) ...[
                      SizedBox(width: 4),
                      FIcon(
                        FAssets.icons.chevronsUpDown,
                        color: Colors.black.withValues(alpha: 0.4),
                        size: 12,
                      ),
                    ]
                  ],
                ),
                divider: FTileDivider.full,
                count: SuggestionStatus.values.length,
                autoHide: true,
                suffixIcon: const Empty(),
                maxHeight: 160,
                menuAnchor: Alignment.topCenter,
                tileAnchor: Alignment.bottomCenter,
                menuTileBuilder: (context, index) {
                  final s = SuggestionStatus.values[index];
                  return FSelectTile<SuggestionStatus>(
                    title: Text(s.displayName),
                    value: s,
                    style: context.theme.selectMenuTileStyle.tileStyle,
                  );
                },
                style: context.theme.selectMenuTileStyle.copyWith(
                  tileStyle:
                      context.theme.selectMenuTileStyle.tileStyle.copyWith(
                    enabledBackgroundColor: Colors.transparent,
                    enabledHoveredBackgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    border: Border.all(
                      color: Colors.transparent,
                      width: 0.0,
                    ),
                    contentStyle: context
                        .theme.selectMenuTileStyle.tileStyle.contentStyle
                        .copyWith(
                      padding: EdgeInsets.zero,
                      suffixIconSpacing: 0,
                      prefixIconSpacing: 0,
                      titleSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Text(
                '${t.year}-${t.month.padL2}-${t.day.padL2} ${t.hour.padL2}:${t.minute.padL2}:${t.second.padL2}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              if (isMyPost || isAdmin)
                _buildActionButton(
                  icon: FAssets.icons.trash,
                  color: Colors.red,
                  onTap: () => widget.onDeleteSuggestion(widget.suggestion),
                ),
              const SizedBox(width: 12),
              FTappable(
                onPress: () {
                  widget.suggestion.hasVoted
                      ? widget.onUnVote(widget.suggestion)
                      : widget.onVote(widget.suggestion);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.suggestion.hasVoted
                        ? MTheme.primary2.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.suggestion.hasVoted
                          ? MTheme.primary2.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FIcon(
                        FAssets.icons.chevronUp,
                        size: 14,
                        color: widget.suggestion.hasVoted
                            ? MTheme.primary2
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.suggestion.votesCount}',
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.suggestion.hasVoted
                              ? MTheme.primary2
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required SvgAsset icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FTappable(
        onPress: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FIcon(
            icon,
            color: color.withValues(alpha: 0.8),
            size: 16,
          ),
        ),
      ),
    );
  }
}
