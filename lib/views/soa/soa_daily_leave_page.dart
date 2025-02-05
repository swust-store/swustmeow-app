import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/empty.dart';
import 'package:swustmeow/data/soa_leave_area.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_action.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_options.dart';
import 'package:swustmeow/entity/soa/leave/leave_type.dart';
import 'package:swustmeow/entity/soa/leave/vehicle_type.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/time.dart';
import 'package:swustmeow/utils/widget.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../data/values.dart';

class SOADailyLeavePage extends StatefulWidget {
  const SOADailyLeavePage(
      {super.key,
      required this.action,
      this.leaveId,
      required this.onSaveDailyLeave});

  final DailyLeaveAction action;
  final String? leaveId;
  final Function(DailyLeaveOptions options) onSaveDailyLeave;

  @override
  State<StatefulWidget> createState() => _SOADailyLeavePageState();
}

class _SOADailyLeavePageState extends State<SOADailyLeavePage> {
  late TextStyle ts;
  final _formKey = GlobalKey<FormState>();
  final _beginDateController =
      FCalendarController.date(initialSelection: DateTime.now());
  DateTime _beginDate = DateTime.now();
  int _beginTime = DateTime.now().hour;
  var _endDateController =
      FCalendarController.date(initialSelection: DateTime.now());
  DateTime _endDate = DateTime.now();
  int _endTime = DateTime.now().hour;
  final _typeSelectController =
      FRadioSelectGroupController<LeaveType>(value: LeaveType.seekJob);
  final _thingController = TextEditingController();
  final Map<int, String> _provinces = {};
  final Map<int, String> _cities = {};
  final Map<int, String> _counties = {};
  final _provinceSelectController = FRadioSelectGroupController<int>();
  final _citySelectController = FRadioSelectGroupController<int>();
  final _countySelectController = FRadioSelectGroupController<int>();
  final _addressController = TextEditingController();
  bool _tellParent = false;
  final _alongWithNumController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _outTelController = TextEditingController();
  final _outPhoneController = TextEditingController();
  final _outRelationController = TextEditingController();
  final _outNameController = TextEditingController();
  final _selfPhoneController = TextEditingController();
  final _selfOtherTelController = TextEditingController();
  final _goDateController =
      FCalendarController.date(initialSelection: DateTime.now());
  DateTime _goDate = DateTime.now();
  int _goTime = DateTime.now().hour;
  final _goVehicleTypeController =
      FRadioSelectGroupController<VehicleType>(value: VehicleType.car);
  var _backDateController =
      FCalendarController.date(initialSelection: DateTime.now());
  DateTime _backDate = DateTime.now();
  int _backTime = DateTime.now().hour;
  final _backVehicleTypeController =
      FRadioSelectGroupController<VehicleType>(value: VehicleType.car);
  bool _isSubmitting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _beginDateController.addListener(() {
      setState(() {
        _beginDate = _beginDateController.value!;
        _initEndDateController(_beginDate);
      });
    });
    _initEndDateController(DateTime.now());
    _loadProvinces();
    _provinceSelectController.addListener(() {
      final provinceCode = _provinceSelectController.values.first;
      _setCity(provinceCode);
    });
    _citySelectController.addListener(() {
      final provinceCode = _provinceSelectController.values.first;
      final cityCode = _citySelectController.values.first;
      _setCounty(provinceCode, cityCode);
    });
    _goDateController.addListener(() {
      setState(() {
        _goDate = _goDateController.value!;
        _initBackDateController(_goDate);
      });
    });
    _initBackDateController(DateTime.now());

