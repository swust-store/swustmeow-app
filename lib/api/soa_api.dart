import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:gbk_codec/gbk_codec.dart';
import 'package:swustmeow/api/swuststore_api.dart';
import 'package:swustmeow/entity/soa/exam/exam_schedule.dart';
import 'package:swustmeow/entity/soa/exam/exam_type.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_options.dart';
import 'package:swustmeow/entity/soa/course/optional_course.dart';
import 'package:swustmeow/entity/soa/course/optional_task_type.dart';
import 'package:swustmeow/entity/soa/course/optional_course_type.dart';
import 'package:swustmeow/entity/soa/score/course_score.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:path_provider/path_provider.dart';

import '../entity/soa/course/course_entry.dart';
import '../entity/soa/course/course_type.dart';
import '../entity/soa/course/courses_container.dart';
import '../entity/soa/leave/daily_leave_display.dart';

class SOAApiService {
  final _dio = Dio();
  static const ua =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0';
  late PersistCookieJar _cookieJar;
  ResponseDecoder gbkDecoder =
      (r, _, __) => gbk_bytes.decode(r); // 处理 GB2312/GBK 变为 UTF-8

  Future<void> init() async {
    await _initializeCookieJar();
    _dio.options.headers = {
      'User-Agent': ua,
      'Accept-Language':
          'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
      'Content-Type': 'application/json'
    };
    _dio.options.validateStatus = (status) => true; // 忽略证书验证
    _dio.options.sendTimeout = const Duration(seconds: 10);

    // 修复 `CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate` 的问题
    // https://stackoverflow.com/a/60890158/15809316
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () => HttpClient()..badCertificateCallback = (cert, host, port) => true;
  }

  Future<void> _initializeCookieJar() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookiesPath = '${appDocDir.path}/cookies';
    _cookieJar = PersistCookieJar(storage: FileStorage(cookiesPath));
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<List<Cookie>> getCookies(Uri uri) async {
    return await _cookieJar.loadForRequest(uri);
  }

  Future<String> getCookiesString(Uri uri) async {
    final list = await getCookies(uri);
    return list.map((c) => '${c.name}=${c.value}').join('; ');
  }

  /// 登录到课表系统
  ///
  /// 返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<String>> loginToMatrix(String tgc) async {
    final matrixAuthUrl =
        'http://cas.swust.edu.cn/authserver/login?service=https://matrix.dean.swust.edu.cn/acadmicManager/index.cfm?event=studentPortal:DEFAULT_EVENT';

    final headers = {
      'Cookie': 'TGC=$tgc; aexpsid=ED40D42341EAE10005B94BD58053D107.node1'
    };

    final authResp = await _dio.get(matrixAuthUrl,
        options: Options(headers: headers, followRedirects: false));

    if (authResp.statusCode != 302) {
      return const StatusContainer(Status.notAuthorized);
    }

    final loc = authResp.headers['Location']?.first;
    if (loc == null) return const StatusContainer(Status.notAuthorized);

    final loginResp = await _dio.get(loc, options: Options(headers: headers));
    final loginHtml = loginResp.data as String;
    final errorMatched =
        RegExp(r"<div class='_err'>(\d*?)</div>").firstMatch(loginHtml);
    if (errorMatched != null) {
      final msg = RegExp(r"<div class='_1'>(.*?)</div>")
              .firstMatch(loginHtml)
              ?.group(1) ??
          '';
      final desc = RegExp(r"<div class='_2'>(.*?)</div>")
              .firstMatch(loginHtml)
              ?.group(1) ??
          '';
      return StatusContainer(Status.fail, '教务系统：$msg $desc');
    }

