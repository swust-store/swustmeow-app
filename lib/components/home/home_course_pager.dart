import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/course_table_page.dart';

import '../../entity/soa/course/course_entry.dart';
import '../../entity/soa/course/courses_container.dart';
import '../../services/box_service.dart';
import 'horizontal_card_pager.dart';
import 'horizontal_course_card.dart';

class HomeCoursePager extends StatefulWidget {
  const HomeCoursePager(
      {super.key,
      required this.activities,
      required this.containers,
      required this.currentCourseContainer,
      required this.todayCourses,
      required this.nextCourse,
      required this.currentCourse,
      required this.isLoading});

  final List<Activity> activities;
  final List<CoursesContainer> containers;
  final CoursesContainer? currentCourseContainer;
  final List<CourseEntry> todayCourses;
  final CourseEntry? nextCourse;
  final CourseEntry? currentCourse;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => _HomeCoursePagerState();
}

class _HomeCoursePagerState extends State<HomeCoursePager> {
  Timer? _timer;
  String? _hitokoto;
  static const height = 120.0;
  static const fallbackHitokoto = '只要开始追赶，就已经走在胜利的路上。';

  @override
  void initState() {
    super.initState();
    _hitokoto =
        (BoxService.commonBox.get('hitokoto') as String?) ?? fallbackHitokoto;

    // 每五分钟更新一次卡片
    _timer ??= Timer.periodic(const Duration(seconds: 5), (timer) {
      _refresh();
    });
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  List<CourseEntry> _randomEntries(int length) {
    return List.generate(
        length,
        (_) => CourseEntry(
            courseName: 'A' * 8,
            teacherName: ['A' * 3],
            startWeek: 1,
            endWeek: 99,
            place: 'A' * 8,
            weekday: 1,
            numberOfDay: 1,
            displayName: 'A' * 5));
  }

  Widget _buildPager(List<CourseEntry> entries, {required int page}) {
    return HorizontalCardPager(
        initialPage: page,
        onPress: () {
          pushTo(
            context,
            CourseTablePage(
                containers: widget.containers,
                currentContainer: widget.currentCourseContainer!,
                activities: widget.activities),
            pushInto: true,
          );
        },
        children: entries
            .map(
              (entry) => HorizontalCourseCard(
                height: height,
                course: entry,
                isActive: widget.currentCourse == entry,
                isNext: widget.nextCourse == entry,
              ),
            )
            .toList());
  }

  Widget _buildEmptyPager() {
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            height: height,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.penNib),
                    SizedBox(width: 4.0),
                    Text(
                      '一言',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                ),
                AutoSizeText(
                  _hitokoto ?? '加载中',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '今天没有课哦，好好休息吧~',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        enabled: widget.isLoading,
        child: widget.isLoading
            ? _buildPager(_randomEntries(2), page: 0)
            : widget.todayCourses.isNotEmpty
                ? _buildPager(widget.todayCourses,
                    page: widget.todayCourses.firstOrNull != null
                        ? widget.todayCourses.indexOf(widget.currentCourse ??
                            widget.nextCourse ??
                            widget.todayCourses.first)
                        : 0)
                : _buildEmptyPager());
  }
}
