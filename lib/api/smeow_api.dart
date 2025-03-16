import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/services/boxes/common_box.dart';
import 'package:swustmeow/utils/time.dart';

class SMeowApiService {
  static final _dio = Dio();

  /// 初始化 Dio 配置
  static Future<void> init() async {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.validateStatus = (status) => true;
  }

  /// 统一处理API响应
  static StatusContainer<dynamic> _handleResponse(Response response) {
    if (response.statusCode == 401) {
      return StatusContainer(Status.notAuthorized, '未授权');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final json = response.data as Map<String, dynamic>;
        final String? msg = json['msg'];
        return StatusContainer(Status.fail, msg ?? '未知错误');
      } catch (_) {
        return StatusContainer(Status.fail, '错误代码 ${response.statusCode}');
      }
    }

    try {
      final Map<String, dynamic> json = response.data;
      final bool flag = json['flag'] == true;
      final String? msg = json['msg'];
      final dynamic data = json['data'];

      if (!flag) {
        return StatusContainer(Status.fail, msg ?? '未知错误');
      }
      return StatusContainer(Status.ok, data);
    } catch (e) {
      return StatusContainer(Status.fail, '解析响应失败');
    }
  }

  /// 提交QQ群信息
  ///
  /// 将QQ群的名称、群号、链接和描述提交到后端API进行审核。
  /// 如果提交成功，返回成功状态；否则，返回错误信息。
  /// 每个用户每天最多可提交10个群聊。
  ///
  /// 参数:
  ///   name: QQ群名称
  ///   qid: QQ群号
  ///   link: QQ群链接
  ///   description: QQ群描述
  ///
  /// 返回值: 包含提交结果的状态容器
  static Future<StatusContainer<String>> submitQQGroup({
    required String name,
    required String qid,
    required String link,
    required String description,
  }) async {
    try {
      // 检查每日提交限制
      Map<String, int>? qunSubmissionCount =
          (CommonBox.get('qunSubmissionCount') as Map<dynamic, dynamic>?)
              ?.cast();
      final now = DateTime.now();
      final today = '${now.year}-${now.month.padL2}-${now.day.padL2}';

      qunSubmissionCount ??= {};

      if (qunSubmissionCount.containsKey(today)) {
        if (qunSubmissionCount[today]! >= 10) {
          return StatusContainer(Status.fail, '今天已达到群聊提交上限（10个/天）');
        }

        qunSubmissionCount[today] = qunSubmissionCount[today]! + 1;
      } else {
        qunSubmissionCount[today] = 1;
      }

      final response = await _dio.post(
        'https://api.s-meow.com/api/v1/public/qun-submit',
        data: {
          'name': name,
          'qid': qid,
          'link': link,
          'description': description,
        },
      );

      final result = _handleResponse(response);
      if (result.status != Status.ok) {
        return StatusContainer(result.status, result.value.toString());
      }

      // 提交成功后保存计数
      CommonBox.put('qunSubmissionCount', qunSubmissionCount);

      return StatusContainer(Status.ok, '提交成功，等待审核');
    } on DioException catch (e) {
      debugPrint('提交QQ群失败：$e');
      if (e.type == DioExceptionType.connectionTimeout) {
        return StatusContainer(Status.fail, '连接超时');
      }
      return StatusContainer(Status.fail, '网络请求失败');
    } on Exception catch (e, st) {
      debugPrint('提交QQ群失败：$e');
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '请求错误');
    }
  }
}
