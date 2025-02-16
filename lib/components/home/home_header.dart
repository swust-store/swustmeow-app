import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/home/home_course_pager.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/time.dart';
import 'package:swustmeow/views/calendar_page.dart';
import 'package:swustmeow/views/course_table_page.dart';

import '../../data/m_theme.dart';
import '../../entity/soa/course/course_entry.dart';
import '../../entity/soa/course/courses_container.dart';
import '../greeting.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.activities,
    required this.containers,
    required this.currentCourseContainer,
    required this.todayCourses,
    required this.nextCourse,
    required this.currentCourse,
    required this.isLoading,
  });

  final List<Activity> activities;
  final List<CoursesContainer> containers;
  final CoursesContainer? currentCourseContainer;
  final List<CourseEntry> todayCourses;
  final CourseEntry? nextCourse;
  final CourseEntry? currentCourse;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final iconDimension = 22.0;
    final now = DateTime.now();
    const weeks = ['一', '二', '三', '四', '五', '六', '日'];
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.28,
          decoration: BoxDecoration(
            color: MTheme.primary2,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.0, 8.0, 8.0, 0.0),
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width - 24 - 8 - (2 * iconDimension) - 52,
                          child: Greeting(activities: widget.activities),
                        ),
                        IconButton(
                          onPressed: () {
                            if (widget.currentCourseContainer == null) {
                              return;
                            }
                            pushTo(
                                context,
                                CourseTablePage(
                                  containers: widget.containers,
                                  currentContainer:
                                      widget.currentCourseContainer!,
                                  activities: widget.activities,
                                ),
                                pushInto: true);
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.tableCells,
                            size: iconDimension,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            pushTo(
                                context,
                                CalendarPage(
                                  activities: widget.activities,
                                ),
                                pushInto: true);
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.calendarDay,
                            size: iconDimension,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    Text(
                      !Values.showcaseMode
                          ? '${now.month.padL2}月${now.day.padL2}日 星期${weeks[now.weekday - 1]}'
                          : '02月17日 星期一',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              ),
              HomeCoursePager(
                activities: widget.activities,
                containers: widget.containers,
                currentCourseContainer: widget.currentCourseContainer,
                todayCourses: widget.todayCourses,
                nextCourse: widget.nextCourse,
                currentCourse: widget.currentCourse,
                isLoading: widget.isLoading,
              )
            ],
          ),
        ),
      ],
    );
  }
}
