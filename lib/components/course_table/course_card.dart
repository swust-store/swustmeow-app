import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/components/utils/empty.dart';

import '../../entity/soa/course/course_entry.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({
    super.key,
    required this.entry,
    required this.active,
    required this.isDuplicate,
  });

  final CourseEntry? entry;
  final bool active;
  final bool isDuplicate;

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

    return widget.active
        ? Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  (widget.isDuplicate ? '*' : '') + name,
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
          )
        : const Empty();
  }
}
