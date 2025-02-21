import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/utils/text.dart';
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
  double _currentHeight = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.entries.indexOf(widget.clicked);
    _pageController = PageController(initialPage: _currentPage);
    _currentEntry = widget.clicked;

    // 添加页面滚动监听
    _pageController.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentHeight = _calculateHeight(widget.clicked);
  }

  // 处理页面滚动
  void _handleScroll() {
    if (!mounted) return;

    // 获取当前页面位置
    final page = _pageController.page!;

    // 获取前后两个页面的索引
    final currentIndex = page.floor();
    final nextIndex = currentIndex + 1;

    // 计算两个页面之间的插值比例
    final pageDelta = page - currentIndex;

    // 确保nextIndex在有效范围内
    if (nextIndex < widget.entries.length) {
      // 计算当前页面和下一页面的高度
      final currentHeight = _calculateHeight(widget.entries[currentIndex]);
      final nextHeight = _calculateHeight(widget.entries[nextIndex]);

      // 使用线性插值计算过渡高度
      setState(() {
        _currentHeight =
            currentHeight + (nextHeight - currentHeight) * pageDelta;
        _currentEntry = widget.entries[currentIndex];
      });
    }
  }

  void _handlePageChange(int page) {
    if (!mounted) return;
    setState(() {
      _currentPage = page;
      _currentEntry = widget.entries[page];
    });
  }

  double _calculateHeight(CourseEntry entry) {
    double size = 1 / 4;
    final placeExtraLines =
        (calculateStringLength(entry.place) / 14).ceil() - 1;
    final hasExtraName = entry.courseName != entry.displayName;
    final height = MediaQuery.of(context).size.height;
    final perLine = 35 / height;

    size += perLine + (placeExtraLines * perLine);
    size += hasExtraName ? perLine : 0;
    return size;
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_handleScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primaryForeground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height * _currentHeight,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1.0,
            minChildSize: 1.0,
            maxChildSize: 1.0,
            builder: (context, scrollController) => Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.entries.length,
                  onPageChanged: _handlePageChange,
                  itemBuilder: (context, index) =>
                      _buildPage(widget.entries[index]),
                ),
                if (widget.entries.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildDotIndicator(
                        Color(_currentEntry.color),
                        widget.entries.length,
                        _currentPage,
                      ),
                    ),
                  )
              ],
            ),
          ),
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

  Widget _buildPage(CourseEntry entry) {
    final days = ['一', '二', '三', '四', '五', '六', '日'];
    final now = !Values.showcaseMode ? DateTime.now() : ShowcaseValues.now;
    widget.entries.sort((a, b) => a.startWeek.compareTo(b.startWeek));
    final allMatches =
        widget.entries.where((e) => e.courseName == entry.courseName).toList();
    final (_, w) = getWeekNum(widget.term, now);
    final notStarted = w < allMatches.first.startWeek;
    final finished = checkIfFinished(widget.term, entry, widget.entries);
    final sectionString = entry.startSection != null && entry.endSection != null
        ? '${entry.startSection}-${entry.endSection}'
        : '${entry.numberOfDay * 2 - 1}-${entry.numberOfDay * 2}节';

    return Container(
      // color: Color(entry.color).withValues(alpha: 0.4),
      color: Colors.white,
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
                          maxLines: 2,
                          minFontSize: 8,
                          maxFontSize: 20,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.primary),
                        ),
                        AutoSizeText(
                          entry.place,
                          maxLines: 2,
                          minFontSize: 8,
                          maxFontSize: 14,
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
                  '星期${days[entry.weekday - 1]}第$sectionString节'),
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
