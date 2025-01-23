import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../utils/time.dart';

class HeaderRow extends StatefulWidget {
  const HeaderRow({super.key});

  @override
  State<StatefulWidget> createState() => _HeaderRowState();
}

class _HeaderRowState extends State<HeaderRow> {
  static const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  Widget build(BuildContext context) {
    final time = DateTime.now();
    getTextStyle(int index) => TextStyle(
        fontSize: 10,
        color: time.weekday == index + 1
            ? Colors.lightBlue
            : context.theme.colorScheme.primary);

    return Row(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            '${getCourseWeekNum(time).padL2}周',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        ...List.generate(
            days.length,
            (index) => Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(days[index], style: getTextStyle(index)),
                        Text(
                          '${time.month}/${time.day + index}',
                          style: getTextStyle(index),
                        )
                      ],
                    ),
                  ),
                )),
      ],
    );
  }
}
