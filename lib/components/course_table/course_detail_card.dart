import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/time.dart';
import 'package:swustmeow/utils/widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../entity/soa/course/course_entry.dart';
import '../../utils/courses.dart';

class CourseDetailCard extends StatefulWidget {
  const CourseDetailCard(
      {super.key,
      required this.entries,
      required this.term,
      required this.clicked});

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

  // late PageController _indicatorController;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.entries.indexOf(widget.clicked);
    _pageController = PageController(initialPage: _currentPage);
    _currentEntry = widget.clicked;
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _calculateSize();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: context.theme.colorScheme.primaryForeground,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: size,
            minChildSize: size,
            maxChildSize: 1 / 2,
            builder: (context, scrollController) => Stack(
                  children: [
                    PageView.builder(
                        controller: _pageController,
                        itemCount: widget.entries.length,
                        onPageChanged: (index) => _refresh(() {
                              _currentPage = index;
                              _currentEntry = widget.entries[index];
                            }),
                        itemBuilder: (context, index) =>
                            _buildPage(widget.entries[index])),
                    if (widget.entries.length > 1)
                      Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _buildDotIndicator(
                                Color(_currentEntry.color),
                                widget.entries.length,
                                _currentPage),
                          ))
                  ],
                )),
      ),
    );
  }

  double _calculateSize() {
    double size = 1 / 4;

    final placeExtraLines =
        (calculateStringLength(_currentEntry.place) / 14).ceil() - 1;
    final hasExtraName = _currentEntry.courseName != _currentEntry.displayName;
    final height = MediaQuery.of(context).size.height;
    final perLine = 30 / height;

    size += perLine + (placeExtraLines * perLine);
    size += hasExtraName ? perLine : 0;
    return size;
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

  Widget _buildPage(CourseEntry entry) {
    final days = ['一', '二', '三', '四', '五', '六', '日'];
    final (_, w) = getWeekNum(widget.term, DateTime.now());
    final notStarted = w < entry.startWeek;
    final finished = checkIfFinished(widget.term, entry, widget.entries);

    return Container(
      color: Color(entry.color).withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    flex: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          entry.displayName,
                          maxLines: 1,
                          minFontSize: 10,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.primary),
                        ),
                        AutoSizeText(
                          entry.place,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16,
                              color: context.theme.colorScheme.primary),
                        )
                      ],
                    )),
                Spacer(),
                Expanded(
                  flex: 2,
                  child: AutoSizeText(
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
                          fontSize: 14)),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ...joinGap(gap: 8, axis: Axis.vertical, widgets: [
              _buildRow(FAssets.icons.squareChartGantt,
                  '星期${days[entry.weekday - 1]}第${entry.numberOfDay}节'),
              _buildRow(
                  FAssets.icons.calendarDays,
                  entry.startWeek == entry.endWeek
                      ? '第${entry.startWeek.padL2}周'
                      : '第${entry.startWeek.padL2}-${entry.endWeek.padL2}周'),
              _buildRow(
                  entry.teacherName.length == 1
                      ? FAssets.icons.user
                      : FAssets.icons.users,
                  entry.teacherName.join('、')),
              if (entry.courseName != entry.displayName)
                _buildRow(FAssets.icons.bookA, entry.courseName)
            ])
          ],
        ),
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
}
