import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/leave/leave_thing_information.dart';
import 'package:swustmeow/components/leave/leave_time_information.dart';
import 'package:swustmeow/components/leave/leave_go_back_information.dart';
import 'package:swustmeow/components/leave/leave_location_information.dart';
import 'package:swustmeow/components/leave/leave_out_information.dart';
import 'package:swustmeow/components/leave/leave_parent_information.dart';
import 'package:swustmeow/components/leave/leave_self_information.dart';
import 'package:swustmeow/components/utils/pop_receiver.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_action.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_options.dart';
import 'package:swustmeow/entity/soa/leave/leave_value_provider.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/widget.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../components/utils/empty.dart';
import '../../data/m_theme.dart';
import '../../services/boxes/soa_box.dart';
import '../../services/value_service.dart';

class SOADailyLeavePage extends StatefulWidget {
  const SOADailyLeavePage({
    super.key,
    required this.action,
    this.template,
    this.leaveId,
    required this.onSaveDailyLeave,
    required this.onDeleteDailyLeave,
    required this.onRefresh,
  });

  final DailyLeaveAction action;
  final DailyLeaveOptions? template;
  final String? leaveId;
  final Function(DailyLeaveOptions options) onSaveDailyLeave;
  final Function(DailyLeaveOptions options) onDeleteDailyLeave;
  final Function() onRefresh;

  @override
  State<StatefulWidget> createState() => _SOADailyLeavePageState();
}

class _SOADailyLeavePageState extends State<SOADailyLeavePage> {
  final _formKey = GlobalKey<FormState>();
  late DailyLeaveAction _currentAction;
  WebUri? _url;
  DailyLeaveOptions? _options;
  bool _isSubmitting = false;
  bool _isLoading = true;
  InAppWebViewController? _webViewController;
  bool _isWebViewLoading = true;
  String? _extraValidatorMessage;
  final Map<String, dynamic> _template = {};

  @override
  void initState() {
    super.initState();
    _currentAction = widget.action;
    _load();
  }

