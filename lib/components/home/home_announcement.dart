import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/widget.dart';

class HomeAnnouncement extends StatefulWidget {
  const HomeAnnouncement({super.key});

  @override
  State<StatefulWidget> createState() => _HomeAnnouncementState();
}

class _HomeAnnouncementState extends State<HomeAnnouncement> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollPosition = 0.0;
  bool _shouldScroll = false;
  final _textStyle = TextStyle(
    fontSize: 13,
    color: Colors.black.withValues(alpha: 0.5),
  );

  @override
  void initState() {
    super.initState();
    _getAnnouncement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextSize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getAnnouncement() async {
    final result = GlobalService.serverInfo?.announcement;
    ValueService.currentAnnouncement = result;
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkTextSize();
      });
    }
  }

  void _checkTextSize() {
    setState(() {
      _shouldScroll = _scrollController.position.maxScrollExtent > 0;
      if (_shouldScroll) {
        _startScrolling();
      } else {
        _stopScrolling();
      }
    });
  }

  void _startScrolling() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 40), (timer) {
      if (_scrollController.hasClients) {
        _scrollPosition += 1;
        if (_scrollPosition > _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
        }
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  void _stopScrolling() {
    _timer?.cancel();
    _scrollPosition = 0;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(MTheme.radius),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: joinGap(gap: 8.0, axis: Axis.horizontal, widgets: [
          FaIcon(
            FontAwesomeIcons.bullhorn,
            color: Colors.orange,
            size: 14,
          ),
          Text(
            '通知 |',
            style: _textStyle,
          ),
          Expanded(
            child: ClipRect(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                child: Row(
                  children: [
                    _buildAnnouncementText(),
                    if (_shouldScroll)
                      SizedBox(width: MediaQuery.of(context).size.width / 4),
                    if (_shouldScroll) _buildAnnouncementText(),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildAnnouncementText() {
    return Text(
      ValueService.currentAnnouncement ?? '欢迎使用西科喵~',
      style: _textStyle,
      maxLines: 1,
      overflow: TextOverflow.visible,
    );
  }
}