    if (widget.leaveId != null) {
      _loadOptions();
    }
  }

  Future<void> _loadOptions() async {
    _refresh(() => _isLoading = true);

    final id = widget.leaveId!;
    final result = await GlobalService.soaService?.getDailyLeaveInformation(id);
    if (result == null || result.status != Status.ok) {
      if (mounted) showErrorToast(context, '无法加载请假信息');
      return;
    }
    final o = result.value! as DailyLeaveOptions;

    _beginDateController.select(o.leaveBeginDate);
    _beginDate = o.leaveBeginDate;
    _beginTime = o.leaveBeginTime;
    _endDateController.select(o.leaveEndDate);
    _endDate = o.leaveEndDate;
    _endTime = o.leaveEndTime;
    _typeSelectController.select(o.leaveType, true);
    _thingController.text = o.leaveThing;
    _loadArea(o);
    _addressController.text = o.outAddress;
    _tellParent = o.isTellRbl;
    _alongWithNumController.text = o.withNumNo.toString();
    _parentNameController.text = o.jhrName;
    _parentPhoneController.text = o.jhrPhone;
    _outTelController.text = o.outTel;
    _outPhoneController.text = o.outMoveTel;
    _outRelationController.text = o.relation;
    _outNameController.text = o.outName;
    _selfPhoneController.text = o.stuMoveTel;
    _selfOtherTelController.text = o.stuOtherTel;
    _goDateController.select(o.goDate);
    _goDate = o.goDate;
    _goTime = o.goTime;
    _goVehicleTypeController.select(o.goVehicle, true);
    _backDateController.select(o.backDate);
    _backDate = o.backDate;
    _backTime = o.backTime;
    _backVehicleTypeController.select(o.backVehicle, true);

    _refresh(() => _isLoading = false);
  }

  void _loadArea(DailyLeaveOptions options) {
    final area = options.area;
    final provinceCode = int.parse(area.substring(0, 2));
    final cityCode = int.parse(area.substring(2, 4));
    final countyCode = int.parse(area.substring(4, 6));
    _provinceSelectController.select(provinceCode, true);
    _citySelectController.select(cityCode, true);
    _countySelectController.select(countyCode, true);
  }

  void _refresh([void Function()? fn]) => WidgetsBinding.instance
      .addPostFrameCallback((_) => setState(fn ?? () {}));

  void _loadProvinces() {
    _provinces.clear();
    for (final provinceCode in areaData.keys) {
      final name = areaData[provinceCode]!['_']! as String;
      _provinces[provinceCode] = name;
    }
    _refresh();
  }

  void _setCity(int provinceCode) {
    _cities.clear();
    final cities = areaData[provinceCode]!;
    for (final cityCode in cities.keys) {
      if (cityCode is! int) continue;
      final name = (cities[cityCode]! as Map<Object, String>)['_']!;
      _cities[cityCode] = name;
    }
    _refresh();
  }

  void _setCounty(int provinceCode, int cityCode) {
    _counties.clear();
    final counties = areaData[provinceCode]![cityCode]! as Map<Object, String>;
    for (final countyCode in counties.keys) {
      if (countyCode is! int) continue;
      final name = counties[countyCode]!;
      _counties[countyCode] = name;
    }
    _refresh();
  }

  void _initEndDateController(DateTime initialSelection) {
    _endDateController = FCalendarController.date()
      ..select(initialSelection)
      ..addListener(() {
        setState(() => _endDate = _endDateController.value!);
      });
  }

  void _initBackDateController(DateTime initialSelection) {
    _backDateController = FCalendarController.date()
      ..select(initialSelection)
      ..addListener(() {
        setState(() => _backDate = _backDateController.value!);
      });
  }

  @override
  void dispose() {
    _beginDateController.dispose();
    _endDateController.dispose();
    _typeSelectController.dispose();
    _thingController.dispose();
    _provinceSelectController.dispose();
    _citySelectController.dispose();
    _countySelectController.dispose();
    _addressController.dispose();
    _alongWithNumController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _outTelController.dispose();
    _outPhoneController.dispose();
    _outRelationController.dispose();
    _outNameController.dispose();
    _selfPhoneController.dispose();
    _selfOtherTelController.dispose();
    _goDateController.dispose();
    _goVehicleTypeController.dispose();
    _backDateController.dispose();
    _backVehicleTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _isSubmitting ? Colors.grey : context.theme.colorScheme.primary;
    ts = TextStyle(fontSize: 16, color: color);
    return Transform.flip(
      flipX: Values.isFlipEnabled.value,
      flipY: Values.isFlipEnabled.value,
      child: FScaffold(
        contentPad: false,
        header: FHeader.nested(
          title: Text(
            switch (widget.action) {
              DailyLeaveAction.add => '新增日常请假',
              DailyLeaveAction.edit => '编辑日常请假'
            },
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          prefixActions: [
            FHeaderAction(
                icon: FIcon(FAssets.icons.chevronLeft),
                onPress: () => Navigator.of(context).pop())
          ],
          suffixActions: [
            FHeaderAction(
                icon: FIcon(FAssets.icons.save, color: color),
                onPress: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (_isSubmitting) return;
                  await _submit();
                })
          ],
        ).withBackground,
        content: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: context.theme.colorScheme.primary,
              ))
            : Stack(
                children: [
                  IgnorePointer(
                    ignoring: _isSubmitting,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                          key: _formKey,
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children:
                                joinGap(gap: 16, axis: Axis.vertical, widgets: [
                              _buildInformationColumn(),
                              _buildParentInformationColumn(),
                              _buildOutInformationColumn(),
                              _buildSelfInformationColumn(),
                              SizedBox(height: 128),
                            ]),
                          )),
                    ),
                  ),
                  if (_isSubmitting)
                    Container(color: Colors.grey.withValues(alpha: 0.2)),
                ],
              ),
      ),
    );
  }

  Widget _lineCalendarItemBuilder(
      BuildContext context, FLineCalendarItemData state, Widget? child) {
    final localizations = FLocalizations.of(context) ?? FDefaultLocalizations();
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: state.focused
                ? state.itemStyle.focusedDecoration
                : state.itemStyle.decoration,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle.merge(
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style:
                        state.itemStyle.weekdayTextStyle.copyWith(fontSize: 10),
                    child: Text(localizations.abbreviatedMonth(state.date)),
                  ),
                  SizedBox(height: state.style.itemContentSpacing),
                  DefaultTextStyle.merge(
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: state.itemStyle.dateTextStyle.copyWith(fontSize: 14),
                    child: Text(localizations.day(state.date)),
                  ),
                  SizedBox(height: state.style.itemContentSpacing),
                  DefaultTextStyle.merge(
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style:
                        state.itemStyle.weekdayTextStyle.copyWith(fontSize: 8),
                    child: Text(
                        localizations.shortWeekDays[state.date.weekday % 7]),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.today)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: state.itemStyle.todayIndicatorColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLineCalendar(FCalendarController<DateTime?> controller,
      {DateTime? start}) {
    final now = DateTime.now();
    return SizedBox(
      height: 50,
      child: FLineCalendar(
        controller: controller,
        initialDateAlignment: AlignmentDirectional.center,
        cacheExtent: 100,
        today: start ?? now,
        start: start ?? now,
        end: DateTime(now.year, now.month, now.day + 999 - 1),
        builder: _lineCalendarItemBuilder,
      ),
    );
  }

  Widget _buildTimeSelector(int value, void Function(int) onChange) {
    return SizedBox(
      height: 50,
      child: NumberPicker(
          minValue: 0,
          maxValue: 23,
          itemWidth: 50,
          itemHeight: 20,
          itemCount: 3,
          zeroPad: true,
          textMapper: (v) => '$v时',
          textStyle: TextStyle(
              fontSize: 12, color: Colors.grey.withValues(alpha: 0.5)),
          selectedTextStyle: TextStyle(fontSize: 14),
          value: value,
          onChanged: onChange),
    );
  }

  int _calculateDays() {
    final start =
        DateTime(_beginDate.year, _beginDate.month, _beginDate.day, _beginTime);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime);
    final diff = end.difference(start);
    return (diff.inMilliseconds / 1000 / 60 / 60 / 24).abs().round();
  }

  Widget _buildLocationSelect(FSelectGroupController<int> controller,
      Map<int, String> data, String hint) {
    return FSelectMenuTile.builder(
      groupController: controller,
      title: const Empty(),
      count: data.length,
      menuTileBuilder: (context, index) {
        final code = data.keys.toList()[index];
        final name = data[code]!;
        return FSelectTile(title: Text(name), value: code);
      },
      details: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final code = controller.values.firstOrNull;
            final name = data[code];
            return Center(
                child: Text(
              name ?? hint,
              style: TextStyle(
                color: name == null ? null : context.theme.colorScheme.primary,
              ),
            ));
          }),
      autoHide: true,
      maxHeight: 200,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (values) => values?.isEmpty ?? true ? '请选择一个正确的地址' : null,
    );
  }

  Widget _buildInformationColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: joinGap(gap: 10, axis: Axis.vertical, widgets: [
        Row(
          children: [
            Text('请假时间', style: ts),
            Spacer(),
            Text('共${_calculateDays()}天', style: ts.copyWith(fontSize: 14)),
          ],
        ),
        Row(
          children: joinGap(gap: 8, axis: Axis.vertical, widgets: [
            Text('始', style: ts),
            Expanded(flex: 4, child: _buildLineCalendar(_beginDateController)),
            Expanded(
                flex: 1,
                child: _buildTimeSelector(
                    _beginTime, (value) => setState(() => _beginTime = value)))
          ]),
        ),
        Row(
          children: joinGap(gap: 8, axis: Axis.vertical, widgets: [
            Text('终', style: ts),
            Expanded(
                flex: 4,
                child: _buildLineCalendar(_endDateController,
                    start: _beginDateController.value)),
            Expanded(
                flex: 1,
                child: _buildTimeSelector(
                    _endTime, (value) => setState(() => _endTime = value)))
          ]),
        ),
        FSelectMenuTile.builder(
          groupController: _typeSelectController,
          scrollController: ScrollController(),
          // label: Text('请假事由类型', style: ts),
          count: LeaveType.values.length,
          maxHeight: 200,
          menuTileBuilder: (context, index) {
            final type = LeaveType.values[index];
            return FSelectTile(
              title: Text(type.name),
              value: type,
              suffixIcon: FIcon(type.icon),
            );
          },
          title: Text('请假事由类型', style: ts),
          details: ListenableBuilder(
              listenable: _typeSelectController,
              builder: (context, _) => Text(
                  (_typeSelectController.values.firstOrNull ??
                          LeaveType.seekJob)
                      .name)),
          autoHide: true,
        ),
        FTextField.multiline(
          controller: _thingController,
          maxLines: 4,
          // label: Text('请假事由（选填）', style: ts),
          hint: '详细的请假事由（选填）',
        ),
        Text('地点', style: ts),
        Row(
          children: joinGap(gap: 8, axis: Axis.horizontal, widgets: [
            Expanded(
                child: _buildLocationSelect(
                    _provinceSelectController, _provinces, '省')),
            Expanded(
                child:
                    _buildLocationSelect(_citySelectController, _cities, '市')),
            Expanded(
                child: _buildLocationSelect(
                    _countySelectController, _counties, '区'))
          ]),
        ),
        FTextField(
          controller: _addressController,
          maxLines: 1,
          hint: '详细地点（必填）',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => (value?.isContentEmpty ?? true) ? '不可为空' : null,
        ),
        Row(
          children: joinGap(gap: 8, axis: Axis.horizontal, widgets: [
            Expanded(
                child: FCheckbox(
              label: Text('我已告知家长', style: ts),
              value: _tellParent,
              onChange: (value) => setState(() => _tellParent = value),
            )),
            Expanded(
                child: FTextField(
              controller: _alongWithNumController,
              maxLines: 1,
              hint: '同行人数（必填）',
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => (value?.isContentEmpty ?? true)
                  ? '不可为空'
                  : numberOnly(value ?? '')
                      ? null
                      : '只能输入数字',
            ))
          ]),
        )
      ]),
    );
  }

  Widget _buildParentInformationColumn() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: joinGap(gap: 10, axis: Axis.vertical, widgets: [
          Text('家长或监护人信息', style: ts),
          FTextField(
            controller: _parentNameController,
            maxLines: 1,
            hint: '姓名（选填）',
          ),
          FTextField(
            controller: _parentPhoneController,
            maxLines: 1,
            hint: '联系电话（选填）',
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => numberOnly(value ?? '') ? null : '只能输入数字',
          ),
        ]));
  }

  Widget _buildOutInformationColumn() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: joinGap(gap: 10, axis: Axis.vertical, widgets: [
          Text('外出联系人信息', style: ts),
          FTextField(
            controller: _outTelController,
            maxLines: 1,
            hint: '固定电话（必填，无电话可填“无”）',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                (value?.isContentEmpty ?? true) ? '不可为空，如无电话请填“无”' : null,
          ),
          FTextField(
            controller: _outPhoneController,
            maxLines: 1,
            hint: '移动电话（必填）',
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => (value?.isContentEmpty ?? true)
                ? '不可为空'
                : numberOnly(value ?? '')
                    ? null
                    : '只能输入数字',
          ),
          Row(
            children: joinGap(gap: 8, axis: Axis.horizontal, widgets: [
              Expanded(
                  child: FTextField(
                      controller: _outRelationController,
                      maxLines: 1,
                      hint: '与本人关系（必填）',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          (value?.isContentEmpty ?? true) ? '不可为空' : null)),
              Expanded(
                  child: FTextField(
                      controller: _outNameController,
                      maxLines: 1,
                      hint: '联系人姓名（必填）',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          (value?.isContentEmpty ?? true) ? '不可为空' : null)),
            ]),
          )
        ]));
  }

  Widget _buildSelfInformationColumn() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: joinGap(gap: 10, axis: Axis.vertical, widgets: [
          Text('本人联系方式', style: ts),
          FTextField(
            controller: _selfPhoneController,
            maxLines: 1,
            hint: '本人电话（选填）',
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => numberOnly(value ?? '') ? null : '只能输入数字',
          ),
          FTextField(
            controller: _selfOtherTelController,
            maxLines: 1,
            hint: '其他联系方式（选填）',
          ),
          Text('往返时间', style: ts),
          Row(
            children: joinGap(gap: 8, axis: Axis.horizontal, widgets: [
              Text('往', style: ts),
              Expanded(
                  flex: 8,
                  child: Column(
                    children: joinGap(gap: 8, axis: Axis.vertical, widgets: [
                      Row(
                        children: [
                          Expanded(
                              flex: 4,
                              child: _buildLineCalendar(_goDateController)),
                          Expanded(
                              flex: 1,
                              child: _buildTimeSelector(_goTime,
                                  (value) => setState(() => _goTime = value)))
                        ],
                      ),
                      FSelectMenuTile.builder(
                        groupController: _goVehicleTypeController,
                        scrollController: ScrollController(),
                        menuAnchor: Alignment.bottomRight,
                        tileAnchor: Alignment.topRight,
                        count: VehicleType.values.length,
                        maxHeight: 200,
                        menuTileBuilder: (context, index) {
                          final type = VehicleType.values[index];
                          return FSelectTile(
                            title: Text(type.name),
                            value: type,
                            suffixIcon: FIcon(type.icon),
                          );
                        },
                        title: Text('交通工具', style: ts),
                        details: ListenableBuilder(
                            listenable: _goVehicleTypeController,
                            builder: (context, _) => Text(
                                (_goVehicleTypeController.values.firstOrNull ??
                                        VehicleType.car)
                                    .name)),
                        autoHide: true,
                      ),
                    ]),
                  ))
            ]),
          ),
          Row(
            children: joinGap(gap: 8, axis: Axis.horizontal, widgets: [
              Text('返', style: ts),
              Expanded(
                  flex: 8,
                  child: Column(
                    children: joinGap(gap: 8, axis: Axis.vertical, widgets: [
                      Row(
                        children: [
                          Expanded(
                              flex: 4,
                              child: _buildLineCalendar(_backDateController)),
                          Expanded(
                              flex: 1,
                              child: _buildTimeSelector(_backTime,
                                  (value) => setState(() => _backTime = value)))
                        ],
                      ),
                      FSelectMenuTile.builder(
                        groupController: _backVehicleTypeController,
                        scrollController: ScrollController(),
                        count: VehicleType.values.length,
                        maxHeight: 200,
                        menuTileBuilder: (context, index) {
                          final type = VehicleType.values[index];
                          return FSelectTile(
                            title: Text(type.name),
                            value: type,
                            suffixIcon: FIcon(type.icon),
                          );
                        },
                        title: Text('交通工具', style: ts),
                        details: ListenableBuilder(
                            listenable: _backVehicleTypeController,
                            builder: (context, _) => Text(
                                (_backVehicleTypeController
                                            .values.firstOrNull ??
                                        VehicleType.car)
                                    .name)),
                        autoHide: true,
                      ),
                    ]),
                  ))
            ]),
          )
        ]));
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final days = _calculateDays();
    final provinceCode = _provinceSelectController.values.first;
    final cityCode = _citySelectController.values.first;
    final countyCode = _countySelectController.values.first;
    final province = areaData[provinceCode]!['_']! as String;
    final city =
        (areaData[provinceCode]![cityCode]! as Map<Object, String>)['_']!;
    final county = (areaData[provinceCode]![cityCode]!
        as Map<Object, String>)[countyCode]!;
    final area = '${provinceCode.padL2}${cityCode.padL2}${countyCode.padL2}';
    final where = '$province$city$county';
    final options = DailyLeaveOptions(
        action: widget.action,
        leaveBeginDate: _beginDate,
        leaveBeginTime: _beginTime,
        leaveEndDate: _endDate,
        leaveEndTime: _endTime,
        leaveNumNo: days > 999 ? 999 : days,
        leaveType:
            _typeSelectController.values.firstOrNull ?? LeaveType.seekJob,
        leaveThing: _thingController.text,
        area: area,
        comeWhere1: where,
        outAddress: _addressController.text,
        isTellRbl: _tellParent,
        withNumNo: int.tryParse(_alongWithNumController.text) ?? 0,
        jhrName: _parentNameController.text,
        jhrPhone: _parentPhoneController.text,
        outTel: _outTelController.text,
        outMoveTel: _outPhoneController.text,
        relation: _outRelationController.text,
        outName: _outNameController.text,
        stuMoveTel: _selfPhoneController.text,
        stuOtherTel: _selfOtherTelController.text,
        goDate: _goDate,
        goTime: _goTime,
        goVehicle:
            _goVehicleTypeController.values.firstOrNull ?? VehicleType.car,
        backDate: _backDate,
        backTime: _backTime,
        backVehicle:
            _backVehicleTypeController.values.firstOrNull ?? VehicleType.car);
    await _submitLeave(options);
    setState(() => _isSubmitting = false);
  }

  Future<void> _submitLeave(DailyLeaveOptions options) async {
    final service = GlobalService.soaService;
    if (service == null) {
      showErrorToast(context, '内部错误，请重启应用');
      return;
    }

    final result = await service.saveDailyLeave(options);
    if (result.status == Status.ok) {
      if (mounted) {
        showSuccessToast(
            context,
            switch (widget.action) {
              DailyLeaveAction.add => '请假成功',
              DailyLeaveAction.edit => '修改请假成功'
            });
      }

      widget.onSaveDailyLeave(options);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    if (!mounted) return;
    showErrorToast(context, result.value ?? '未知错误');
  }
}
