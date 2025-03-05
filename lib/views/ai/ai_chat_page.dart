import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/ai_chat_test_data.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/entity/ai/ai_chat_message.dart';
import 'package:swustmeow/entity/ai/ai_model.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:flutter/services.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/api/swuststore_api.dart';
import 'dart:async';

import '../../components/ai/message_item.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<StatefulWidget> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIChatMessage> _messages = [];
  late AIModel _selectedModel;
  bool _isLoading = false;
  late FPopoverController _modelSelectController;
  bool _isSearchEnabled = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _selectedModel = AIChatTestData.models.first;
    _modelSelectController = FPopoverController(vsync: this);
    _messages.addAll(AIChatTestData.sampleMessages);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      KeyboardVisibilityController().onChange.listen((bool visible) {
        if (visible) {
          _scrollToBottom();
        }
      });
    });

    _scrollController.addListener(() {
      final showButton = _scrollController.position.pixels > 0;
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _modelSelectController.dispose();
    super.dispose();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BasePage.gradient(
          headerPad: false,
          header: BaseHeader(
            title: Text(
              'AI 助手',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            suffixIcons: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildModelSelector(),
              ),
            ],
          ),
          content: Column(
            children: [
              Expanded(
                child: _buildMessageList(),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelSelector() {
    return FPopover(
      controller: _modelSelectController,
      childAnchor: Alignment.topCenter,
      popoverAnchor: Alignment.bottomCenter,
      child: FTappable(
        onPress: () {
          _modelSelectController.toggle();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedModel.icon != null)
                Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: FaIcon(
                    _selectedModel.icon,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              Text(
                _selectedModel.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 2),
              FIcon(
                FAssets.icons.chevronsUpDown,
                color: Colors.white,
                size: 14,
              )
            ],
          ),
        ),
      ),
      popoverBuilder: (context, style, child) => Container(
        width: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AIChatTestData.models
              .map((model) => _buildModelItem(model))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildModelItem(AIModel model) {
    final isSelected = model.id == _selectedModel.id;
    return InkWell(
      onTap: () {
        _refresh(() => _selectedModel = model);
        _modelSelectController.hide();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? MTheme.primary2.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            if (model.icon != null)
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: FaIcon(
                  model.icon,
                  color: isSelected ? MTheme.primary2 : Colors.grey,
                  size: 16,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: TextStyle(
                      color: isSelected ? MTheme.primary2 : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (model.description != null)
                    Text(
                      model.description!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              FaIcon(
                FontAwesomeIcons.check,
                color: MTheme.primary2,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(left: 8, right: 0, top: 16, bottom: 16),
          itemCount: _messages.length,
          reverse: true,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            final message = _messages[_messages.length - 1 - index];
            return RepaintBoundary(
              child: _buildMessageItem(message),
            );
          },
        ),
        if (_showScrollToBottom)
          Positioned(
            bottom: 16,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MTheme.primary2,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _scrollToBottom,
                icon: Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageItem(AIChatMessage message) {
    return MessageItem(
      key: ValueKey(message.id),
      message: message,
      selectedModel: _selectedModel,
      onCopy: () {
        Clipboard.setData(ClipboardData(text: message.content));
        showSuccessToast(context, '已复制到剪贴板');
      },
    );
  }

  Widget _buildInputArea() {
    final bool isInputEmpty = _messageController.text.trim().isEmpty;
    final bool shouldDisableInput = _isLoading || isInputEmpty;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 120,
                      minHeight: 46,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(
                        color: !isInputEmpty
                            ? MTheme.primary2.withValues(alpha: 0.2)
                            : Colors.grey.shade100,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: TextField(
                        controller: _messageController,
                        enabled: !_isLoading,
                        // 在加载时禁用输入框
                        maxLines: null,
                        cursorColor: MTheme.primary2,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: _isLoading ? '等待 AI 回复中...' : '输入消息...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: shouldDisableInput ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(23),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        color:
                            shouldDisableInput ? Colors.white : MTheme.primary2,
                        boxShadow: shouldDisableInput
                            ? null
                            : [
                                BoxShadow(
                                  color: MTheme.primary2.withValues(alpha: 0.2),
                                  offset: Offset(0, 2),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.paperPlane,
                          color: shouldDisableInput
                              ? Colors.grey.shade400
                              : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSearchEnabled = !_isSearchEnabled;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isSearchEnabled
                          ? MTheme.primary2.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isSearchEnabled
                            ? MTheme.primary2.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.globe,
                          size: 16,
                          color:
                              _isSearchEnabled ? MTheme.primary2 : Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '联网搜索',
                          style: TextStyle(
                            color: _isSearchEnabled
                                ? MTheme.primary2
                                : Colors.grey,
                            fontSize: 14,
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
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMessage = AIChatMessage.user(content: text);
    _messageController.clear();

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    // 添加一个空的 AI 消息用于显示加载状态
    final aiMessage = AIChatMessage.assistant(
      content: '',
      isComplete: false,
    );

    setState(() {
      _messages.add(aiMessage);
    });

    String responseText = '';

    await SWUSTStoreApiService.streamChat(
      prompt: text,
      useSearch: _isSearchEnabled,
      onToken: (token) {
        // 直接在每个 token 到达时更新状态
        if (mounted) {
          setState(() {
            responseText += token;
            _messages.last = AIChatMessage.assistant(
              content: responseText,
              isComplete: false,
              isReceiving: true,
            );
          });
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _messages.last = AIChatMessage.assistant(
            content: '对话失败：$error',
            isComplete: true,
          );
          _isLoading = false;
        });
      },
      onComplete: () {
        if (!mounted) return;
        setState(() {
          _messages.last = AIChatMessage.assistant(
            content: responseText,
            isComplete: true,
          );
          _isLoading = false;
        });
      },
    );

    _scrollToBottom();
  }
}
