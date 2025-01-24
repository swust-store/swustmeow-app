import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:miaomiaoswust/entity/duifene_class.dart';
import 'package:miaomiaoswust/utils/status.dart';
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

        return const StatusContainer(Status.ok);
      } else {
        return const StatusContainer(Status.notAuthorized);
      }
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, e.toString());
    }
  }

  /// 从对分易获取班级列表
  ///
  /// 若中途遇到异常，返回错误信息字符串的状态容器；
  /// 否则正常返回 `List<DuiFenEClass>` 的状态容器。
  Future<StatusContainer<dynamic>> getClassList() async {
    final cookie = await cookieString;
    debugPrint('携带的 Cookie: $cookie');

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
              final instance = DuiFenEClass.fromJson(map);
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
    debugPrint('携带的 Cookie: $cookie');
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
}
