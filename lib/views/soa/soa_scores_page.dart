import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/simple_badge.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/soa/score/course_score.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/math.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/text.dart';

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
  List<CourseScore> _scores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCache();
    if (!Values.showcaseMode) _loadScores();
  }

  void _loadCache() {
    if (Values.showcaseMode) {
      _refresh(() {
        _scores = ShowcaseValues.courseScores
            .map((c) => CourseScore.fromJson(c))
            .toList();
        _isLoading = false;
      });
      return;
    }

    final box = BoxService.soaBox;
    List<CourseScore>? scores =
        (box.get('courseScores') as List<dynamic>?)?.cast();
    if (scores != null && scores.isNotEmpty) {
      _refresh(() {
        _scores = scores;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadScores() async {
    final service = GlobalService.soaService;
    if (service == null) return;

    final result = await service.getScores();
    if (result.status != Status.ok) return;

    _refresh(() {
      _scores = (result.value as List<dynamic>).cast();
      _isLoading = false;
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
          content: _buildBody()),
    );
  }

  Widget _buildBody() {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
            color: MTheme.primary2,
          ))
        : ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
            separatorBuilder: (context, index) => SizedBox(height: 16.0),
            itemCount: _scores.length,
            itemBuilder: (context, index) {
              final score = _scores[index];
              final style = TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withValues(alpha: 0.6),
                  fontSize: 14);

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
                              SimpleBadge(
                                color: MTheme.primary1,
                                child: Text(
                                  score.courseType,
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
                          double.tryParse(score.formalScore)
                                  ?.intOrDouble
                                  ?.splice('分') ??
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
            },
          );
  }
}
