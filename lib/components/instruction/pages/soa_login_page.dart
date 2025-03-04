import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/instruction/button_state.dart';
import 'package:swustmeow/components/instruction/pages/login_page.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/services/umeng_service.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../../data/m_theme.dart';
import '../../../services/boxes/soa_box.dart';
import '../../../services/global_service.dart';
import '../../../utils/common.dart';
import '../../../utils/router.dart';
import '../../../utils/status.dart';
import '../../../utils/text.dart';
import '../../../views/agreements/privacy_page.dart';
import '../../../views/agreements/tos_page.dart';
import '../../icon_text_field.dart';

class SOALoginPage extends LoginPage {
  const SOALoginPage({
    super.key,
    required super.sc,
    required super.onStateChange,
    required super.onComplete,
    required super.onlyThis,
  });

  @override
  State<StatefulWidget> createState() => _SOALoginPageState();
}

class _SOALoginPageState extends State<SOALoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  bool _remember = false;
  bool _isAgreedAgreements = false;
  late AnimationController _agreementController;
  bool _userInteracted = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
    _agreementController = AnimationController(vsync: this);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  Future<void> _loadRemembered() async {
    final username = SOABox.get('username') as String?;
    final password = SOABox.get('password') as String?;
    final remember = (SOABox.get('remember') as bool?) ?? false;

    if (remember) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refresh(() {
          _remember = remember;
          if (username != null) _usernameController.text = username;
          if (password != null) _passwordController.text = password;
          widget.onStateChange(ButtonStateContainer(ButtonState.ok,
              withCaptcha: widget.sc.withCaptcha, captcha: widget.sc.captcha));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    validate() {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final captcha = _captchaController.text;

      if (username.length != 10 || !numberOnly(username)) {
        return ButtonStateContainer(
          ButtonState.dissatisfied,
          message: '请输入十位数字学号',
          withCaptcha: widget.sc.withCaptcha,
          captcha: widget.sc.captcha,
        );
      }

      if (password.trim().isEmpty) {
        return ButtonStateContainer(
          ButtonState.dissatisfied,
          message: '请输入密码',
          withCaptcha: widget.sc.withCaptcha,
          captcha: widget.sc.captcha,
        );
      }

      if (widget.sc.withCaptcha == true && captcha.trim().length != 4) {
        return ButtonStateContainer(
          ButtonState.dissatisfied,
          message: '请输入四位验证码',
          withCaptcha: widget.sc.withCaptcha,
          captcha: widget.sc.captcha,
        );
      }

      return ButtonStateContainer(
        ButtonState.ok,
        withCaptcha: widget.sc.withCaptcha,
        captcha: widget.sc.captcha,
      );
    }

    onChange() {
      final sc = validate();
      widget.onStateChange(sc);
    }

    final checkBoxStyle = context.theme.checkboxStyle.copyWith(
      labelLayoutStyle: context.theme.checkboxStyle.labelLayoutStyle.copyWith(
        labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
        descriptionPadding: EdgeInsets.symmetric(horizontal: 8.0),
        errorPadding: EdgeInsets.symmetric(horizontal: 8.0),
        childPadding: EdgeInsets.zero,
      ),
    );

    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '登录到西科大一站式服务',
            style: TextStyle(fontSize: 14),
          ),
          IconTextField(
            icon: FIcon(FAssets.icons.user),
            controller: _usernameController,
            hint: '请输入学号',
            autofocus: false,
            onChange: (_) => onChange(),
          ),
          IconTextField.password(
            icon: FIcon(FAssets.icons.lock),
            controller: _passwordController,
            label: null,
            hint: '请输入密码',
            autofocus: false,
            onChange: (_) => onChange(),
            obscureText: !_showPassword,
            suffixBuilder: (context, style, child) {
              return FTappable(
                onPress: () => setState(() => _showPassword = !_showPassword),
                child: FIcon(
                  _showPassword ? FAssets.icons.eye : FAssets.icons.eyeClosed,
                ),
              );
            },
          ),
          if (widget.sc.withCaptcha == true)
            CaptchaInput(
              captchaBase64: widget.sc.captcha as String,
              captchaController: _captchaController,
              onChange: onChange,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, 4),
                child: FIcon(
                  FAssets.icons.info,
                  size: 16,
                  alignment: Alignment.centerRight,
                  allowDrawingOutsideViewBox: true,
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
              const Expanded(
                child: Text(
                  '用于课表获取和账号统一管理',
                  style: TextStyle(fontSize: 14),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          FCheckbox(
            label: const Text('记住账号和密码'),
            description: const Text(
              '下次登录时可自动填充',
              style: TextStyle(fontSize: 12),
            ),
            value: _remember,
            onChange: (value) => setState(() => _remember = value),
            style: checkBoxStyle,
          ),
          FCheckbox(
            style: checkBoxStyle,
            label: RichText(
              text: TextSpan(
                text: '我已阅读并同意',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '《用户协议》',
                    style: TextStyle(color: MTheme.primary2),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        pushTo(context, TOSPage());
                        setState(() {});
                      },
                  ),
                  const TextSpan(
                    text: '与',
                  ),
                  TextSpan(
                    text: '《隐私政策》',
                    style: TextStyle(color: MTheme.primary2),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        pushTo(context, PrivacyPage());
                        setState(() {});
                      },
                  ),
                ],
              ),
            ),
            value: _isAgreedAgreements,
            onChange: (value) {
              setState(() => _isAgreedAgreements = value);
            },
          )
              .animate(
                  controller: _agreementController,
                  onPlay: (controller) {
                    if (!_userInteracted || _isAgreedAgreements) {
                      controller.stop();
                    }
                  })
              .shakeX(
                hz: 3,
                amount: 8,
                duration: Duration(milliseconds: 500),
              ),
          !Values.showcaseMode
              ? _buildSubmitButton()
              : Row(
                  children: [
                    Expanded(child: _buildSubmitButton()),
                    const SizedBox(width: 16.0),
                    FButton(
                      onPress: () => widget.onComplete(),
                      label: const Text('跳过'),
                      style: FButtonStyle.ghost,
                    )
                  ],
                )
        ],
      ).wrap(context: context),
    );
  }

  Widget _buildSubmitButton() {
    final nextStepLabel = widget.onlyThis ? '完成' : '下一步 -->';
    return FButton(
      style: switch (widget.sc.state) {
        ButtonState.ok => FButtonStyle.primary,
        ButtonState.dissatisfied ||
        ButtonState.loading =>
          FButtonStyle.secondary,
        ButtonState.error => FButtonStyle.destructive,
      },
      onPress: () async {
        if (widget.sc.state == ButtonState.ok) {
          await _submit();
        }
      },
      label: Row(
        children: [
          if (widget.sc.state == ButtonState.loading) ...[
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
          ],
          widget.sc.state == ButtonState.ok
              ? Text(nextStepLabel)
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                      duration: 1.5.seconds,
                      delay: 0.5.seconds,
                      color: Colors.grey)
              : Text(
                  widget.sc.state == ButtonState.loading
                      ? '登录中'
                      : widget.sc.message ?? nextStepLabel,
                )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    _refresh(() => _userInteracted = true);

    final now = DateTime.now();
    final hour = now.hour;
    // 时间未知，假设为凌晨 2 点
    if (hour >= 0 && hour <= 2) {
      showWarningToast(context, '每日凌晨 0 时后一站式接口维护，不可登录，请在早晨重试!', seconds: 5);
      return;
    }

    if (!_isAgreedAgreements) {
      _agreementController.reset();
      _agreementController.forward();
      showErrorToast(context, '未勾选阅读并同意条款');
      return;
    }

    if (_isAgreedAgreements) {
      UmengService.initUmeng();
    }

    final username = _usernameController.text;
    final password = _passwordController.text;
    final manualCaptcha =
        widget.sc.withCaptcha == true ? _captchaController.text : null;

    if (username.isEmpty || password.isEmpty) {
      showErrorToast(context, '请输入账号和密码');
      return;
    }

    widget.onStateChange(
      ButtonStateContainer(
        ButtonState.loading,
        withCaptcha: widget.sc.withCaptcha,
        captcha: widget.sc.captcha,
      ),
    );

    if (GlobalService.soaService == null) {
      widget.onStateChange(
        ButtonStateContainer(
          ButtonState.error,
          message: '本地服务未启动，请重启 APP',
          withCaptcha: widget.sc.withCaptcha,
          captcha: widget.sc.captcha,
        ),
      );
      return;
    }

    final result = await GlobalService.soaService?.login(
      username: username,
      password: password,
      remember: _remember,
      manualCaptcha: manualCaptcha,
    );

    if (result == null) {
      widget.onStateChange(
        ButtonStateContainer(
          ButtonState.error,
          message: '登录失败',
          withCaptcha: widget.sc.withCaptcha,
          captcha: widget.sc.captcha,
        ),
      );
      if (mounted) showErrorToast(context, '登录失败');
      return;
    }

    if (result.status == Status.manualCaptchaRequired) {
      widget.onStateChange(
        ButtonStateContainer(
          ButtonState.dissatisfied,
          message: '请输入验证码',
          withCaptcha: true,
          captcha: result.value,
        ),
      );
      return;
    }

    if (result.status == Status.captchaFailed) {
      widget.onStateChange(
        ButtonStateContainer(
          ButtonState.dissatisfied,
          message: '验证码有误或过期，请重试',
          withCaptcha: true,
          captcha: result.value,
        ),
      );
      setState(() {});
      return;
    }

    if (result.status != Status.ok) {
      widget.onStateChange(
        ButtonStateContainer(
          ButtonState.error,
          message: result.value ?? '未知错误',
          withCaptcha: widget.sc.withCaptcha,
          captcha: widget.sc.captcha,
        ),
      );
      return;
    }

    widget.onStateChange(
      ButtonStateContainer(
        ButtonState.ok,
        withCaptcha: widget.sc.withCaptcha,
        captcha: widget.sc.captcha,
      ),
    );
    widget.onComplete();
  }
}

class CaptchaInput extends StatefulWidget {
  final String captchaBase64;
  final TextEditingController captchaController;
  final Function() onChange;

  const CaptchaInput({
    super.key,
    required this.captchaBase64,
    required this.captchaController,
    required this.onChange,
  });

  @override
  State<StatefulWidget> createState() => _CaptchaInputState();
}

class _CaptchaInputState extends State<CaptchaInput> {
  Widget? _captchaImage;
  String? _cachedBase64;

  @override
  void initState() {
    super.initState();
    update();
  }

  void update() {
    _cachedBase64 = widget.captchaBase64;
    _captchaImage = SizedBox(
      width: 90,
      height: 30,
      child: Image.memory(
        base64Decode(widget.captchaBase64),
        width: 90,
        height: 30,
        key: ValueKey(widget.captchaBase64),
      ),
    );
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.captchaBase64 != _cachedBase64) {
      _refresh(update);
    }

    return Row(
      children: joinGap(
        gap: 8,
        axis: Axis.horizontal,
        widgets: [
          Expanded(
            child: IconTextField(
              controller: widget.captchaController,
              icon: FIcon(FAssets.icons.shield),
              hint: '请输入验证码',
              onChange: (_) => widget.onChange(),
            ),
          ),
          _captchaImage!,
        ],
      ),
    );
  }
}
