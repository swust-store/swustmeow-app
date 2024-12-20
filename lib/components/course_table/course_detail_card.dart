import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/utils/widget.dart';

class CourseDetailCard extends StatefulWidget {
  const CourseDetailCard(
      {super.key, required this.entries, required this.clicked});

  final List<CourseEntry> entries;
  final CourseEntry clicked;

  @override
  State<StatefulWidget> createState() => _CourseDetailCardState();
}

class _CourseDetailCardState extends State<CourseDetailCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.entries.indexOf(widget.clicked);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1 / 4,
            minChildSize: 1 / 4,
            maxChildSize: 1 / 2,
            builder: (context, scrollController) => Stack(
                  children: [
                    PageView.builder(
                        controller: _pageController,
                        itemCount: widget.entries.length,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemBuilder: (context, index) =>
                            _buildPage(widget.entries[index])),
                    if (widget.entries.length > 1)
                      Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _buildDotIndicator(
                                Color(widget.entries[_currentPage].color),
                                widget.entries.length,
                                _currentPage),
                          ))
                  ],
                )),
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
            style: const TextStyle(fontSize: 18),
          )
        ],
      );

  Widget _buildPage(CourseEntry entry) {
    final days = ['一', '二', '三', '四', '五', '六', '日'];
    final finished = entry.checkIfFinished(widget.entries);

    return Container(
      color: Color(entry.color).withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                        Text(
                          entry.courseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${entry.place} • 星期${days[entry.weekday - 1]}第${entry.numberOfDay}节',
                          style: const TextStyle(fontSize: 16),
                        )
                      ],
                    )),
                Expanded(
                  flex: 2,
                  child: Text(
                      finished
                          ? '已结课🎉'
                          : '剩余${entry.getWeeksRemaining(widget.entries)}周',
                      style: TextStyle(
                          color: finished
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
            ...joinPlaceholder(gap: 8, widgets: [
              _buildRow(FAssets.icons.calendarDays,
                  '第${entry.startWeek.padL2}-${entry.endWeek.padL2}周'),
              _buildRow(
                  entry.teacherName.length == 1
                      ? FAssets.icons.user
                      : FAssets.icons.users,
                  entry.teacherName.join('、'))
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(Color color, int count, int currentIndex) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 10 : 8,
          height: currentIndex == index ? 10 : 8,
          decoration: BoxDecoration(
            color: currentIndex == index ? color : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
