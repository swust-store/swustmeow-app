import 'package:flutter/material.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';

import '../../data/values.dart';
import '../../utils/text.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({super.key, required this.courseEntries});

  final List<CourseEntry> courseEntries;

  @override
  State<StatefulWidget> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    final first = widget.courseEntries.firstOrNull;
    if (first == null) return Container();

    final active = first.getIsActive();
    final dark = Values.isDarkMode;
    final bgColor = active
        ? Color(first.color).withOpacity(dark ? 0.7 : 0.9)
        : Colors.grey.withOpacity(dark ? 0.2 : 0.4);
    final primaryColor = Colors.white.withOpacity(dark
        ? active
            ? 0.8
            : 0.4
        : active
            ? 1
            : 0.8);
    final secondaryColor = Colors.white.withOpacity(dark
        ? active
            ? 0.6
            : 0.2
        : active
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
              overflowed(first.courseName, 3 * 3),
              style: TextStyle(
                  color: primaryColor,
                  height: 0,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                  wordSpacing: 0),
            ),
            Text(
              overflowed('@${first.place}', 3 * 3),
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
