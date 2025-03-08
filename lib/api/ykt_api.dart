import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swustmeow/api/soa_api.dart';
import 'package:swustmeow/entity/ykt/ykt_auth_token.dart';
import 'package:swustmeow/entity/ykt/ykt_card.dart';
import 'package:swustmeow/entity/ykt/ykt_card_account_info.dart';
import 'package:swustmeow/services/boxes/ykt_box.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/status.dart';

import '../entity/ykt/ykt_bill.dart';

class YKTApiService {
  final _dio = Dio();
  static const _host = 'http://ykt.swust.edu.cn';
  static const ua =
      'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36';
  static const defaultHeaders = {
    'User-Agent': ua,
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate, br',
  };
  late PersistCookieJar _cookieJar;

  Future<void> init() async {
    await _initializeCookieJar();
    _dio.options.headers = defaultHeaders;
    _dio.options.validateStatus = (status) => true; // 忽略证书验证
    _dio.options.sendTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.connectTimeout = const Duration(seconds: 10);

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

  Future<void> deleteCookies() async {
    await _cookieJar.deleteAll();
  }

  /// 登录到一卡通服务
  ///
  /// 成功时返回 ticket 字符串，失败时返回错误信息字符串
  Future<StatusContainer<String>> login({
    required String username,
    required String password,
  }) async {
    try {
      final assertionResp = await _dio.get(
          '$_host/berserker-auth/cas/login/assertion?targetUrl=http%3A%2F%2Fykt.swust.edu.cn%2Fplat%3Fname%3DloginTransit%26source%3Dh5',
          options: Options(followRedirects: false));
      final location = assertionResp.headers.value('Location');
      if (location == null) {
        return const StatusContainer(Status.fail, '未成功获取请求（0）');
      }

      final loginResult = await SOAApiService.loginToSOA(
        dio: _dio,
        username: username,
        password: password,
        url: location,
      );
      final (resp, _) = loginResult.value!;
      if (loginResult.status != Status.ok || resp == null) {
        return StatusContainer(
            loginResult.status, loginResult.value?.$2 ?? '未知错误（1）');
      }

      final location1 = resp.headers.value('Location');
      if (location1 == null) {
        return const StatusContainer(Status.fail, '未成功获取请求（1）');
      }

      final options = Options(
        followRedirects: false,
      );

      final assertionResp1 = await _dio.get(location1, options: options);
      final location2 = assertionResp1.headers.value('Location');
      if (location2 == null) {
        return const StatusContainer(Status.fail, '未成功获取请求（2）');
      }

      final assertionResp2 = await _dio.get(location2, options: options);
      final location3 = assertionResp2.headers.value('Location');
      if (location3 == null) {
        return const StatusContainer(Status.fail, '未成功获取请求（3）');
      }

      final platResp1 = await _dio.get(location3, options: options);
      final location4 = platResp1.headers.value('Location');
      if (location4 == null) {
        return const StatusContainer(Status.fail, '未成功获取请求（4）');
      }

      final ticket = Uri.parse(location4).queryParameters['ticket'];
      final platResp2 = await _dio.get(location4, options: options);
      final ok = platResp2.statusCode == 200 &&
          (platResp2.data as String?)?.contains('移动服务平台') == true;

      return StatusContainer(
          ok ? Status.ok : Status.fail, ok ? ticket : '登录失败');
    } on Exception catch (e, st) {
      debugPrint('无法登录到一卡通服务：$e');
      debugPrintStack(stackTrace: st);
      return const StatusContainer(Status.fail, '登录异常');
    }
  }

  /// 退出登录
  Future<StatusContainer> logout() async {
    final token = YKTBox.get('token') as YKTAuthToken?;
    if (token == null) {
      return const StatusContainer(Status.fail);
    }

    final queryParams = {
      'type': 'logout',
      'loginFrom': 'h5',
      'synjones-auth': token.accessToken,
      'synAccessSource': 'h5',
    };
    final resp = await _dio.get(
      '$_host/berserker-base/redirect',
      queryParameters: queryParams,
    );
    return const StatusContainer(Status.ok);
  }

  /// 获取授权码
  ///
  /// 成功时返回 [YKTAuthToken]，失败时返回错误信息字符串
  Future<StatusContainer<dynamic>> getAuthToken() async {
    try {
      final ticket = YKTBox.get('ticket') as String?;
      if (ticket == null) {
        return const StatusContainer(Status.fail, '登录失效，请重新登录');
      }

      final params = {
        'username': ticket,
        'password': ticket,
        'grant_type': 'password',
        'scope': 'all',
        'loginFrom': 'h5',
        'logintype': 'sso',
        'device_token': 'h5',
        'synAccessSource': 'h5',
      };

      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        // 不知道哪来的 token
        'Authorization':
            'Basic bW9iaWxlX3NlcnZpY2VfcGxhdGZvcm06bW9iaWxlX3NlcnZpY2VfcGxhdGZvcm1fc2VjcmV0',
        'Referer': '$_host/plat/loginTransit?ticket=$ticket',
        'Host': 'ykt.swust.edu.cn',
      };

      final resp = await _dio.post(
        '$_host/berserker-auth/oauth/token',
        data: params,
        options: Options(headers: headers, followRedirects: false),
      );

      final data = resp.data as Map<String, dynamic>;
      final token = YKTAuthToken(
        accessToken: (data['access_token'] as String).trim(),
        refreshToken: (data['refresh_token'] as String).trim(),
        expiresIn: data['expires_in'],
        tokenType: (data['token_type'] as String).trim(),
        createdAt: DateTime.now(),
      );
      return StatusContainer(Status.ok, token);
    } on Exception catch (e, st) {
      debugPrint('无法获取一卡通 Token：$e');
      debugPrintStack(stackTrace: st);
      return const StatusContainer(Status.fail, '获取一卡通令牌错误');
    }
  }

