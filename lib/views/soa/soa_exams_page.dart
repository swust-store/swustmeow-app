import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/refresh_icon.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/soa/exam/exam_schedule.dart';
import 'package:swustmeow/entity/soa/exam/exam_type.dart';
import 'package:swustmeow/entity/soa/score/course_score.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/math.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/time.dart';

import '../../components/utils/base_page.dart';
import '../../data/m_theme.dart';
import '../../services/boxes/soa_box.dart';
import '../../utils/courses.dart';

class SOAExamsPage extends StatefulWidget {
  const SOAExamsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SOAExamsPageState();
}

class _SOAExamsPageState extends State<SOAExamsPage>
    with SingleTickerProviderStateMixin {
  Map<ExamType, List<ExamSchedule>> _exams = {};
  List<CourseScore> _scores = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _loadCache();
    _loadData();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  void _loadCache() {
    List<ExamSchedule>? exams = !Values.showcaseMode
        ? (SOABox.get('examSchedules') as List<dynamic>?)?.cast()
        : ShowcaseValues.examSchedules
            .map((c) => ExamSchedule.fromJson(c))
            .toList();
    List<CourseScore>? scores = !Values.showcaseMode
        ? (SOABox.get('courseScores') as List<dynamic>?)?.cast()
        : ShowcaseValues.courseScores
            .map((c) => CourseScore.fromJson(c))
            .toList();
    if (exams != null && exams.isNotEmpty) {
      _refresh(() {
        _exams = _parseMap(exams);
        _isLoading = false;
      });
    }
    if (scores != null && scores.isNotEmpty) {
      _refresh(() => _scores = scores);
    }
  }

  Future<void> _loadData() async {
    if (!Values.showcaseMode) await _loadExams();
    if (!Values.showcaseMode) await _loadScores();
    _refresh(() => _isLoading = false);
  }

  Map<ExamType, List<ExamSchedule>> _parseMap(List<ExamSchedule> exams) {
    Map<ExamType, List<ExamSchedule>> result = {};
    for (final exam in exams) {
      final list = result[exam.type];
      if (list == null) result[exam.type] = [];
      result[exam.type]!.add(exam);
    }
    return result;
  }

  Future<void> _loadExams() async {
    final service = GlobalService.soaService;
    if (service == null) return;

    final result = await service.getExams();
    if (result.status != Status.ok) return;

    _refresh(() {
      _exams = _parseMap((result.value as List<dynamic>).cast());
    });
  }

  Future<void> _loadScores() async {
    final service = GlobalService.soaService;
    if (service == null) return;

    final result = await service.getScores();
    if (result.status != Status.ok) return;

    _refresh(() {
      _scores = (result.value as List<dynamic>).cast();
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
    _refreshAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(
        title: '考试',
        suffixIcons: [
          RefreshIcon(
            isRefreshing: _isRefreshing,
            onRefresh: () async {
              if (_isRefreshing || _isLoading) return;
              _refresh(() => _isRefreshing = true);
              _refreshAnimationController.repeat();
              await _loadData();
              _refresh(() {
                _isRefreshing = false;
                _refreshAnimationController.stop();
                _refreshAnimationController.reset();
              });
            },
          )
        ],
      ),
      content: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: MTheme.primary2,
        ),
      );
    }

    if (_exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.calendarXmark,
              size: 60,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
            SizedBox(height: 16),
            Text(
              '这里什么都木有~',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                '当前无考试安排数据，请稍后再查看或点击右上角刷新按钮',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                if (_isRefreshing || _isLoading) return;
                _refresh(() => _isRefreshing = true);
                _refreshAnimationController.repeat();
                await _loadData();
                _refresh(() {
                  _isRefreshing = false;
                  _refreshAnimationController.stop();
                  _refreshAnimationController.reset();
                });
              },
              icon: FaIcon(
                FontAwesomeIcons.arrowsRotate,
                size: 16,
                color: MTheme.primary2,
              ),
              label: Text('刷新数据'),
              style: OutlinedButton.styleFrom(
                foregroundColor: MTheme.primary2,
              ),
            ),
          ],
        ),
      );
    }

    return FTabs(
      tabs: _exams.entries.map(
        (entry) {
          final name = switch (entry.key) {
            ExamType.finalExam => '期末考试',
            ExamType.midExam => '期中考试',
            ExamType.resitExam => '补考',
          };
          final exams = entry.value;
          final now = DateTime.now();
          final unfinished = exams.where((e) => e.isActive).toList()
            ..sort((a, b) {
              final aDiff = a.date - now;
              final bDiff = b.date - now;
              return aDiff > bDiff
                  ? 1
                  : aDiff == bDiff
                      ? 0
                      : -1;
            });
          final finished = exams.where((e) => !e.isActive).toList()
            ..sort((a, b) {
              final aDiff = now - a.date;
              final bDiff = now - b.date;
              return aDiff > bDiff
                  ? 1
                  : aDiff == bDiff
                      ? 0
                      : -1;
            });
          final result = [...unfinished, ...finished];

          return FTabEntry(
            label: Text(name),
            content: Expanded(child: _buildList(result)),
          );
        },
      ).toList(),
    );
  }

  Widget _buildList(List<ExamSchedule> exams) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 32.0),
      separatorBuilder: (context, index) => SizedBox(height: 8.0),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        final score = _scores
            .where((s) => s.courseName.trim() == exam.courseName.trim())
            .firstOrNull;
        final time = Values.courseTableTimes[exam.numberOfDay - 1];
        final style = TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black.withValues(alpha: 0.6),
          fontSize: 14,
        );
        final numbers = ['一', '二', '三', '四', '五', '六', '日'];

        return Opacity(
          opacity: exam.isActive ? 1 : 0.5,
          child: Container(
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
                      Text(
                        exam.courseName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '日期：${exam.date.year}-${exam.date.month.padL2}-${exam.date.day.padL2}',
                        style: style,
                      ),
                      Text(
                        '场次：周${numbers[exam.weekday - 1]}第${numbers[exam.numberOfDay - 1]}场 ${time.split('\n').join('-')}',
                        style: style,
                      ),
                      Text(
                        '地点：${exam.place}',
                        style: style,
                      ),
                      Text(
                        '教室：${exam.classroom}',
                        style: style,
                      ),
                      Text(
                        '座次：${exam.seatNo}',
                        style: style,
                      ),
                    ],
                  ),
                ),
                if (score != null && !exam.isActive)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '已结束',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
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
          ),
        );
      },
    );
  }
}
