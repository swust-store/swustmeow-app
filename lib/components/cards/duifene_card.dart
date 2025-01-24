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
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: GlobalService.duifeneService.isLogin,
        builder: (context, isLogin, child) {
          return Clickable(
              onClick: () {
                if (isLogin) {}
              },
              child: FCard(
                image: FIcon(FAssets.icons.bookUser),
                title: Text('对分易签到a'),
                style: widget.cardStyle,
              ));
        });
  }
}