  Future<StatusContainer<dynamic>> _checkToken(
      Future<StatusContainer<dynamic>> Function(YKTAuthToken token)
          self) async {
    YKTAuthToken? token = YKTBox.get('token') as YKTAuthToken?;
    if (token == null || token.isExpired) {
      final reLoginResult = await GlobalService.yktService?.login();
      if (reLoginResult == null || reLoginResult.status != Status.ok) {
        return const StatusContainer(Status.fail, '登录状态失效，请重新登录（0）');
      }

      return await self(token!);
    }
    return await self(token);
  }

  /// 获取所有一卡通的卡片
  ///
  /// 成功时返回卡片列表，失败时返回错误信息字符串
  Future<StatusContainer<dynamic>> getCards({
    YKTAuthToken? token,
    int retries = 2,
  }) async {
    try {
      if (retries <= 0) {
        await GlobalService.yktService?.logout(notify: true);
        return const StatusContainer(Status.fail, '登录状态失效，请重新登录（1）');
      }
      retries--;
      if (token == null) {
        return _checkToken(
          (t) async => await getCards(token: t, retries: retries),
        );
      }

      final headers = {
        'Referer': '$_host/campus-card/campusCard?loginFrom=h5',
        'Synjones-Auth': '${token.tokenType} ${token.accessToken}',
      };

      final resp = await _dio.get(
        '$_host/berserker-app/ykt/tsm/getCampusCards?synAccessSource=h5',
        options: Options(
          headers: headers,
          preserveHeaderCase: true,
        ),
      );

      if (resp.statusCode == 401) {
        // 登录状态失效，尝试重新登录
        await GlobalService.yktService?.login();
        return await getCards(token: token, retries: retries);
      }

      if (resp.statusCode != 200) {
        return StatusContainer(Status.fail, '获取失败（${resp.statusCode}）');
      }

      final cards =
          (resp.data as Map<String, dynamic>)['data']['card'] as List<dynamic>;
      final result = <YKTCard>[];
      for (final card in cards) {
        final data = card as Map<String, dynamic>;
        final info = data['accinfo'] as List<dynamic>;
        final accountInfos = <YKTCardAccountInfo>[];
        for (final acc in info) {
          final accData = acc as Map<String, dynamic>;
          accountInfos.add(YKTCardAccountInfo(
            name: accData['name'] as String,
            type: accData['type'] as String,
            balance: ((accData['balance'] as int) / 100).toStringAsFixed(2),
          ));
        }

        result.add(YKTCard(
          account: data['account'] as String,
          cardName: data['cardname'] as String,
          departmentName: data['department_name'] as String,
          expireDate: (data['expdate'] as String).replaceAllMapped(
              RegExp(r'(\d{4})(\d{2})(\d{2})'),
              (match) => '${match[1]}/${match[2]}/${match[3]}'),
          name: data['name'] as String,
          accountInfos: accountInfos,
        ));
      }

      return StatusContainer(Status.ok, result);
    } on Exception catch (e, st) {
      debugPrint('无法获取一卡通卡包：$e');
      debugPrintStack(stackTrace: st);
      return const StatusContainer(Status.fail, '获取一卡通卡包错误');
    }
  }

