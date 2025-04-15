import 'package:flutter/material.dart';
import 'package:swustmeow/config.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

class UmengService {
  static Future<void> initUmeng() async {
    debugPrint('初始化友盟 SDK...');
    UmengCommonSdk.initCommon(Config.umengAppKey, Config.umengAppKey, 'Umeng')
        .then((result) {
      debugPrint('友盟 SDK 初始化结果：$result');
    });
    UmengCommonSdk.setPageCollectionModeManual();
  }
}
