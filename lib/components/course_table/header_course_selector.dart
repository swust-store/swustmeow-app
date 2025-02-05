import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/services/global_service.dart';

class HeaderCourseSelector extends StatefulWidget {
  const HeaderCourseSelector(
      {super.key,
      required this.currentTerm,
      required this.terms,
      required this.onChange,
      this.enabled = true});

  final String currentTerm;
  final List<String> terms;
  final Function(String value) onChange;
  final bool enabled;

  @override
  State<StatefulWidget> createState() => _HeaderCourseSelectorState();
}

class _HeaderCourseSelectorState extends State<HeaderCourseSelector>
    with SingleTickerProviderStateMixin {
  String? _currentValue;
  late FPopoverController _popoverController;
  late FRadioSelectGroupController<String> _groupController;
  bool _isPopoverOpened = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentTerm;
    _popoverController = FPopoverController(vsync: this);
    _popoverController.addListener(() {
      setState(() => _isPopoverOpened = !_isPopoverOpened);
    });
    _groupController = FRadioSelectGroupController(value: _currentValue);
    _groupController.addListener(() {
      final value = _groupController.values.firstOrNull ?? widget.currentTerm;
      setState(() {
        _currentValue = value;
        widget.onChange(value);
      });
      _popoverController.hide();
    });
  }

  String _parseDisplayString(String term) {
    final [s, e, t] = term.split('-');
    final now = DateTime.now();
    final (_, _, w) =
        GlobalService.termDates.value[term]?.value ?? (now, now, -1);
    final [ts, te] = [s, e].map((x) => int.parse(x) - 2000).toList();
    final week = w > 0 ? '($w周)' : '';
    return '$ts-$te-$t$week';
  }

  @override
  Widget build(BuildContext context) {
    return FPopover(
      controller: _popoverController,
      target: _buildSelector(),
      followerBuilder: (context, style, child) {
        return SizedBox(
          width: 200,
          child: FSelectTileGroup.builder(
              groupController: _groupController,
              divider: FTileDivider.full,
              count: widget.terms.length,
              enabled: widget.enabled,
              tileBuilder: (context, index) {
                final value = widget.terms[index];
                return FSelectTile(
                    title: Transform.translate(
                      offset: Offset(-16.0, 0.0),
                      child: Center(
                        child: Text(_parseDisplayString(value),
                            style: TextStyle(fontSize: 14)),
                      ),
                    ),
                    value: value);
              }),
        );
      },
      followerAnchor: Alignment.topCenter,
      targetAnchor: Alignment.bottomCenter,
    );
  }

  Widget _buildSelector() {
    final t = context.theme.tileGroupStyle.tileStyle;
    final c = context.theme.colorScheme;
    final bgColor = Values.isDarkMode ? c.background : c.primaryForeground;
    return SizedBox(
      width: 200,
      child: FTile(
        enabled: widget.enabled,
        title: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_parseDisplayString(_currentValue!)),
              const SizedBox(width: 4.0),
              FIcon(
                  _isPopoverOpened
                      ? FAssets.icons.chevronUp
                      : FAssets.icons.chevronDown,
                  color: widget.enabled ? c.primary : Colors.grey)
            ],
          ),
        ),
        style: t.copyWith(
            border: Border.all(color: Colors.transparent, width: 0.0),
            enabledBackgroundColor: bgColor,
            enabledHoveredBackgroundColor: bgColor,
            disabledBackgroundColor: bgColor,
            contentStyle: t.contentStyle.copyWith(padding: EdgeInsets.zero)),
        onPress: _popoverController.toggle,
      ),
    );
  }
}
