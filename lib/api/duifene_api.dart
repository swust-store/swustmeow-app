import 'dart:convert';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_course.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_homework.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_sign_container.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_test.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:miaomiaoswust/utils/text.dart';
import 'package:path_provider/path_provider.dart';

class DuiFenEApiService {
  final _dio = Dio();
  final _host = 'https://www.duifene.com';
  late PersistCookieJar _cookieJar;

  Future<void> init() async {
    await _initializeCookieJar();
    _dio.options.headers = {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.40(0x1800282a) NetType/WIFI Language/zh_CN',
    };
    _dio.options.validateStatus = (status) => true; // 忽略证书验证
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  Future<void> _initializeCookieJar() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookiesPath = '${appDocDir.path}/cookies';
    _cookieJar = PersistCookieJar(storage: FileStorage(cookiesPath));
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<List<Cookie>> get cookies async =>
      await _cookieJar.loadForRequest(Uri.parse(_host));

  Future<String> get cookieString async =>
      (await cookies).map((c) => '${c.name}=${c.value}').join('; ');

  /// 登录到对分易
  ///
  /// 只会返回一个是否登录成功的状态。
  Future<StatusContainer> login(String username, String password) async {
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Referer': '$_host/AppGate.aspx',
    };
    final params = 'action=loginmb&loginname=$username&password=$password';

    try {
      await _cookieJar.deleteAll();
      await _dio.get(_host);

      final response = await _dio.post(
        '$_host/AppCode/LoginInfo.ashx',
        data: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final cookies1 =
            (response.requestOptions.headers['cookie'] as String?)?.split('; ');
        final cookies2 =
            response.headers['set-cookie']?.map((c) => c.split('; ').first);
        if (cookies1 == null && cookies2 == null) {
          return const StatusContainer(Status.fail);
        }

        final cookies3 = (cookies2 ?? cookies1)!
            .map((c) => Cookie.fromSetCookieValue(c))
            .toList();
        await _cookieJar.saveFromResponse(Uri.parse(_host), cookies3);

        final cookie = await cookieString;
        debugPrint('获取到的 Cookie：$cookie');

        return const StatusContainer(Status.ok);
      } else {
        return const StatusContainer(Status.notAuthorized);
      }
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, e.toString());
    }
  }

  /// 获取课程名称列表
  ///
  /// 若中途遇到异常，返回错误信息字符串的状态容器；
  /// 否则正常返回 [DuiFenECourse] 的列表的状态容器。
  Future<StatusContainer<dynamic>> getCourseList() async {
    final cookie = await cookieString;
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Referer': '$_host/_UserCenter/PC/CenterStudent.aspx',
      'Cookie': cookie
    };
    const params = 'action=getstudentcourse&classtypeid=2';

    try {
      final response = await _dio.post(
        '$_host/_UserCenter/CourseInfo.ashx',
        data: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final info = json.decode(response.data);

        if (info != null) {
          if (info is List) {
            final result = [];
            for (Map<String, dynamic> map in info) {
              final instance = DuiFenECourse.fromJson(map);
              result.add(instance);
            }
            return StatusContainer(Status.ok, result);
          } else {
            await _cookieJar.deleteAll();
            return StatusContainer(Status.fail, info['msgbox']);
          }
        }
      }
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, e.toString());
    }

    return const StatusContainer(Status.fail);
  }

  /// 获取是否已登录状态
  Future<bool> getIsLogin() async {
    final cookie = await cookieString;
    final headers = {
      'Referer': 'https://www.duifene.com/_UserCenter/PC/CenterStudent.aspx',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Cookie': cookie
    };

    final response = await _dio.get('$_host/AppCode/LoginInfo.ashx',
        data: 'Action=checklogin', options: Options(headers: headers));

    Map<String, dynamic> data =
        (json.decode(response.data) as Map<dynamic, dynamic>).cast();
    if (response.statusCode == 200) {
      if (data['msg'] == '1') {
        return true;
      } else {
        await _cookieJar.deleteAll();
        return false;
      }
    }

    return false;
  }

  /// 转到签到页面
  ///
  /// 返回一个是否成功的值。
  Future<bool> _goSign(DuiFenECourse course) async {
    final cookie = await cookieString;
    final headers = {
      'Referer': 'https://www.duifene.com/_UserCenter/MB/index.aspx',
      'Cookie': cookie
    };

    final response = await _dio.get(
        '$_host/_UserCenter/MB/Module.aspx?data=${course.courseId}',
        options: Options(headers: headers));
    return response.statusCode == 200;
  }

  /// 检查是否有签到，返回一个签到信息容器
  Future<StatusContainer<DuiFenESignContainer>> checkSignIn(
      DuiFenECourse course) async {
    final flag = await _goSign(course);
    if (!flag) return const StatusContainer(Status.notAuthorized);

    final cookie = await cookieString;
    final headers = {
      'Cookie': cookie,
    };

    final response = await _dio.get(
        '$_host/_CheckIn/MB/TeachCheckIn.aspx?classid=${course.tClassId}&temps=0&checktype=1&isrefresh=0&timeinterval=0&roomid=0&match=',
        options: Options(headers: headers));

    String text = response.data as String;
    if (response.statusCode != 200) {
      return const StatusContainer(Status.notAuthorized);
    }

    if (!text.contains('HFCheckCodeKey')) {
      return const StatusContainer(Status.fail);
    }

    final soup = BeautifulSoup(text);
    final signCode =
        soup.find('*', id: 'HFCheckCodeKey')?.getAttrValue('value');
    final seconds = soup.find('*', id: 'HFSeconds')?.getAttrValue('value');
    final checkType = soup.find('*', id: 'HFChecktype')?.getAttrValue('value');
    final checkInId = soup.find('*', id: 'HFCheckInID')?.getAttrValue('value');
    final classId = soup.find('*', id: 'HFClassID')?.getAttrValue('value');

    if (classId?.contains(course.tClassId) != true) {
      return const StatusContainer(Status.fail);
    }

    if (checkInId == null || signCode == null || seconds == null) {
      return const StatusContainer(Status.fail);
    }

    return StatusContainer(
        Status.ok,
        DuiFenESignContainer(
            id: checkInId,
            signCode: signCode,
            secondsRemaining: int.tryParse(seconds) ?? 0));
  }

  /// 获取用户 ID
  ///
  /// 返回用户 ID 的字符串的状态容器。
  Future<StatusContainer<String>> getUserId() async {
    final cookie = await cookieString;
    final headers = {'Cookie': cookie};

    final response = await _dio.get('$_host/_UserCenter/MB/index.aspx',
        options: Options(headers: headers));
    if (response.statusCode != 200) {
      return const StatusContainer(Status.notAuthorized);
    }

    final soup = BeautifulSoup(response.data as String);
    final id = soup.find('*', id: 'hidUID')?.getAttrValue('value');
    if (id == null) return const StatusContainer(Status.notAuthorized);

    return StatusContainer(Status.ok, id);
  }

  /// 签到码签到
  ///
  /// 返回是否签到成功的值。
  Future<bool> signInWithSignCode(String signCode) async {
    if (signCode.length != 4) return false;

    final userIdContainer = await getUserId();
    if (userIdContainer.status != Status.ok || userIdContainer.value == null) {
      return false;
    }

    final cookie = await cookieString;
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Referer':
          'https://www.duifene.com/_CheckIn/MB/CheckInStudent.aspx?moduleid=16&pasd=',
      'Cookie': cookie,
    };
    final params =
        'action=studentcheckin&studentid=${userIdContainer.value}&checkincode=$signCode';

    final response = await _dio.post('$_host/_CheckIn/CheckIn.ashx',
        data: params, options: Options(headers: headers));
    return response.statusCode == 200;
  }

  /// 获取在线练习
  ///
  /// 返回一个带有 [DuiFenETest] 的列表的状态容器。
  Future<StatusContainer<List<DuiFenETest>>> getTests(
      DuiFenECourse course) async {
    final cookie = await cookieString;
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Referer':
          'https://www.duifene.com/_Paper/MB/StudentPaperList.aspx?moduleid=19&pasd=',
      'Cookie': cookie,
    };
    final params = 'Action=datalist&CourseID=${course.courseId}';

    final response = await _dio.post('$_host/_Paper/StudentPaper.ashx',
        data: params, options: Options(headers: headers));
    if (response.statusCode != 200) {
      return const StatusContainer(Status.notAuthorized);
    }

    final data = json.decode(response.data as String) as Map<String, dynamic>;
    List<dynamic>? j = data['jsontb1'] as List<dynamic>?;
    if (j == null) return const StatusContainer(Status.fail);

    List<Map<String, dynamic>> testList = j.cast();
    final result = testList.map((json) {
      final myDone = (json['MyDoneDate'] as String).emptyThenNull;
      return DuiFenETest(
        course: course,
        name: json['Name'],
        createTime: DateTime.parse(json['CreateDate']),
        beginTime: DateTime.parse(json['BeginDate']),
        endTime: DateTime.parse(json['EndDate']),
        submitTime: myDone != null ? DateTime.parse(myDone) : null,
        limitMinutes: int.parse(json['LimitTime']),
        creatorName: json['CreateName'],
        score: double.parse(json['MyScore']).toInt(),
        finished: json['MyStatus'] == '1',
        overdue: json['OverDue'] == '1',
      );
    }).toList();

    return StatusContainer(Status.ok, result);
  }

  /// 获取所有作业
  ///
  /// 返回一个带有 [DuiFenEHomework] 的列表的状态容器。
  Future<StatusContainer<List<DuiFenEHomework>>> getHomeworks(
      DuiFenECourse course) async {
    final cookie = await cookieString;
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Referer':
          'https://www.duifene.com/_HomeWork/MB/StudentHomeWork.aspx?moduleid=12&pasd=',
      'Cookie': cookie,
    };
    final params =
        'action=gethomeworklist&courseid=${course.courseId}&classtypeid=2&classid=${course.tClassId}&mathradom=';

    final response = await _dio.post('$_host/_HomeWork/HomeWorkInfo.ashx',
        data: params, options: Options(headers: headers));
    if (response.statusCode != 200) {
      return const StatusContainer(Status.notAuthorized);
    }

    final data = json.decode(response.data as String) as List<dynamic>;
    List<Map<String, dynamic>> list = data.cast();

    final result = list.map((json) {
      return DuiFenEHomework(
          name: json['HWName'],
          endDate:
              DateTime.parse((json['EndDate'] as String).replaceAll('/', '-')),
          finish: json['IsSubmit'] == '1',
          overdue: json['OverDue'] == '1');
    }).toList();

    return StatusContainer(Status.ok, result);
  }
}