  /// 根据卡账户和支付账户获取所有支付码
  ///
  /// 成功时返回一个 `List<String>`，否则返回错误信息字符串。
  Future<StatusContainer<dynamic>> getBarCodes({
    required String account,
    required String payAccount,
    YKTAuthToken? token,
    int retries = 2,
  }) async {
    try {
      if (retries <= 0) {
        await GlobalService.yktService?.logout(notify: true);
        return const StatusContainer(Status.fail, '登录状态失效，请重新登录（2）');
      }
      retries--;
      if (token == null) {
        return _checkToken(
          (t) async => await getBarCodes(
            account: account,
            payAccount: payAccount,
            token: t,
            retries: retries,
          ),
        );
      }

      final headers = {
        'Referer':
            'http://ykt.swust.edu.cn/plat/pay?nodeId=15&synjones-auth=${token.accessToken}&loginFrom=h5',
        'Synjones-Auth': '${token.tokenType} ${token.accessToken}',
      };

      final resp = await _dio.get(
        // paytype：1 = 校园卡，2 = 银行卡
        '$_host/berserker-app/ykt/tsm/batchGetBarCodeGet?account=$account&payacc=$payAccount&paytype=1&synAccessSource=h5',
        options: Options(
          headers: headers,
          preserveHeaderCase: true,
        ),
      );

      if (resp.statusCode == 401) {
        // 登录状态失效，尝试重新登录
        await GlobalService.yktService?.login();
        return await getBarCodes(
          account: account,
          payAccount: payAccount,
          token: token,
          retries: retries,
        );
      }

      if (resp.statusCode != 200) {
        return StatusContainer(Status.fail, '获取失败（${resp.statusCode}）');
      }

      final data = (resp.data as Map<String, dynamic>)['data'];
      List<String> barcodes =
          ((data as Map<String, dynamic>)['barcode'] as List<dynamic>).cast();

      return StatusContainer(Status.ok, barcodes);
    } on Exception catch (e, st) {
      debugPrint('无法获取一卡通支付码：$e');
      debugPrintStack(stackTrace: st);
      return const StatusContainer(Status.fail, '获取一卡通支付码错误');
    }
  }

