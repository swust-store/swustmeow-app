import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/utils/time.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../data/m_theme.dart';
import '../../entity/feature_suggestion.dart';
import '../../services/global_service.dart';

class SuggestionItem extends StatefulWidget {
  const SuggestionItem({
    super.key,
    required this.suggestion,
    required this.onCompleteSuggestion,
    required this.onSetSuggestionWorking,
    required this.onDeleteSuggestion,
    required this.onVote,
    required this.onUnVote,
  });

  final FeatureSuggestion suggestion;
  final Future<void> Function(FeatureSuggestion suggestion)
      onCompleteSuggestion;
  final Future<void> Function(FeatureSuggestion suggestion, bool working)
      onSetSuggestionWorking;
  final Future<void> Function(FeatureSuggestion suggestion) onDeleteSuggestion;
  final Future<void> Function(FeatureSuggestion suggestion) onVote;
  final Future<void> Function(FeatureSuggestion suggestion) onUnVote;

  @override
  State<StatefulWidget> createState() => _SuggestionItemState();
}

class _SuggestionItemState extends State<SuggestionItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.suggestion.createdAt;
    final account = GlobalService.soaService?.currentAccount?.account ?? '';
    final isMyPost = widget.suggestion.creatorId == account;

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
                    AutoSizeText(
                      widget.suggestion.content,
                      maxLines: 100,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: joinGap(
                  gap: 12,
                  axis: Axis.horizontal,
                  widgets: [
                    if (Values.admins.contains(account)) ...[
                      if (!widget.suggestion.isCompleted)
                        FTappable(
                          onPress: () async {
                            if (!Values.admins.contains(account)) return;
                            await widget.onSetSuggestionWorking(
                                widget.suggestion,
                                !widget.suggestion.isWorking);
                          },
                          child: FIcon(
                            widget.suggestion.isWorking
                                ? FAssets.icons.pause
                                : FAssets.icons.play,
                            color: widget.suggestion.isWorking
                                ? Colors.orange.withValues(alpha: 0.8)
                                : MTheme.primary2.withValues(alpha: 0.8),
                          ),
                        ),
                      if (!widget.suggestion.isCompleted &&
                          widget.suggestion.isWorking)
                        FTappable(
                          onPress: () async {
                            if (!Values.admins.contains(account)) return;
                            await widget
                                .onCompleteSuggestion(widget.suggestion);
                          },
                          child: FIcon(
                            FAssets.icons.check,
                            color: Colors.green.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                    if (widget.suggestion.creatorId == account ||
                        Values.admins.contains(account))
                      FTappable(
                        onPress: () async =>
                            await widget.onDeleteSuggestion(widget.suggestion),
                        child: FIcon(
                          FAssets.icons.trash,
                          color: Colors.red.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${t.year}-${t.month.padL2}-${t.day.padL2} ${t.hour.padL2}:${t.minute.padL2}:${t.second.padL2}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (widget.suggestion.isCompleted
                          ? Colors.green
                          : widget.suggestion.isWorking
                              ? Colors.orange
                              : Colors.red)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.suggestion.isCompleted
                      ? '已完成'
                      : widget.suggestion.isWorking
                          ? '进行中'
                          : '未完成',
                  style: TextStyle(
                    color: widget.suggestion.isCompleted
                        ? Colors.green
                        : widget.suggestion.isWorking
                            ? Colors.orange
                            : Colors.red,
                    fontSize: 10,
                  ),
                ),
              ),
              if (isMyPost) ...[
                const SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              const Spacer(),
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
}
