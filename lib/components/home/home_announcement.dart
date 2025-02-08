import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/widget.dart';

class HomeAnnouncement extends StatefulWidget {
  const HomeAnnouncement({super.key});

  @override
  State<StatefulWidget> createState() => _HomeAnnouncementState();
}

class _HomeAnnouncementState extends State<HomeAnnouncement> {
  @override
  void initState() {
    super.initState();
    _getAnnouncement();
  }

  Future<void> _getAnnouncement() async {
    final result = GlobalService.serverInfo?.announcement;
    ValueService.currentAnnouncement = result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: joinGap(gap: 8.0, axis: Axis.horizontal, widgets: [
          FaIcon(
            FontAwesomeIcons.bullhorn,
            color: Colors.orange,
            size: 14,
          ),
          Expanded(
            child: Text(
              '通知 | ${ValueService.currentAnnouncement ?? '欢迎使用西科喵~'}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
