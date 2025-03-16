import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:swustmeow/utils/color.dart';

import '../../utils/common.dart';

class QunCard extends StatefulWidget {
  const QunCard({
    super.key,
    required this.name,
    required this.qid,
    required this.link,
    required this.iosLink,
    this.description,
  });

  final String name;
  final String qid;
  final String link;
  final String? iosLink;
  final String? description;

  @override
  State<StatefulWidget> createState() => _QunCardState();
}

class _QunCardState extends State<QunCard> {
  CachedNetworkImageProvider? _image;
  Color _primaryColor = Colors.grey;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _fetchImage();
  }

  void _fetchImage() {
    _image = CachedNetworkImageProvider(
      'https://p.qlogo.cn/gh/${widget.qid}/${widget.qid}/640/',
      errorListener: (_) {
        if (mounted) {
          setState(() {
            _isImageLoaded = true;
          });
        }
      },
    );

    // 异步获取主色，避免阻塞UI
    _image!
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
      _fetchPrimaryColor();
      if (mounted) {
        setState(() {
          _isImageLoaded = true;
        });
      }
    }));
  }

  Future<void> _fetchPrimaryColor() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(_image!,
              maximumColorCount: 8);
      final color = paletteGenerator.lightVibrantColor?.color ??
          paletteGenerator.dominantColor?.color ??
          Colors.blueGrey;
      _refresh(() => _primaryColor = generatePrimaryColors(color).first);
    } catch (e) {
      _refresh(() => _primaryColor = Colors.blueGrey);
    }
  }

  void _refresh([Function()? fn]) {
    if (!mounted) return;
    setState(fn ?? () {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
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
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "群号: ${widget.qid}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      if (widget.description != null &&
                          widget.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            widget.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.2),
                    // border: Border.all(
                    //     color: _primaryColor.withValues(alpha: 0.3), width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.rightToBracket,
                        size: 12,
                        color: _primaryColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '加入',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isImageLoaded ? Colors.transparent : Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.15),
            blurRadius: 6,
            spreadRadius: 0.5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: _isImageLoaded
            ? Image(
                image: _image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: FaIcon(
                      FontAwesomeIcons.userGroup,
                      color: Colors.grey,
                      size: 18,
                    ),
                  );
                },
              )
            : Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    strokeWidth: 2,
                  ),
                ),
              ),
      ),
    );
  }
}
