import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/version/version_info.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/time.dart';

import '../data/m_theme.dart';
import '../entity/version/version_push_type.dart';
import '../utils/widget.dart';

class VersionDialog extends StatefulWidget {
  const VersionDialog({super.key, required this.info});

  final VersionInfo info;

  @override
  State<StatefulWidget> createState() => _VersionDialogState();
}

class _VersionDialogState extends State<VersionDialog> {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      // canPop: false,
      onPopInvokedWithResult: (_, __) => false,
      child: Center(
        child: Container(
          width: (8 / 10) * size.width,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(180, 216, 253, 1),
                Color.fromRGBO(187, 224, 252, 1),
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
              ],
              transform: const GradientRotation(pi / 2),
            ),
            borderRadius: BorderRadius.circular(MTheme.radius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '发现新版本',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  color: MTheme.primary4.withValues(alpha: 0.6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  'NEW VERSION: v${widget.info.version}',
                  style: TextStyle(color: MTheme.primary2, fontSize: 12),
                ),
              ),
              SizedBox(height: 16),
              ...widget.info.changes.map(
                (c) => Text(
                  c,
                  style: TextStyle(
                      fontSize: 14, color: Colors.black.withValues(alpha: 0.6)),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '发布日期：${widget.info.releaseDate.year}-${widget.info.releaseDate.month.padL2}-${widget.info.releaseDate.day.padL2}',
                style: TextStyle(color: MTheme.primary2, fontSize: 12),
              ),
              SizedBox(height: 16),
              Row(
                children: joinGap(
                  gap: 16,
                  axis: Axis.horizontal,
                  widgets: [
                    Expanded(
                      child: FButton(
                        onPress: () async {
                          if (_isDownloading) return;
                          Navigator.of(context).pop(false);
                        },
                        label: Text(
                          switch (widget.info.pushType) {
                            VersionPushType.minor => '忽略此版本',
                            VersionPushType.major => '暂不',
                          },
                        ),
                        style: FButtonStyle.secondary,
                      ),
                    ),
                    Expanded(
                      child: FButton(
                        onPress: () async {
                          if (_isDownloading) return;
                          await _download();
                        },
                        label: Text(
                          !_isDownloading
                              ? '立即体验'
                              : _downloadProgress != 1.0
                                  ? '${(_downloadProgress * 100).floor()}%'
                                  : '正在安装',
                          maxLines: 1,
                        ),
                        style: FButtonStyle.primary,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _download() async {
    _refresh(() => _isDownloading = true);

    try {
      final fileName = '${Values.name}-v${widget.info.version}.apk';
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$fileName';
      final dio = Dio();
      await dio.download(widget.info.distributionUrl, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() => _downloadProgress = received / total);
        }
      });
      final res = await InstallPlugin.install(savePath);
      final isSuccess = res['isSuccess'] == true;

      if (!isSuccess) {
        debugPrint('安装失败');
        showErrorToast('安装失败，请手动更新');
      }
    } on Exception catch (e, st) {
      debugPrint('无法下载安装包（${widget.info.distributionUrl}）：$e');
      debugPrintStack(stackTrace: st);
      launchLink(widget.info.distributionUrl);
      showErrorToast('下载失败，请手动下载安装包');
    }

    _refresh(() {
      _isDownloading = false;
      _downloadProgress = 0.0;
    });
  }
}
