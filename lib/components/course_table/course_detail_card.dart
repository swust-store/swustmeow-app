import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/m_theme.dart';
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
    required this.isConflict,
    required this.onSelectDisplay,
    required this.displayEntry,
  });

  final List<CourseEntry> entries;
  final String term;
  final CourseEntry clicked;
  final bool isConflict;
  final Function(CourseEntry) onSelectDisplay;
  final CourseEntry displayEntry;

  @override
  State<StatefulWidget> createState() => _CourseDetailCardState();
}

class _CourseDetailCardState extends State<CourseDetailCard> {
  late PageController _pageController;
  int _currentPage = 0;
  late CourseEntry _currentEntry;
  late CourseEntry _displayEntry;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.entries.indexOf(widget.clicked);
    _pageController = PageController(initialPage: _currentPage);
    _currentEntry = widget.clicked;
    _displayEntry = widget.displayEntry;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
              if (widget.entries.length > 1) ...[
                Center(
                  child: _buildDotIndicator(
                    Color(_currentEntry.color),
                    widget.entries.length,
                    _currentPage,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildBadges(CourseEntry entry) {
    final isConflict = widget.isConflict;
    final isDisplaying = entry == _displayEntry;

    if (!isConflict && !isDisplaying && entry.isCustom != true) return null;

    final children = [
      if (isConflict)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, size: 14, color: Colors.red.shade400),
              const SizedBox(width: 4),
              Text(
                '重课',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      if (entry.isCustom == true) ...[
        if (isConflict) const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 14, color: Colors.blue.shade400),
              const SizedBox(width: 4),
              Text(
                '自定义课程',
                style: TextStyle(
                  color: Colors.blue.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      if (isDisplaying && isConflict) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 14, color: Colors.green.shade400),
              const SizedBox(width: 4),
              Text(
                '当前展示',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ]
    ];

    return children.isNotEmpty
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        : null;
  }

  Widget? _buildStatusBadge(CourseEntry entry) {
    final now = !Values.showcaseMode ? DateTime.now() : ShowcaseValues.now;
    final sameCourses = findSameCourses(entry, widget.entries)
      ..sort((a, b) => a.startWeek.compareTo(b.startWeek));
    final (_, w) = getWeekNum(widget.term, now);
    final (s, _, _) = getCourseTime(sameCourses.first);
    final startTime = timeStringToTimeOfDay(s);
    final nowTime = timeStringToTimeOfDay('${now.hour}:${now.minute}');
    final notStarted = w < sameCourses.first.startWeek ||
        (w == sameCourses.first.startWeek && nowTime < startTime);
    final finished = checkIfFinished(widget.term, entry, widget.entries);

    if (!notStarted && !finished) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            (notStarted ? Colors.orange : Colors.green).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MTheme.radius),
        border: Border.all(
          color: (notStarted ? Colors.orange : Colors.green)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            notStarted ? Icons.schedule_rounded : Icons.celebration_rounded,
            size: 14,
            color: notStarted ? Colors.orange.shade400 : Colors.green.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            notStarted ? '未开课' : '已结课',
            style: TextStyle(
              color:
                  notStarted ? Colors.orange.shade400 : Colors.green.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(CourseEntry entry) {
    final badges = _buildBadges(entry);
    final statusBadges = _buildStatusBadge(entry);

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.displayName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.theme.colorScheme.primary,
                      height: 1.2,
                    ),
                  ),
                ),
                if (widget.isConflict && entry != _displayEntry)
                  FTappable(
                    onPress: () {
                      widget.onSelectDisplay(entry);
                      setState(() {
                        _displayEntry = entry;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.visibility_outlined,
                        size: 20,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color:
                      context.theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AutoSizeText(
                    entry.place,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.theme.colorScheme.primary
                          .withValues(alpha: 0.7),
                      height: 1.2,
                    ),
                    minFontSize: 12,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (badges != null || statusBadges != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (badges != null) badges,
                  if (statusBadges != null) statusBadges,
                ],
              ),
            ],
            const SizedBox(height: 16),
            ...joinGap(
              gap: 8,
              axis: Axis.vertical,
              widgets: [
                _buildInfoRow(
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
                _buildInfoRow(
                  FAssets.icons.calendarDays,
                  entry.startWeek == entry.endWeek
                      ? '第${entry.startWeek.padL2}周'
                      : '第${entry.startWeek.padL2}-${entry.endWeek.padL2}周',
                ),
                _buildInfoRow(
                  entry.teacherName.length == 1
                      ? FAssets.icons.user
                      : FAssets.icons.users,
                  entry.teacherName.join('、'),
                ),
                if (entry.courseName != entry.displayName)
                  _buildInfoRow(FAssets.icons.bookA, entry.courseName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(SvgAsset icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FIcon(
            icon,
            size: 18,
            color: context.theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: context.theme.colorScheme.primary.withValues(alpha: 0.9),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(Color color, int count, int currentIndex) {
    return SmoothPageIndicator(
      controller: _pageController,
      count: count,
      effect: WormEffect(
        dotHeight: 8,
        dotWidth: 8,
        spacing: 8,
        activeDotColor: color,
        dotColor: color.withValues(alpha: 0.2),
      ),
    );
  }

  String _getSectionString(CourseEntry entry) {
    return entry.startSection != null && entry.endSection != null
        ? '${entry.startSection}-${entry.endSection}'
        : '${entry.numberOfDay * 2 - 1}-${entry.numberOfDay * 2}';
  }
}
