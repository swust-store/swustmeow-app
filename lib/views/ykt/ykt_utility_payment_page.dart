import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/entity/ykt/ykt_card.dart';
import 'package:swustmeow/entity/ykt/ykt_pay_app.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/views/ykt/pay/ykt_electricity_pay_page.dart';

class YKTUtilityPaymentPage extends StatefulWidget {
  final List<YKTCard> cards;

  const YKTUtilityPaymentPage({
    super.key,
    required this.cards,
  });

  @override
  State<YKTUtilityPaymentPage> createState() => _YKTUtilityPaymentPageState();
}

class _YKTUtilityPaymentPageState extends State<YKTUtilityPaymentPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isRefreshing = false;
  List<YKTPayApp> _payApps = [];
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadPayApps();
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadPayApps() async {
    setState(() {
      _isLoading = true;
      _isRefreshing = true;
      _refreshAnimationController.repeat();
    });

    try {
      if (GlobalService.yktService == null) {
        if (!mounted) return;
        showErrorToast(context, '本地服务未启动，请重启 APP');
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _refreshAnimationController.stop();
          _refreshAnimationController.reset();
        });
        return;
      }

      final appsResult = await GlobalService.yktService!.getPayApps();
      if (appsResult.status != Status.ok) {
        if (!mounted) return;
        showErrorToast(context, appsResult.value ?? '未知错误');
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _refreshAnimationController.stop();
          _refreshAnimationController.reset();
        });
        return;
      }

      List<YKTPayApp> apps = (appsResult.value as List<dynamic>).cast();
      setState(() {
        _payApps = apps;
        _isLoading = false;
        _isRefreshing = false;
        _refreshAnimationController.stop();
        _refreshAnimationController.reset();
      });
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, '加载失败：$e');
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _refreshAnimationController.stop();
        _refreshAnimationController.reset();
      });
    }
  }

  void _onRefresh() {
    _loadPayApps();
  }

  // 根据应用名称获取图标
  IconData _getIconForApp(String appName) {
    switch (appName) {
      case '电费':
        return FontAwesomeIcons.bolt;
      case '水费':
        return FontAwesomeIcons.droplet;
      case '维修赔偿费':
        return FontAwesomeIcons.wrench;
      default:
        return FontAwesomeIcons.moneyBill;
    }
  }

  // 根据应用名称获取颜色
  Color _getColorForApp(String appName) {
    switch (appName) {
      case '电费':
        return Colors.orange;
      case '水费':
        return Colors.blue;
      case '维修赔偿费':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // 处理特定支付应用
  void _handlePayApp(YKTPayApp app) {
    // 电费缴费特殊处理
    if (app.name == '电费') {
      pushTo(
        context,
        YKTElectricityPayPage(
          cards: widget.cards,
          payApp: app,
        ),
      );
      return;
    }

    // 其他应用
    showSuccessToast(context, '${app.name}功能即将上线');
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
            '生活缴费',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          suffixIcons: [
            Stack(
              children: [
                IconButton(
                  onPressed: _onRefresh,
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
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: MTheme.primary2,
                      ),
                      SizedBox(height: 16),
                      Text('正在加载缴费应用...'),
                    ],
                  ),
                )
              : _payApps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.fileCircleExclamation,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            '暂无可用的缴费应用',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '请稍后再试或联系管理员',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Material(
                      color: Colors.transparent,
                      child: _buildPayAppsList(),
                    ),
        ),
      ),
    );
  }

  Widget _buildPayAppsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _payApps.length,
      itemBuilder: (context, index) {
        final app = _payApps[index];
        final iconData = _getIconForApp(app.name);
        final iconColor = _getColorForApp(app.name);

        return GestureDetector(
          onTap: () => _handlePayApp(app),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(MTheme.radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(MTheme.radius),
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '点击进入支付',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
