import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/services/global_service.dart';

class DuiFenECard extends StatefulWidget {
  const DuiFenECard({super.key, required this.cardStyle});

  final FCardStyle cardStyle;

  @override
  State<StatefulWidget> createState() => _DuiFenECardState();
}

class _DuiFenECardState extends State<DuiFenECard> {
  String? _signingCourse;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: GlobalService.duifeneService?.isLoginNotifier ??
            ValueNotifier(false),
        builder: (context, isLogin, child) {
          return Clickable(
              onClick: () {
                if (isLogin) {}
              },
              child: FCard(
                image: FIcon(FAssets.icons.bookUser),
                title: Text('对分易签到'),
                style: widget.cardStyle,
                child: _getChild(isLogin),
              ));
        });
  }

  Widget _getChild(bool isLogin) {
    final style = TextStyle(color: isLogin ? Colors.grey : Colors.red);
    return SizedBox(
      height: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Divider(),
          Text(!isLogin ? '未登录' : _signingCourse ?? '无课程',
              style: style.copyWith(fontSize: 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  !isLogin
                      ? '点击以登录'
                      : _signingCourse != null
                          ? '签到中...'
                          : '等待上课',
                  style: style.copyWith(fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