  Future<void> _load() async {
    if (widget.leaveId != null && widget.template == null) {
      await _loadOptions();
    }

    if (widget.template != null) {
      _options = widget.template;
    }

    await _loadWebView();

    _refresh(() => _isLoading = false);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  Future<void> _loadOptions() async {
    final id = widget.leaveId!;
    if (!mounted) return;
    final result = await GlobalService.soaService?.getDailyLeaveInformation(id);
    if (result == null || result.status != Status.ok) {
      if (mounted) showErrorToast(context, '无法加载请假信息');
      return;
    }
    final o = result.value! as DailyLeaveOptions;
    _refresh(() {
      _options = o;
      _isLoading = false;
    });
  }

  Future<void> _loadWebView() async {
    final service = GlobalService.soaService;
    if (service == null) return;

    final api = service.api;
    if (api == null) return;

    final tgcResult = await service.checkLogin();
    if (tgcResult.status != Status.ok) return; // TODO 处理 notAuthorized 自动登录

    final xscResult = await api.loginToXSC(tgcResult.value!);
    if (xscResult.status != Status.ok) return; // TODO 处理 notAuthorized 自动登录

    final base =
        'http://xsc.swust.edu.cn/Sys/SystemForm/Leave/StuAllLeaveManage_Edit.aspx';

    final cookies = await api.getCookies(Uri.parse(base));

    // Map<String, String> processEncodedEditParams() {
    //   // 以下算法来自学工系统 JavaScript
    //   final s1 = randomInt(9);
    //   final salt1 = md5.convert(utf8.encode('$s1')).toString().toLowerCase();
    //   final salt2 = randomBetween(1, 9999).toString().padLeft(4, '0');
    //   return {
    //     'Status': 'RWRpdA;;', // == (base64('Edit') + ';;')  但不知为何编码后有尾缀 `==`
    //     'Id': '${base64.encode(utf8.encode(widget.leaveId ?? ''))}$salt1$salt2'
    //   };
    // }

    final cookieManager = CookieManager.instance();

    final uri = Uri.http(
      'xsc.swust.edu.cn',
      '/Sys/SystemForm/Leave/StuAllLeaveManage_Edit.aspx',
      switch (widget.action) {
        DailyLeaveAction.add => {'Status': 'Add'},
        DailyLeaveAction.edit || DailyLeaveAction.delete => {
            'Status': 'Edit',
            'Id': widget.leaveId ?? ''
          }
        // processEncodedEditParams()
      },
    );
    final url = WebUri.uri(uri);

    for (final cookie in cookies) {
      await cookieManager.setCookie(
          url: url, name: cookie.name, value: cookie.value);
    }

    _refresh(() => _url = url);
  }

  void _stop() {
    _webViewController?.dispose();
    _webViewController = null;
  }

  Future<void> _setFieldValue(String id, String value) async {
    if (_webViewController == null) return;
    await _runJs('''
      var field = document.querySelector('#$id');
      field.value = '$value';
    ''');
  }

  Future<void> _setSelectValue(String id, String value) async {
    if (_webViewController == null) return;
    await _runJs('''
      var select = document.querySelector('#$id');
      select.value = '$value';
      select.onchange();
    ''');
  }

  Future<void> _setTableCheckValue(String id, String value) async {
    if (_webViewController == null) return;
    await _runJs('''
      var table = document.querySelector('#$id');
      var inputs = Array.from(table.querySelectorAll('tbody > tr > td > input'));
      var option = inputs.filter((c) => c.value === '$value')[0];
      var checked = inputs.filter((c) => c.getAttribute('checked' === 'checked'));
      
      if (checked.length !== 0) {
        for (var checkedElement of checked) {
          checkedElement.removeAttribute('checked');
        }
      }
      
      option.setAttribute('checked', 'checked');
    ''');
  }

  Future<void> _setSpanCheckValue(String id, String value) async {
    await _runJs('''
      var span = document.querySelector('#$id');
      var inputs = Array.from(span.querySelectorAll('input'));
      var option = inputs.filter((c) => c.value === '$value')[0];
      option.click();
    ''');
  }

  Future<void> _runJs(String source) async {
    if (_webViewController == null) return;
    await _webViewController!.evaluateJavascript(source: source);
  }

  void _setValidatorMessage(String? message) {
    _refresh(() => _extraValidatorMessage = message);
  }

  void _setTemplateValue(String key, dynamic value) {
    _template[key] = value;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopReceiver(
      onPop: widget.onRefresh,
      child: Stack(
        children: [
          _isLoading || _url == null
              ? const Empty()
              : InAppWebView(
                  initialUrlRequest: URLRequest(url: _url),
                  initialSettings: InAppWebViewSettings(
                    userAgent:
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/132.0.0.0',
                  ),
                  onLoadStart: (controller, _) =>
                      _webViewController = controller,
                  onLoadStop: (controller, _) =>
                      _refresh(() => _isWebViewLoading = false),
                  onJsAlert: (controller, request) async {
                    await _onAlert(request);
                    return JsAlertResponse(handledByClient: true);
                  },
                  onJsConfirm: (controller, request) async {
                    final title = request.message;
                    bool? r = await showAdaptiveDialog(
                      context: context,
                      builder: (context) => FDialog(
                        direction: Axis.horizontal,
                        title: Text(title ?? '确认操作？'),
                        body: SizedBox(height: 12.0),
                        actions: [
                          FButton(
                              style: FButtonStyle.outline,
                              onPress: () {
                                Navigator.of(context).pop(false);
                                _refresh(() => _isSubmitting = false);
                              },
                              label: Text('取消')),
                          FButton(
                            onPress: () => Navigator.of(context).pop(true),
                            label: Text('确定'),
                          ),
                        ],
                      ),
                    );
                    return JsConfirmResponse(
                      handledByClient: true,
                      action: r == true
                          ? JsConfirmResponseAction.CONFIRM
                          : JsConfirmResponseAction.CANCEL,
                    );
                  },
                  onCloseWindow: (_) => _stop(),
                ),
          Opacity(
            opacity: 1,
            child: Transform.flip(
              flipX: ValueService.isFlipEnabled.value,
              flipY: ValueService.isFlipEnabled.value,
              child: BasePage.gradient(
                headerPad: false,
                header: BaseHeader(
                  title: Text(
                    switch (widget.action) {
                      DailyLeaveAction.add => '新增日常请假',
                      _ => '编辑日常请假'
                    },
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                content: _isLoading || _isWebViewLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: MTheme.primary2))
                    : Stack(
                        children: [
                          IgnorePointer(
                            ignoring: _isSubmitting,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: _buildForm(),
                            ),
                          ),
                          if (_isSubmitting)
                            Container(
                                color: Colors.grey.withValues(alpha: 0.2)),
                        ],
                      ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 32,
            child: Row(
              children: joinGap(gap: 16, axis: Axis.horizontal, widgets: [
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: MTheme.primary2,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (_isSubmitting) return;
                    _refresh(() => _currentAction = widget.action);
                    await _submit();
                  },
                  child: FaIcon(
                    FontAwesomeIcons.solidFloppyDisk,
                    color: _isSubmitting ? Colors.grey : Colors.white,
                    size: 22,
                  ),
                ),
                if (widget.action != DailyLeaveAction.add)
                  FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.red,
                    onPressed: () async {
                      if (_isSubmitting) return;
                      _currentAction = DailyLeaveAction.delete;
                      await _submit();
                    },
                    child: FaIcon(
                      FontAwesomeIcons.solidTrashCan,
                      color: _isSubmitting ? Colors.grey : Colors.white,
                      size: 22,
                    ),
                  )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final ts = TextStyle(
      fontSize: 16,
      color: _isSubmitting ? Colors.grey : context.theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
    final ts2 = TextStyle(
      fontSize: 12,
      color: Colors.grey,
      fontWeight: FontWeight.w500,
    );

    final provider = LeaveValueProvider(
      leaveId: widget.leaveId,
      isLoading: _isLoading || _isWebViewLoading,
      options: _options,
      ts: ts,
      ts2: ts2,
      buildLineCalendar: _buildLineCalendar,
      buildTimeSelector: _buildTimeSelector,
      runJs: _runJs,
      setFieldValue: _setFieldValue,
      setSelectValue: _setSelectValue,
      setTableCheckValue: _setTableCheckValue,
      setSpanCheckValue: _setSpanCheckValue,
      setValidatorMessage: _setValidatorMessage,
      setTemplateValue: _setTemplateValue,
    );

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: joinGap(
            gap: 16,
            axis: Axis.vertical,
            widgets: [
              LeaveTimeInformation(provider: provider),
              LeaveThingInformation(provider: provider),
              LeaveLocationInformation(provider: provider),
              LeaveParentInformation(provider: provider),
              LeaveOutInformation(provider: provider),
              LeaveSelfInformation(provider: provider),
              LeaveGoBackInformation(provider: provider),
              SizedBox(),
              FButton(
                onPress: _saveAsTemplate,
                label: Text('存为模板'),
              ),
              SizedBox(height: 82),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAsTemplate() async {
    if (_webViewController == null) return;
    final options = DailyLeaveOptions.fromJson(_template);
    await SOABox.put('leaveTemplate', options);
    if (!mounted) return;
    showSuccessToast(context, '保存成功！');
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

  Widget _buildLineCalendar(FCalendarController<DateTime?>? controller,
      {DateTime? start}) {
    final now = DateTime.now();
    if (controller == null) return const Empty();
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

  Future<void> _submit() async {
    if (_webViewController == null) return;

    if (_extraValidatorMessage != null) {
      showErrorToast(context, _extraValidatorMessage!);
      return;
    }

    _refresh(() => _isSubmitting = true);
    Future.delayed(Duration(seconds: 5), () {
      if (_isSubmitting && mounted) {
        showErrorToast(context, '提交失败');
        _refresh(() => _isSubmitting = false);
      }
    });

    switch (_currentAction) {
      case DailyLeaveAction.add:
      case DailyLeaveAction.edit:
        await _runJs('''
          var saveButton = document.querySelector('#Save');
          saveButton.click();
        ''');
        return;
      case DailyLeaveAction.delete:
        await _runJs('''
          var deleteButton = document.querySelector('#Del');
          deleteButton.click();
        ''');
        return;
    }
  }

  Future<void> _onAlert(JsAlertRequest request) async {
    final message = request.message;
    if (message == null || message.isEmpty) return;

    if (message.contains('成功')) {
      showSuccessToast(
          context,
          switch (_currentAction) {
            DailyLeaveAction.add => '请假成功',
            DailyLeaveAction.edit => '修改请假成功',
            DailyLeaveAction.delete => '撤销请假成功'
          });

      switch (_currentAction) {
        case DailyLeaveAction.add:
        case DailyLeaveAction.edit:
          widget.onSaveDailyLeave(_options!);
          break;
        case DailyLeaveAction.delete:
          widget.onDeleteDailyLeave(_options!);
          break;
      }
    } else {
      showErrorToast(context, message);
    }

    _refresh(() => _isSubmitting = false);
    Navigator.of(context).pop();
  }
}
