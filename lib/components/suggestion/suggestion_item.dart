import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/utils/time.dart';

import '../../config.dart';
import '../../data/m_theme.dart';
import '../../entity/feature_suggestion.dart';
import '../../entity/feature_suggestion_status.dart';
import '../../services/global_service.dart';

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
    final isAdmin = Config.admins.contains(account);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: MTheme.primary2.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '我的',
                              style: TextStyle(
                                color: MTheme.primary2,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
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
            child: FTappable(
              onPress: isAdmin ? () => _showStatusBottomSheet(context) : null,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.suggestion.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.suggestion.status.displayName,
                        style: TextStyle(
                          color: _getStatusColor(widget.suggestion.status),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
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
            ),
          ),
          Divider(
            height: 16,
            color: Colors.grey.withValues(alpha: 0.1),
          ),
          Row(
            children: [
              Text(
                '${t.year}-${t.month.padL2}-${t.day.padL2} ${t.hour.padL2}:${t.minute.padL2}',
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
                    borderRadius: BorderRadius.circular(8),
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

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(MTheme.radius),
              topRight: Radius.circular(MTheme.radius),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '设置状态',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              Container(
                height: 1,
                color: Colors.grey.shade100,
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: SuggestionStatus.values.length,
                  itemBuilder: (context, index) {
                    final status = SuggestionStatus.values[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                status.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              if (widget.suggestion.status == status) ...[
                                SizedBox(width: 8),
                                FIcon(
                                  FAssets.icons.check,
                                  size: 16,
                                  color: MTheme.primary2,
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            _statusController.value = {status};
                            Navigator.pop(context);
                          },
                        ),
                        if (index < SuggestionStatus.values.length - 1)
                          Container(
                            height: 1,
                            color: Colors.grey.shade100,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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
            borderRadius: BorderRadius.circular(8),
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
