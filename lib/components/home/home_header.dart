import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/home/home_course_pager.dart';
import 'package:swustmeow/components/utils/pop_receiver.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/calendar_page.dart';
import 'package:swustmeow/views/course_table_page.dart';

import '../../data/m_theme.dart';
import '../../entity/soa/course/course_entry.dart';
import '../../entity/soa/course/courses_container.dart';
import '../greeting.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.refresh,
    required this.activities,
    required this.containers,
    required this.currentCourseContainer,
    required this.todayCourses,
    required this.nextCourse,
    required this.currentCourse,
    required this.isLoading,
  });

  final Function() refresh;
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
  Widget build(BuildContext context) {
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Greeting(activities: widget.activities),
                        Spacer(),
                        IconButton(
                            onPressed: () {
                              if (widget.currentCourseContainer == null) {
                                return;
                              }
                              pushTo(
                                  context,
                                  PopReceiver(
                                      onPop: widget.refresh,
                                      child: CourseTablePage(
                                        containers: widget.containers,
                                        currentContainer:
                                            widget.currentCourseContainer!,
                                        activities: widget.activities,
                                      )),
                                  pushInto: true);
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.tableCells,
                              size: 22,
                              color: Colors.white,
                            )),
                        IconButton(
                            onPressed: () {
                              pushTo(
                                  context,
                                  PopReceiver(
                                    onPop: widget.refresh,
                                    child: CalendarPage(
                                      activities: widget.activities,
                                    ),
                                  ),
                                  pushInto: true);
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.calendarDay,
                              size: 22,
                              color: Colors.white,
                            ))
                      ],
                    ),
                    Text(
                      '02月06日  星期三',
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
                  isLoading: widget.isLoading)
              // SizedBox(
              //   width: MediaQuery.of(context).size.width,
              //   child: TimeCard(),
              // ),
              // const SizedBox(height: cardGap),
              // DoubleColumn(
              //     left: joinGap(
              //         gap: cardGap,
              //         axis: Axis.vertical,
              //         widgets: cards1
              //             .where((element) => cards1.indexOf(element) % 2 == 0)
              //             .toList()),
              //     right: joinGap(
              //         gap: 10,
              //         axis: Axis.vertical,
              //         widgets: cards1
              //             .where((element) => cards1.indexOf(element) % 2 == 1)
              //             .toList())),
              // const SizedBox(height: cardGap),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width,
              //   height: 144,
              //   child: const TodoCard(),
              // ),
              // const SizedBox(height: cardGap),
              // DoubleColumn(
              //     left: joinGap(
              //         gap: cardGap,
              //         axis: Axis.vertical,
              //         widgets: cards2
              //             .where((element) => cards2.indexOf(element) % 2 == 0)
              //             .toList()),
              //     right: joinGap(
              //         gap: 10,
              //         axis: Axis.vertical,
              //         widgets: cards2
              //             .where((element) => cards2.indexOf(element) % 2 == 1)
              //             .toList())),
            ],
          ),
        ),
      ],
    );
  }
}
