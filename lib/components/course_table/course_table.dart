import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/course_table/course_card.dart';
import 'package:swustmeow/components/course_table/course_detail_card.dart';
import 'package:swustmeow/components/course_table/header_row.dart';
import 'package:swustmeow/components/course_table/time_column.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:swustmeow/components/utils/empty.dart';

import '../../data/values.dart';
import '../../entity/soa/course/courses_container.dart';
import '../../services/global_service.dart';
import '../../utils/courses.dart';

class CourseTable extends StatefulWidget {
  const CourseTable({
    super.key,
    required this.container,
    required this.isLoading,
  });

  final CoursesContainer container;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => _CourseTableState();
}

class _CourseTableState extends State<CourseTable> {
  String? _term;
  int? _all;
  PageController? _pageController;
  late int _initialPage;
  final _pageKey = GlobalKey();
  double? _pageHeight;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildTimeColumn() {
    return Column(
      children: List.generate(
        6,
        (index) => Expanded(
          child: TimeColumn(
            number: index + 1,
            time: Values.courseTableTimes[index],
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(int columnIndex, int pageIndex) {
    final w = pageIndex + 1;

    return Stack(
      children: [
        ...List.generate(
          6,
          (indexOfDay) {
            final matched = widget.container.entries
                .where((entry) =>
                    entry.numberOfDay == indexOfDay + 1 &&
                    entry.weekday == columnIndex + 1)
                .toList()
              ..sort((a, b) => a.endWeek.compareTo(b.endWeek));
            final actives = matched
                .where((e) => w >= e.startWeek && w <= e.endWeek)
                .toList();
            final display =
                actives.isNotEmpty ? actives.first : matched.lastOrNull;

            if (display == null || _pageHeight == null) return const Empty();

            final nod = display.numberOfDay;
            final startSection = display.startSection;
            final endSection = display.endSection;
            final supportSection = startSection != null && endSection != null;
            final diff = supportSection ? (endSection - startSection) : 0;
            final perHeight = (_pageHeight! - (6 - 1) * 1) / 6;
            final perSection = perHeight / 2;
            final height = supportSection ? (diff + 1) * perSection : perHeight;
            final dy = supportSection
                ? (startSection - 1) * perSection
                : (nod - 1) * perSection;

            return Transform.translate(
              offset: Offset(0, dy),
              child: SizedBox(
                height: height,
                child: FTappable(
                  onPress: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CourseDetailCard(
                        entries: matched,
                        term: _term!,
                        clicked: display,
                      ),
                    );
                  },
                  child: CourseCard(
                    entry: display,
                    active: actives.isNotEmpty,
                    isMore: matched.length > 1,
                    isConflict: actives.length > 1,
                  ),
                ),
              ),
            );
          },
        ),
        Column(children: List.generate(6, (_) => const Empty())),
      ],
    );
  }

  Widget _buildPage(int pageIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageHeight != null) return;
      final c = _pageKey.currentContext?.findRenderObject() as RenderBox?;
      setState(() => _pageHeight ??= c?.size.height);
    });

    return Padding(
      padding: EdgeInsets.only(right: 1),
      child: Row(
        key: _pageHeight == null ? _pageKey : null,
        children: [
          _buildTimeColumn(),
          ...List.generate(
            7,
            (index) => Expanded(
              // child: Skeletonizer(
              //   enabled: widget.isLoading,
              //   child: _buildColumn(index, pageIndex),
              // ),
              child: _buildColumn(index, pageIndex),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _term = widget.container.term;
    var (_, w) = getWeekNum(_term!, DateTime.now());
    w = w > 0 ? w : 1;
    final (_, _, all) = GlobalService.termDates.value[_term!]?.value ??
        Values.getFallbackTermDates(_term!);
    _all = all;
    _initialPage = (w > all ? all : w) - 1;
    _pageController =
        PageController(initialPage: _initialPage, keepPage: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController!.jumpToPage(_initialPage);
    });

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          ListenableBuilder(
              listenable: _pageController!,
              builder: (context, _) {
                var page = _pageController!.positions.isEmpty ||
                        _pageController!.page == null
                    ? _initialPage
                    : _pageController!.page ?? _initialPage;
                page = page > 0 ? page : 0;
                final result = (page - page.toInt()).abs() >= 0.5
                    ? page.ceil()
                    : page.floor();
                return HeaderRow(term: _term!, weekNum: result + 1);
              }),
          Expanded(
            flex: 1,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _all,
              itemBuilder: (context, pageIndex) => _buildPage(pageIndex),
            ),
          )
        ],
      ),
    );
  }
}