  /// 获取一卡通账单数据
  ///
  /// 成功时返回 `List<YKTBill>`，否则返回错误信息字符串
  Future<StatusContainer<dynamic>> getBills({
    required String account,
    required String payAccount,
    int page = 1,
    int pageSize = 10,
    YKTAuthToken? token,
    int retries = 2,
  }) async {
    try {
      if (retries <= 0) {
        await GlobalService.yktService?.logout(notify: true);
        return const StatusContainer(Status.fail, '登录状态失效，请重新登录（3）');
      }
      retries--;
      if (token == null) {
        return _checkToken(
          (t) async => await getBills(
            account: account,
            payAccount: payAccount,
            page: page,
            pageSize: pageSize,
            token: t,
            retries: retries,
          ),
        );
      }

      final headers = {
        'Referer': '$_host/campus-card/billing/list?loginFrom=h5',
        'Synjones-Auth': '${token.tokenType} ${token.accessToken}',
      };

      final resp = await _dio.get(
        '$_host/berserker-search/search/personal/turnover',
        queryParameters: {
          'size': pageSize,
          'current': page,
          'synAccessSource': 'h5',
        },
        options: Options(
          headers: headers,
          preserveHeaderCase: true,
        ),
      );

      if (resp.statusCode == 401) {
        // 登录状态失效，尝试重新登录
        await GlobalService.yktService?.login();
        return await getBills(
          account: account,
          payAccount: payAccount,
          page: page,
          pageSize: pageSize,
          token: token,
          retries: retries,
        );
      }

      if (resp.statusCode != 200) {
        return StatusContainer(Status.fail, '获取失败（${resp.statusCode}）');
      }

      final responseData = resp.data as Map<String, dynamic>;
      if (responseData['code'] != 200 || responseData['success'] != true) {
        return StatusContainer(Status.fail, responseData['msg'] ?? '获取账单失败');
      }

      final data = responseData['data'] as Map<String, dynamic>;
      final records = data['records'] as List<dynamic>;

      List<YKTBill> bills = records.map((record) {
        return YKTBill.fromJson(record as Map<String, dynamic>);
      }).toList();

      return StatusContainer(Status.ok, bills);
    } on Exception catch (e, st) {
      debugPrint('无法获取一卡通账单：$e');
      debugPrintStack(stackTrace: st);
      return const StatusContainer(Status.fail, '获取一卡通账单错误');
    }
  }

  /// 获取指定时间段内的收支统计
  ///
  /// 成功时返回包含income和expenses的Map，否则返回错误信息字符串
  Future<StatusContainer<dynamic>> getStatistics({
    required String timeFrom,
    required String timeTo,
    YKTAuthToken? token,
    int retries = 2,
  }) async {
    try {
      if (retries <= 0) {
        await GlobalService.yktService?.logout(notify: true);
        return const StatusContainer(Status.fail, '登录状态失效，请重新登录（4）');
      }
      retries--;
      if (token == null) {
        return _checkToken(
          (t) async => await getStatistics(
            timeFrom: timeFrom,
            timeTo: timeTo,
            token: t,
            retries: retries,
          ),
        );
      }

      final headers = {
        'Referer': '$_host/campus-card/billing/list?loginFrom=h5',
        'Synjones-Auth': '${token.tokenType} ${token.accessToken}',
      };

      final resp = await _dio.get(
        '$_host/berserker-search/statistics/turnover/count',
        queryParameters: {
          'timeFrom': timeFrom,
          'timeTo': timeTo,
          'synAccessSource': 'h5',
        },
        options: Options(
          headers: headers,
          preserveHeaderCase: true,
        ),
      );

      if (resp.statusCode == 401) {
        // 登录状态失效，尝试重新登录
        await GlobalService.yktService?.login();
        return await getStatistics(
          timeFrom: timeFrom,
          timeTo: timeTo,
          token: token,
          retries: retries,
        );
      }

      if (resp.statusCode != 200) {
        return StatusContainer(Status.fail, '获取失败（${resp.statusCode}）');
      }

      final responseData = resp.data as Map<String, dynamic>;
      if (responseData['code'] != 200 || responseData['success'] != true) {
        return StatusContainer(Status.fail, responseData['msg'] ?? '获取统计数据失败');
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return StatusContainer(Status.ok, {
        'income': data['income'] as double,
        'expenses': data['expenses'] as double,
      });
    } on Exception catch (e, st) {
      debugPrint('无法获取一卡通统计数据：$e');
      debugPrintStack(stackTrace: st);
      return const StatusContainer(Status.fail, '获取一卡通统计数据错误');
    }
  }
}
