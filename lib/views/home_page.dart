import 'package:flutter/material.dart';
import 'package:swustmeow/components/home/home_announcement.dart';
import 'package:swustmeow/components/home/home_header.dart';
import 'package:swustmeow/components/home/home_news.dart';
import 'package:swustmeow/components/home/home_tool_grid.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/data/global_keys.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/version_service.dart';
import 'package:swustmeow/utils/widget.dart';

import '../components/home/home_ad.dart';
import '../data/values.dart';
import '../services/value_service.dart';

class HomePage extends StatefulWidget {
  final Function() onRefresh;

  const HomePage({super.key, required this.onRefresh});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> _ads = [];

  @override
  void initState() {
    super.initState();
    _ads = GlobalService.serverInfo?.ads ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (!ValueService.checkedUpdate) {
      VersionService.checkUpdate(context);
      ValueService.checkedUpdate = true;
    }

    const padding = 16.0;

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        ValueListenableBuilder(
          valueListenable: ValueService.isCourseLoading,
          builder: (context, isCourseLoading, child) {
            return HomeHeader(
              activities: ValueService.activities,
              containers: !Values.showcaseMode
                  ? ValueService.coursesContainers
                  : ShowcaseValues.coursesContainers,
              currentCourseContainer: !Values.showcaseMode
                  ? ValueService.currentCoursesContainer
                  : ShowcaseValues.coursesContainers.first,
              todayCourses: ValueService.todayCourses,
              nextCourse: ValueService.nextCourse,
              currentCourse: ValueService.currentCourse,
              isLoading: isCourseLoading,
              onRefresh: () async {
                await GlobalService.load(force: true);
                widget.onRefresh();
                setState(() {});
              },
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            children: [
              SizedBox(height: 8),
              buildShowcaseWidget(
                key: GlobalKeys.showcaseToolGridKey,
                title: '工具栏',
                description: '一键直达，快速访问。',
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                child: HomeToolGrid(padding: padding),
              ),
              SizedBox(height: 8),
              ...joinGap(
                gap: 12,
                axis: Axis.vertical,
                widgets: [
                  if (_ads.isNotEmpty) HomeAd(ads: _ads),
                  HomeAnnouncement(),
                  HomeNews(),
                ],
              ),
              SizedBox(height: 90),
            ],
          ),
        ),
      ],
    );
  }
}
