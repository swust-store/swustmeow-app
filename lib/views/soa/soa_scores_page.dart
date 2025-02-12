import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/circular_progress.dart';
import 'package:swustmeow/components/simple_badge.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/soa/score/course_score.dart';
import 'package:swustmeow/entity/soa/score/points_data.dart';
import 'package:swustmeow/entity/soa/score/score_type.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/math.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../data/m_theme.dart';
import '../../services/value_service.dart';
import '../../utils/courses.dart';

class SoaScoresPage extends StatefulWidget {
  const SoaScoresPage({super.key});

  @override
  State<StatefulWidget> createState() => _SoaScoresPageState();
}

class _SoaScoresPageState extends State<SoaScoresPage> {
  Map<ScoreType, List<CourseScore>> _scores = {};
  PointsData? _pointsData;
  bool _isLoading = true;
  static const _maxPoints = 5.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _loadCache();
    if (!Values.showcaseMode) {
      await _loadScores();
      await _loadPoints();
    }
    _refresh(() {
      _isLoading = false;
    });
  }

  Map<ScoreType, List<CourseScore>> _parseScores(List<CourseScore> scores) {
    Map<ScoreType, List<CourseScore>> result = {};
    for (final score in scores) {
      if (result.containsKey(score.scoreType)) {
        result[score.scoreType]!.add(score);
      } else {
        result[score.scoreType] = [score];
      }
    }
    return result;
  }

  void _loadCache() {
    if (Values.showcaseMode) {
      _refresh(() {
        _scores = {
          ScoreType.plan: ShowcaseValues.courseScores
              .map((c) => CourseScore.fromJson(c))
              .toList()
        };
      });
      return;
    }

    final box = BoxService.soaBox;
    List<CourseScore>? cachedScores =
        (box.get('courseScores') as List<dynamic>?)?.cast() ?? [].cast();
    PointsData? cachedPointsData = box.get('pointsData') as PointsData?;
    _refresh(() {
      _scores = _parseScores(cachedScores);
      _pointsData = cachedPointsData;
      _isLoading = false;
    });
  }

  Future<void> _loadScores() async {
    final service = GlobalService.soaService;
    if (service == null) return;

    final result = await service.getScores();
    if (result.status != Status.ok) return;

    _refresh(() {
      _scores = _parseScores((result.value as List<dynamic>).cast());
    });
  }

  Future<void> _loadPoints() async {
    final service = GlobalService.soaService;
    if (service == null) return;

    final result = await service.getPointsData();
    if (result.status != Status.ok) return;

    _refresh(() {
      _pointsData = result.value as PointsData;
    });
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '考试成绩',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          suffixIcons: [
            IconButton(
              onPressed: () async {
                _refresh(() => _isLoading = true);
                await _loadScores();
              },
              icon: FaIcon(
                FontAwesomeIcons.rotateRight,
                color: Colors.white,
                size: 20,
              ),
            )
          ],
        ),
        content: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: MTheme.primary2,
                ),
              )
            : FTabs(
                initialIndex: _scores.isEmpty ? 0 : 1,
                tabs: [
                  FTabEntry(
                    label: AutoSizeText(
                      '学分绩点',
                      maxLines: 1,
                      minFontSize: 8,
                    ),
                    content: _buildCreditsPage(),
                  ),
                  ..._scores.keys.map(
                    (key) {
                      final list = _scores[key]!;
                      final name = ScoreTypeData.of(key).name;
                      return FTabEntry(
                        label: AutoSizeText(
                          name,
                          maxLines: 1,
                          minFontSize: 8,
                        ),
                        content: Expanded(child: _buildList(list)),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCreditsPage() {
    final d = _pointsData;
    final w = MediaQuery.of(context).size.width;
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
      children: joinGap(
        gap: 48,
        axis: Axis.vertical,
        widgets: [
          Row(
            children: joinGap(
              gap: 16,
              axis: Axis.horizontal,
              widgets: [
                Expanded(
                  child: _buildCircularProgress(
                    title: d?.totalCredits?.toString() ?? '???',
                    titleSize: 40,
                    subtitle: '总学分',
                    subtitleSize: 14,
                    maxValue: 0.01,
                    value: d?.totalCredits ?? 1,
                    size: (w - (2 * 32)) / 2,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildCircularProgress(
                      title: d?.requiredCoursesCredits?.toString() ?? '???',
                      titleSize: 40,
                      subtitle: '必修课',
                      subtitleSize: 14,
                      maxValue: 0.01,
                      value: d?.requiredCoursesCredits ?? 1,
                      size: (w - (2 * 32)) / 2,
                      color: Colors.cyanAccent.shade700),
                ),
              ],
            ),
          ),
          Row(
            children: joinGap(
              gap: 16,
              axis: Axis.horizontal,
              widgets: [
                Expanded(
                  child: _buildCircularProgress(
                    title: d?.averagePoints?.toString() ?? '???',
                    titleSize: 28,
                    subtitle: '平均绩点',
                    subtitleSize: 12,
                    maxValue: _maxPoints,
                    value: d?.averagePoints ?? 1,
                    size: (w - (2 * 32)) / 3,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildCircularProgress(
                      title: d?.requiredCoursesPoints?.toString() ?? '???',
                      titleSize: 28,
                      subtitle: '必修课绩点',
                      subtitleSize: 12,
                      maxValue: _maxPoints,
                      value: d?.requiredCoursesPoints ?? 1,
                      size: (w - (2 * 32)) / 3,
                      color: Colors.cyanAccent.shade700),
                ),
                Expanded(
                  child: _buildCircularProgress(
                      title:
                          d?.degreeCoursesPoints?.toString().padRight(5, '0') ??
                              '???',
                      titleSize: 28,
                      subtitle: '学位课绩点',
                      subtitleSize: 12,
                      maxValue: _maxPoints,
                      value: d?.degreeCoursesPoints ?? 1,
                      size: (w - (2 * 32)) / 3,
                      color: Colors.purpleAccent.shade100),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCircularProgress({
    required String title,
    required double titleSize,
    required String subtitle,
    required double subtitleSize,
    required double maxValue,
    required double value,
    required double size,
    required Color color,
  }) {
    return CircularProgress(
      maxValue: maxValue,
      value: value,
      size: size,
      color: color,
      strokeWidth: 6,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: subtitleSize,
                color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<CourseScore> scores) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
      separatorBuilder: (context, index) => SizedBox(height: 16.0),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        return _buildCard(score);
      },
    );
  }

  Widget _buildCard(CourseScore score) {
    final style = TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.black.withValues(alpha: 0.6),
      fontSize: 14,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MTheme.border),
        borderRadius: BorderRadius.circular(MTheme.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (score.courseType != null)
                      SimpleBadge(
                        color: MTheme.primary1,
                        child: Text(
                          score.courseType!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    SizedBox(width: 4.0),
                    Expanded(
                        child: AutoSizeText(
                      score.courseName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: 18,
                      minFontSize: 16,
                    )),
                  ],
                ),
                Text(
                  '课程学分：${score.credit}',
                  style: style,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                double.tryParse(score.formalScore)?.intOrDouble?.splice('分') ??
                    score.formalScore,
                style: TextStyle(
                  color: getCourseScoreColor(score.formalScore),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!score.resitScore.isContentEmpty)
                Text(
                  '补考：${double.tryParse(score.resitScore)?.intOrDouble?.splice('分') ?? score.resitScore}',
                  style: TextStyle(
                    color: getCourseScoreColor(score.resitScore),
                    fontSize: 12,
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}
