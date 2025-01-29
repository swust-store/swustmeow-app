import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:miaomiaoswust/entity/course/course_entry.dart';
import 'package:miaomiaoswust/entity/course/course_type.dart';
import 'package:miaomiaoswust/entity/course/courses_container.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:path_provider/path_provider.dart';

class SOAApiService {
  final _dio = Dio();
  late PersistCookieJar _cookieJar;
  static const _expCourseHost = 'https://sjjx.dean.swust.edu.cn';

  Future<void> init() async {
    await _initializeCookieJar();
    _dio.options.headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0',
      'Accept-Language':
          'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
      'Content-Type': 'application/json'
    };
    _dio.options.validateStatus = (status) => true; // 忽略证书验证
    _dio.options.sendTimeout = const Duration(seconds: 10);

    // 修复 `CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate` 的问题
    // https://stackoverflow.com/a/60890158/15809316
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
        HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
  }

  Future<void> _initializeCookieJar() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookiesPath = '${appDocDir.path}/cookies';
    _cookieJar = PersistCookieJar(storage: FileStorage(cookiesPath));
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<List<Cookie>> get cookies async =>
      await _cookieJar.loadForRequest(Uri.parse(_expCourseHost)); // TODO 优化

  Future<String> get cookieString async =>
      (await cookies).map((c) => '${c.name}=${c.value}').join('; ');

  /// 获取普通课和选课课程表
  ///
  /// 若获取成功，返回一个 [CoursesContainer] 的列表的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getCourseTables(String tgc) async {
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
        final d0 = days[0];

        // 去掉第一列的节数
        if (d0.contents.length == 1 && d0.contents[0].text.startsWith('第')) {
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
                teacherName: teacherName,
                startWeek: startWeek,
                endWeek: endWeek,
                place: place,
                weekday: j + 1,
                numberOfDay: i + 1));
          }
        }
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
}
