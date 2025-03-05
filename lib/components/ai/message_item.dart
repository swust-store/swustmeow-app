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
                Container(
                  padding: isUser
                      ? EdgeInsets.symmetric(horizontal: 18, vertical: 12)
                      : EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: isUser ? MTheme.primary2 : Colors.transparent,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message.content.isNotEmpty)
                        MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                            ),
                            code: TextStyle(
                              backgroundColor: isUser
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              color: isUser ? Colors.white : MTheme.primary2,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: isUser
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          selectable: true,
                        ),
                      if (!isUser && message.isReceiving) ...[
                        const SizedBox(height: 8),
                        _buildTypingIndicator(),
                      ]
                    ],
                  ),
                ),
                if (!isUser && message.isComplete) ...[
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

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 4,
          height: 4,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: MTheme.primary2.withValues(alpha: 0.5 + (index * 0.2)),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
