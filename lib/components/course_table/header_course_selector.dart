import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class HeaderCourseSelector extends StatefulWidget {
  const HeaderCourseSelector(
      {super.key,
      required this.defaultValue,
      required this.values,
      required this.onChange,
      this.enabled = true});

  final String defaultValue;
  final List<String> values;
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
    _currentValue = widget.defaultValue;
    _popoverController = FPopoverController(vsync: this);
    _popoverController.addListener(() {
      setState(() => _isPopoverOpened = !_isPopoverOpened);
    });
    _groupController = FRadioSelectGroupController(value: _currentValue);
    _groupController.addListener(() {
      final value = _groupController.values.firstOrNull ?? widget.defaultValue;
      setState(() {
        _currentValue = value;
        widget.onChange(value);
      });
      _popoverController.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FPopover(
      controller: _popoverController,
      target: _buildSelector(),
      followerBuilder: (context, style, child) {
        return SizedBox(
          width: 220,
          child: FSelectTileGroup.builder(
              groupController: _groupController,
              divider: FTileDivider.full,
              count: widget.values.length,
              enabled: widget.enabled,
              tileBuilder: (context, index) {
                final value = widget.values[index];
                return FSelectTile(
                    title: Transform.translate(
                      offset: Offset(-16.0, 0.0),
                      child: Center(
                        child: Text(value),
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
    return SizedBox(
      width: 200,
      child: FTile(
        enabled: widget.enabled,
        title: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_currentValue!),
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
            enabledBackgroundColor: c.primaryForeground,
            enabledHoveredBackgroundColor: c.primaryForeground,
            disabledBackgroundColor: c.primaryForeground,
            contentStyle: t.contentStyle.copyWith(padding: EdgeInsets.zero)),
        onPress: _popoverController.toggle,
      ),
    );
  }
}
