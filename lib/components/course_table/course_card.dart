import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/components/utils/empty.dart';

import '../../entity/soa/course/course_entry.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({
    super.key,
    required this.entry,
    required this.active,
    required this.isMore,
    required this.isConflict,
  });

  final CourseEntry? entry;
  final bool active;

  /// 当前课程表位置是否有更多课程
  final bool isMore;

  /// 当前课程表位置是否重课（排课冲突）
  final bool isConflict;

  @override
  State<StatefulWidget> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entry == null) return Container();

    final color = Color(widget.entry!.color);
    // final dark = Values.isDarkMode;
    final bgColor = widget.active
        ? color.withValues(alpha: /*dark ? 0.8 :*/ 1)
        : Colors.grey.withValues(alpha: /*dark ? 0.1 :*/ 0.4);
    final primaryColor = Colors.white.withValues(
        alpha: /*dark
            ? widget.active
                ? 0.8
                : 0.4
            :*/
            widget.active ? 1 : 0.8);
    final secondaryColor = Colors.white.withValues(
        alpha: /*dark
            ? widget.active
                ? 0.6
                : 0.2
            :*/
            widget.active ? 0.8 : 0.6);

    final displayName = widget.entry!.displayName;
    final courseName = widget.entry!.courseName;
    final name =
        displayName == courseName ? displayName : '$displayName-$courseName';
    final conflictBorderWidth = 1.5;

    return widget.active
        ? Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(6 + conflictBorderWidth)),
              border: widget.isConflict
                  ? Border.all(
                      color: Colors.red,
                      width: conflictBorderWidth,
                    )
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    (widget.isMore ? '*' : '') + name,
                    style: TextStyle(
                      color: primaryColor,
                      height: 0,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                      wordSpacing: 0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    minFontSize: 10,
                  ),
                  AutoSizeText(
                    '@${widget.entry!.place}',
                    style: TextStyle(
                        color: secondaryColor,
                        height: 0,
                        fontSize: 10,
                        letterSpacing: 0,
                        wordSpacing: 0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    minFontSize: 8,
                  ),
                ],
              ),
            ),
          )
        : const Empty();
  }
}
