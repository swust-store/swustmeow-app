import 'package:flutter/material.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';

import '../../data/values.dart';
import '../../utils/text.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({super.key, required this.entry, required this.active});

  final CourseEntry? entry;
  final bool active;

  @override
  State<StatefulWidget> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.entry == null) return Container();

    final dark = Values.isDarkMode;
    final bgColor = widget.active
        ? Color(widget.entry!.color).withValues(alpha: dark ? 0.8 : 1)
        : Colors.grey.withValues(alpha: dark ? 0.1 : 0.3);
    final primaryColor = Colors.white.withValues(
        alpha: dark
            ? widget.active
                ? 0.8
                : 0.4
            : widget.active
                ? 1
                : 0.8);
    final secondaryColor = Colors.white.withValues(
        alpha: dark
            ? widget.active
                ? 0.6
                : 0.2
            : widget.active
                ? 0.8
                : 0.6);

    return Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              overflowed(widget.entry!.courseName, 3 * 3),
              style: TextStyle(
                  color: primaryColor,
                  height: 0,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                  wordSpacing: 0),
            ),
            Text(
              overflowed('@${widget.entry!.place}', 3 * 3),
              style: TextStyle(
                  color: secondaryColor,
                  height: 0,
                  fontSize: 10,
                  letterSpacing: 0,
                  wordSpacing: 0),
            ),
          ],
        ));
  }
}
