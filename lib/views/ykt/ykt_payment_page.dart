import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:swustmeow/entity/ykt/ykt_card.dart';
import 'package:swustmeow/entity/ykt/ykt_card_account_info.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/status.dart';

class YKTPaymentPage extends StatefulWidget {
  final YKTCard card;
  final YKTCardAccountInfo account;

  const YKTPaymentPage({
    super.key,
    required this.card,
    required this.account,
  });

  @override
  State<YKTPaymentPage> createState() => _YKTPaymentPageState();
}

class _YKTPaymentPageState extends State<YKTPaymentPage>
    with SingleTickerProviderStateMixin {
  static const _refreshInterval = 60;
  int _remainingSeconds = _refreshInterval;
  Timer? _timer;
  String _barcode = '';
  late AnimationController _refreshAnimationController;
  bool _isRefreshing = false;
  List<String> _barcodes = [];
  int? _currentBarcodeIndex;

  @override
  void initState() {
    super.initState();
    ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isRefreshing = true;
      _refreshAnimationController.repeat();
    });

    await _getBarcodes();
    _onRefresh();
    _startTimer();
  }

  Future<void> _getBarcodes() async {
    final info = widget.account;
    final [account, payAccount] = info.type.split('-');
    final barcodesResult = await GlobalService.yktService
        ?.getBarCodes(account: account, payAccount: payAccount);
    if (barcodesResult == null || barcodesResult.status != Status.ok) {
      if (!mounted) return;
      showErrorToast(context, barcodesResult?.value ?? '无法获取支付码');
      return;
    }

    List<String> barcodes = (barcodesResult.value as List<dynamic>).cast();
    setState(() {
      _barcodes = barcodes;
    });
  }

  void _generatePayCode() {
    if (_currentBarcodeIndex == _barcodes.length ||
        _currentBarcodeIndex == null) {
      _currentBarcodeIndex = 0;
    }

    setState(() {
      _barcode = _barcodes[_currentBarcodeIndex!];
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _remainingSeconds = _refreshInterval;
          _onRefresh();
        }
      });
    });
  }

  void _onRefresh() async {
    setState(() {
      _remainingSeconds = _refreshInterval;
      if (_currentBarcodeIndex == null) {
        _currentBarcodeIndex = 0;
      } else {
        _currentBarcodeIndex = _currentBarcodeIndex! + 1;
      }
      _generatePayCode();
      _isRefreshing = false;
      _refreshAnimationController.stop();
      _refreshAnimationController.reset();
    });
  }

  @override
  void dispose() {
    ScreenBrightness.instance.resetApplicationScreenBrightness();
    _timer?.cancel();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '付款码',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          suffixIcons: [
            Stack(
              children: [
                IconButton(
                  onPressed: _load,
                  icon: RotationTransition(
                    turns: _refreshAnimationController,
                    child: FaIcon(
                      FontAwesomeIcons.rotateRight,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                if (_isRefreshing)
                  Positioned(
                    bottom: 5,
                    left: 20 / 2,
                    child: Text(
                      '刷新中...',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        content: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCardInfo(),
                _buildCodes(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MTheme.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            ]),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.card.color,
              radius: 24,
              child: FaIcon(
                FontAwesomeIcons.creditCard,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.card.cardName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${widget.account.name} · 余额: ¥${widget.account.balance}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodes() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MTheme.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: BarcodeWidget(
                    data: _barcode,
                    barcode: Barcode.code128(),
                    drawText: true,
                    width: double.infinity,
                    height: 100,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  width: 180,
                  child: BarcodeWidget(
                    data: _barcode,
                    barcode: Barcode.qrCode(),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(MTheme.radius),
                ),
                child: Text(
                  '$_remainingSeconds秒后刷新',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '请将付款码对准扫码设备',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}
