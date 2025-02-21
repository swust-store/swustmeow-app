import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/services/boxes/common_box.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/views/todo_page.dart';

import '../components/utils/empty.dart';
import '../components/utils/m_scaffold.dart';
import '../data/m_theme.dart';
import '../services/global_keys.dart';
import '../services/value_service.dart';
import '../utils/router.dart';
import 'settings/settings_page.dart';
import 'home_page.dart';
import 'instruction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.index});

  final int? index;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isFirstTime = false;
  late BuildContext _showcaseContext;
  late List<GlobalKey> _showcaseKeys;
  bool _hasStartedShowcase = false;
  int _index = 0;
  final pages = [
    ('首页', FontAwesomeIcons.house, HomePage()),
    ('待办', FontAwesomeIcons.tableList, TodoPage()),
    ('设置', FontAwesomeIcons.gear, SettingsPage())
  ];

  @override
  void initState() {
    super.initState();
    _isFirstTime = CommonBox.get('isFirstTime') ?? true;
    if (widget.index != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _refresh(() => _index = widget.index!));
    }

    _showcaseKeys = [
      GlobalKeys.showcaseCourseTableKey,
      GlobalKeys.showcaseCalendarKey,
      GlobalKeys.showcaseCourseCardsKey,
      GlobalKeys.showcaseToolGridKey,
    ];
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalService.size = MediaQuery.of(context).size;

    if (!Values.showcaseMode && GlobalService.soaService?.isLogin != true) {
      pushReplacement(context, const InstructionPage(), pushInto: true);
      return const Empty();
    }

    final (_, _, content) = pages[_index];

    return ShowCaseWidget(
      disableBarrierInteraction: true,
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        left: 16,
        bottom: 16,
        child: Padding(
          padding: EdgeInsets.all(MTheme.radius),
          child: ElevatedButton(
            onPressed: () {
              CommonBox.put('isFirstTime', false);
              ShowCaseWidget.of(showcaseContext).dismiss();
            },
            style: ElevatedButton.styleFrom(backgroundColor: MTheme.primary2),
            child: Text('跳过', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      globalTooltipActionConfig: TooltipActionConfig(
        position: TooltipActionPosition.outside,
        alignment: MainAxisAlignment.end,
        actionGap: 2,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          name: '上一个',
          type: TooltipDefaultActionType.previous,
          textStyle: TextStyle(color: Colors.white),
          hideActionWidgetForShowcase: [_showcaseKeys.first],
          backgroundColor: Colors.transparent,
        ),
        TooltipActionButton(
          name: '下一个',
          type: TooltipDefaultActionType.next,
          textStyle: TextStyle(color: Colors.white),
          hideActionWidgetForShowcase: [_showcaseKeys.last],
          backgroundColor: MTheme.primary2,
        ),
        TooltipActionButton(
            name: '完成',
            type: TooltipDefaultActionType.skip,
            textStyle: TextStyle(color: Colors.white),
            hideActionWidgetForShowcase:
                _showcaseKeys.sublist(0, _showcaseKeys.length - 1),
            backgroundColor: MTheme.primary2,
            onTap: () {
              CommonBox.put('isFirstTime', false);
              ShowCaseWidget.of(_showcaseContext).dismiss();
            })
      ],
      builder: (showcaseContext) {
        if (_isFirstTime && !_hasStartedShowcase) {
          _refresh(() => _showcaseContext = showcaseContext);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refresh(() => _hasStartedShowcase = true);
            ShowCaseWidget.of(_showcaseContext).startShowCase(_showcaseKeys);
          });
        }
        return ValueListenableBuilder(
          valueListenable: ValueService.isFlipEnabled,
          builder: (context, value, child) {
            return Transform.flip(
              flipX: value,
              flipY: value,
              child: MScaffold(
                safeArea: false,
                safeBottom: false,
                child: FScaffold(
                  contentPad: false,
                  content: content,
                  footer: FBottomNavigationBar(
                    index: _index,
                    onChange: (index) {
                      _refresh(() => _index = index);
                    },
                    children: pages.map((data) {
                      final (label, icon, _) = data;
                      final color =
                          pages[_index] == data ? MTheme.primary2 : Colors.grey;
                      return ValueListenableBuilder(
                          valueListenable: ValueService.hasUpdate,
                          builder: (context, hasUpdate, child) {
                            return FBottomNavigationBarItem(
                              label: Text(
                                label,
                                style: TextStyle(color: color, fontSize: 10),
                              ),
                              icon: SizedBox(
                                width: 40,
                                child: Stack(
                                  children: [
                                    Center(
                                      child:
                                          FaIcon(icon, color: color, size: 20),
                                    ),
                                    if (label == '设置' && hasUpdate)
                                      Positioned(
                                        left: (40 / 2) + 10,
                                        child: SizedBox(
                                          width: 5,
                                          height: 5,
                                          child: badge.Badge(),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            );
                          });
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
