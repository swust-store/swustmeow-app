import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/entity/ai/ai_chat_message.dart';
import 'package:swustmeow/entity/ai/ai_model.dart';
import 'package:swustmeow/data/m_theme.dart';

class MessageItem extends StatelessWidget {
  final AIChatMessage message;
  final AIModel selectedModel;
  final VoidCallback onCopy;
  final bool isLoading;

  const MessageItem({
    super.key,
    required this.message,
    required this.selectedModel,
    required this.onCopy,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUser && !message.isComplete)
                  Container(
                    padding: EdgeInsets.only(left: 4),
                    height: 36,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLoadingDot(0),
                        _buildLoadingDot(1),
                        _buildLoadingDot(2),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: isUser
                        ? EdgeInsets.symmetric(horizontal: 18, vertical: 12)
                        : EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: isUser ? MTheme.primary2 : Colors.transparent,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                        code: TextStyle(
                          backgroundColor: isUser
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          color: isUser ? Colors.white : MTheme.primary2,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                if (!isUser) ...[
                  SizedBox(height: 2),
                  InkWell(
                    onTap: onCopy,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: FaIcon(
                        FontAwesomeIcons.copy,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: FaIcon(
          selectedModel.icon ?? FontAwesomeIcons.robot,
          color: MTheme.primary2,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Container(
          width: 4,
          height: 4,
          margin: EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: value * 0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