    return StatusContainer(Status.ok);
  }

  /// 获取普通课和选课课程表
  ///
  /// 若获取成功，返回一个 [CoursesContainer] 的列表的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getCourseTables(String tgc) async {
    final r = await loginToMatrix(tgc);
    if (r.status != Status.ok) return r;

    Future<CoursesContainer?> getCourseFrom(String url, CourseType type) async {
      final courseResp = await _dio.get(url);
      final courseHtml = courseResp.data as String;

      final termRegex = RegExp(r'<h3>(\d+-\d+-\d) 学期 个人课表</h3>');
      final term = termRegex.firstMatch(courseHtml)?.group(1);

      if (term == null) return null;

      final [startYear, endYear, t] =
          term.split('-').map((c) => int.parse(c)).toList();
      final trueTerm = '$startYear-$endYear-${t == 1 ? '上' : '下'}';

      List<CourseEntry> res = [];
      final soup = BeautifulSoup(courseHtml);
      final table = soup.find('table', class_: 'UICourseTable');
      final sections = table?.find('tbody')?.findAll('tr');
      if (table == null || sections == null) {
        return null;
      }

      for (int i = 0; i < sections.length; i++) {
        var days = sections[i].findAll('td').sublist(1);

        // 去掉第一列的节数
        if (days[0].text.startsWith('第')) {
          days = days.sublist(1);
        }

        for (int j = 0; j < days.length; j++) {
          final day = days[j];
          for (final lecture in day.findAll('div', class_: 'lecture')) {
            final courseName = lecture.find('span', class_: 'course')!.text;
            final teachers = lecture.find('span', class_: 'teacher')!.text;
            final teacherName = teachers.split(RegExp(r'[\s/,，]+'));
            final week = lecture.find('span', class_: 'week')!.text;
            final [startWeek, endWeek] =
                week.split('(')[0].split('-').map((c) => int.parse(c)).toList();
            final place = lecture.find('span', class_: 'place')!.text;
            res.add(CourseEntry(
                courseName: courseName,
                displayName: courseName,
                teacherName: teacherName,
                startWeek: startWeek,
                endWeek: endWeek,
                place: place,
                weekday: j + 1,
                numberOfDay: i + 1));
          }
        }
      }

      final exp = await getExperimentCourseEntries(tgc, term);
      if (exp.status == Status.ok && exp.value != null) {
        List<CourseEntry> r = (exp.value! as List<dynamic>).cast();
        res.addAll(r);
      }

      return CoursesContainer(type: type, term: trueTerm, entries: res);
    }

    final normalCourse = await getCourseFrom(
        'https://matrix.dean.swust.edu.cn/acadmicManager/index.cfm?event=studentPortal:courseTable',
        CourseType.normal);
    final optionalCourse = await getCourseFrom(
        'https://matrix.dean.swust.edu.cn/acadmicManager/index.cfm?event=chooseCourse:courseTable',
        CourseType.optional);

    final result = <CoursesContainer>[];

    if (normalCourse != null) result.add(normalCourse);
    if (optionalCourse != null) result.add(optionalCourse);

    return StatusContainer(Status.ok, result);
  }

  /// 根据类别获取选课的课程列表
  ///
  /// 若获取成功，返回一个 [OptionalCourse] 的列表的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getOptionalCourses(
      String tgc, OptionalTaskType taskType) async {
    final r = await loginToMatrix(tgc);
    if (r.status != Status.ok) return r;

    final response = await _dio.get(
        'https://matrix.dean.swust.edu.cn/acadmicManager/index.cfm?event=chooseCourse:${taskType.type}&CT=2');
    final soup = BeautifulSoup(response.data as String);

    final coursesList = soup.findAll('div', class_: 'courseShow');
    final result = <OptionalCourse>[];
    for (final element in coursesList) {
      final title = element.find('div', class_: 'title')!;
      final cid = title.find('a', class_: 'trigger')!.getAttrValue('cid')!;
      final name = title.find('span', class_: 'name')!.text;
      final credit = title.find('span', class_: 'numeric')!.text;
      final type = title.find('span', class_: 'type')!.text;
      result.add(OptionalCourse(
          cid: cid,
          name: name,
          credit: double.tryParse(credit) ?? 0.0,
          taskType: taskType,
          courseType: switch (type) {
            '网络通识课' => OptionalCourseType.internetGeneralCourse,
            '素质选修课' => OptionalCourseType.qualityOptionalCourse,
            _ => OptionalCourseType.unknown
          }));
    }

    return StatusContainer(Status.ok, result);
  }

  /// 获取所有的考试
  ///
  /// 若获取成功，返回一个 [ExamSchedule] 的列表的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getExams(String tgc) async {
    final r = await loginToMatrix(tgc);
    if (r.status != Status.ok) return r;

    final response = await _dio.get(
        'https://matrix.dean.swust.edu.cn/acadmicManager/index.cfm?event=studentPortal:examTable');
    final soup = BeautifulSoup(response.data as String);

    List<ExamSchedule> result = [];
    final numbers = {'一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '日': 7};

    List<ExamSchedule> get(String id, ExamType type) {
      final div = soup.find('div', id: id);
      final table = div?.find('table');
      if (div == null || table == null) return [];
      final trs = table.findAll('tr', class_: 'editRows');
      List<ExamSchedule> r = [];
      for (final tr in trs) {
        final tds = tr.findAll('td');
        final courseName = tds[1].text;
        final weekNum = int.parse(tds[2].find('span')!.text);
        final orderChars = tds[3].text.characters.toList();
        final weekday = numbers[orderChars[1]]!;
        final numberOfDay = numbers[orderChars[3]]!;
        final date =
            DateTime.parse(tds[4].find('span')!.text.replaceAll('/', '-'));
        final classroom = tds[6].text;
        final seatNo = int.parse(tds[7].text);
        final place = tds[8].text;
        r.add(ExamSchedule(
          type: type,
          courseName: courseName,
          weekNum: weekNum,
          numberOfDay: numberOfDay,
          weekday: weekday,
          date: date,
          place: place,
          classroom: classroom,
          seatNo: seatNo,
        ));
      }
      return r;
    }

    result.addAll(get('finalExamTable', ExamType.finalExam));
    result.addAll(get('midExamTable', ExamType.midExam));
    result.addAll(get('resitExamTable', ExamType.resitExam));
    return StatusContainer(Status.ok, result);
  }

  /// 获取所有的考试成绩
  ///
  /// 若获取成功，返回一个 [CourseScore] 的列表的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getScores(String tgc) async {
    final r = await loginToMatrix(tgc);
    if (r.status != Status.ok) return r;

    final response = await _dio.get(
        'https://matrix.dean.swust.edu.cn/acadmicManager/index.cfm?event=studentProfile:courseMark');
    final soup = BeautifulSoup(response.data as String);

    List<CourseScore> result = [];

    List<CourseScore> get(String id) {
      final div = soup.find('div', id: id);
      final table = div?.find('table');
      if (div == null || table == null) return [];
      final trs = table.findAll('tr', class_: 'cellBorder');
      List<CourseScore> r = [];
      for (final tr in trs.sublist(2)) {
        final tds = tr.findAll('td');
        final courseName = tds[0].text;
        final courseId = tds[1].find('span')!.text;
        final credit = double.parse(tds[2].find('span')!.text);
        final courseType = tds[3].text;
        final formalScore = tds[4].find('span')?.text ?? tds[4].text;
        final resitScore = tds[5].find('span')?.text ?? tds[5].text;
        final points = double.parse(tds[6].find('span')!.text);
        r.add(CourseScore(
          courseName: courseName,
          courseId: courseId,
          credit: credit,
          courseType: courseType,
          formalScore: formalScore,
          resitScore: resitScore,
          points: points,
        ));
      }
      return r;
    }

    result.addAll(get('Plan')); // TODO 解析其他分类的成绩
    return StatusContainer(Status.ok, result);
  }

  /// 登录到学工管理系统
  ///
  /// 返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<String>> loginToXSC(String tgc) async {
    final xscAuthUrl =
        'http://cas.swust.edu.cn/authserver/login?service=http://xsc.swust.edu.cn/JC/OneLogin.aspx';
    final headers = {
      'Cookie': 'TGC=$tgc; aexpsid=ED40D42341EAE10005B94BD58053D107.node1'
    };

    final resp1 = await _dio.get(xscAuthUrl,
        options: Options(headers: headers, followRedirects: false));
    if (resp1.statusCode != 302) {
      return const StatusContainer(Status.notAuthorized);
    }
    final loc1 = resp1.headers['Location']?.first;
    if (loc1 == null) return const StatusContainer(Status.notAuthorized);

    final resp2 =
        await _dio.get(loc1, options: Options(followRedirects: false));
    if (resp2.statusCode != 302) {
      return const StatusContainer(Status.notAuthorized);
    }
    final loc2 = resp2.headers['Location']?.first;
    if (loc2 == null) return const StatusContainer(Status.notAuthorized);

    final resp3 = await _dio.get(loc2);
    final hrefRegex = RegExp(r"<script>window.location.href='(.*)';</script>");
    final loc3 = hrefRegex.firstMatch(resp3.data)?.group(1);
    if (loc3 == null) return StatusContainer(Status.ok);

    await _dio.get(loc3);
    return StatusContainer(Status.ok);
  }

  /// 获取已有日常请假的信息
  ///
  /// 若获取成功，返回一个 [DailyLeaveOptions] 的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getDailyLeaveInformation(
      String tgc, String id) async {
    final r = await loginToXSC(tgc);
    if (r.status != Status.ok) return r;

    final url =
        'http://xsc.swust.edu.cn/Sys/SystemForm/Leave/StuAllLeaveManage_Edit.aspx';
    final response = await _dio.get(url,
        queryParameters: {'Status': 'Edit', 'Id': id},
        options: Options(responseDecoder: gbkDecoder));

    return StatusContainer(
        Status.ok, DailyLeaveOptions.fromHTML(response.data as String));
  }

  /// 获取所有的日常请假
  ///
  /// 若获取成功，返回一个 [DailyLeaveDisplay] 的列表的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getDailyLeaves(String tgc) async {
    final r = await loginToXSC(tgc);
    if (r.status != Status.ok) return r;

    final url =
        'http://xsc.swust.edu.cn/Sys/SystemForm/Leave/StuAllLeaveManage.aspx';
    final response = await _dio.get(url,
        options: Options(
          responseDecoder: gbkDecoder,
        ));

    final soup = BeautifulSoup(response.data as String);
    final gridView = soup.find('table', id: 'GridView1');

    if (gridView == null) return StatusContainer(Status.fail, '加载失败');

    final tbody = gridView.find('tbody')!;
    final trs = tbody.findAll('tr').sublist(1);

    final result = <DailyLeaveDisplay>[];
    for (final row in trs) {
      final tds = row.findAll('td');
      final editUrl = tds[1].find('a')!.getAttrValue('href');
      if (editUrl == null) continue;
      final idRegex = RegExp(r'Id=([0-9]+)');
      final id = idRegex.firstMatch(editUrl)?.group(1);
      if (id == null) continue;

      final time = tds[2].text;
      final type = tds[3].text;
      final address = tds[4].text;
      final status = tds[5].text;
      final leaveStatus = tds[6].text;
      result.add(
        DailyLeaveDisplay(
          id: id,
          time: time,
          type: type,
          address: address,
          status: status,
          leaveStatus: leaveStatus,
        ),
      );
    }

    return StatusContainer(Status.ok, result);
  }
}
