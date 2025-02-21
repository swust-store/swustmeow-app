import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/utils/time.dart';
import 'package:swustmeow/utils/widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../entity/soa/course/course_entry.dart';
import '../../utils/courses.dart';

class CourseDetailCard extends StatefulWidget {
  const CourseDetailCard({
    super.key,
    required this.entries,
    required this.term,
    required this.clicked,
  });

  final List<CourseEntry> entries;
  final String term;
  final CourseEntry clicked;

  @override
  State<StatefulWidget> createState() => _CourseDetailCardState();
}

class _CourseDetailCardState extends State<CourseDetailCard> {
  late PageController _pageController;
  int _currentPage = 0;
  late CourseEntry _currentEntry;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.entries.indexOf(widget.clicked);
    _pageController = PageController(initialPage: _currentPage);
    _currentEntry = widget.clicked;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                ExpandablePageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                      _currentEntry = widget.entries[page];
                    });
                  },
                  children:
                      widget.entries.map((entry) => _buildPage(entry)).toList(),
                ),
                if (widget.entries.length > 1)
                  Center(
                    child: _buildDotIndicator(
                      Color(_currentEntry.color),
                      widget.entries.length,
                      _currentPage,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(CourseEntry entry) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.place,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: _buildStatusText(entry),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...joinGap(
              gap: 12,
              axis: Axis.vertical,
              widgets: [
                _buildRow(
                  FAssets.icons.squareChartGantt,
                  '星期${[
                    '一',
                    '二',
                    '三',
                    '四',
                    '五',
                    '六',
                    '日'
                  ][entry.weekday - 1]}第${_getSectionString(entry)}节',
                ),
                _buildRow(
                  FAssets.icons.calendarDays,
                  entry.startWeek == entry.endWeek
                      ? '第${entry.startWeek.padL2}周'
                      : '第${entry.startWeek.padL2}-${entry.endWeek.padL2}周',
                ),
                _buildRow(
                  entry.teacherName.length == 1
                      ? FAssets.icons.user
                      : FAssets.icons.users,
                  entry.teacherName.join('、'),
                ),
                if (entry.courseName != entry.displayName)
                  _buildRow(FAssets.icons.bookA, entry.courseName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(SvgAsset icon, String text) => Row(
        children: [
          FIcon(
            icon,
            size: 20,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: 18, color: context.theme.colorScheme.primary),
          )
        ],
      );

  Widget _buildStatusText(CourseEntry entry) {
    final now = !Values.showcaseMode ? DateTime.now() : ShowcaseValues.now;
    final (_, w) = getWeekNum(widget.term, now);
    final notStarted = w < widget.entries.first.startWeek;
    final finished = checkIfFinished(widget.term, entry, widget.entries);

    return AutoSizeText(
      notStarted
          ? '未开课'
          : finished
              ? '已结课🎉'
              : '剩余${getWeeksRemaining(widget.term, entry, widget.entries)}周',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: notStarted
            ? Colors.red
            : finished
                ? Colors.green
                : context.theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildDotIndicator(Color color, int count, int currentIndex) {
    return Transform.scale(
      scale: 0.5,
      child: AnimatedSmoothIndicator(
        activeIndex: currentIndex,
        count: count,
        effect: WormEffect(),
      ),
    );
  }

  String _getSectionString(CourseEntry entry) {
    return entry.startSection != null && entry.endSection != null
        ? '${entry.startSection}-${entry.endSection}'
        : '${entry.numberOfDay * 2 - 1}-${entry.numberOfDay * 2}';
  }
}
