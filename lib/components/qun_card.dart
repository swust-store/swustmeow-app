import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:swustmeow/data/m_theme.dart';

import '../utils/common.dart';

class QunCard extends StatefulWidget {
  const QunCard({
    super.key,
    required this.name,
    required this.qid,
    required this.link,
    required this.iosLink,
  });

  final String name;
  final String qid;
  final String link;
  final String? iosLink;

  @override
  State<StatefulWidget> createState() => _QunCardState();
}

class _QunCardState extends State<QunCard> {
  CachedNetworkImageProvider? _image;
  Color _primaryColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _fetchImage();
    await _fetchPrimaryColor();
  }

  Future<void> _fetchImage() async {
    _image = CachedNetworkImageProvider(
      'https://p.qlogo.cn/gh/${widget.qid}/${widget.qid}/640/',
    );
  }

  Future<void> _fetchPrimaryColor() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(_image!);
    final color = paletteGenerator.lightVibrantColor?.color ?? Colors.grey;
    _refresh(() => _primaryColor = color);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: SizedBox(
              height: 48,
              width: 48,
              child: Image(
                image: _image!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Skeletonizer(child: child);
                },
                errorBuilder: (context, child, err) {
                  return Center(
                    child: FaIcon(
                      FontAwesomeIcons.circleExclamation,
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.qid,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 50,
            child: FTappable(
              onPress: () async {
                bool result;
                if (Platform.isIOS && widget.iosLink != null) {
                  result = await launchLink(widget.iosLink!);
                } else {
                  result = await launchLink(widget.link);
                }
                if (!result) {
                  showErrorToast('无法启动相关应用');
                }
              },
              child: Center(
                child: Text(
                  '› 点击加入 ‹',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MTheme.radius),
        border: Border.all(color: _primaryColor),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
