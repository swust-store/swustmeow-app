import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/entity/apaertment/apartment_student_info.dart';
import 'package:swustmeow/entity/apaertment/electricity_bill.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/math.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../services/boxes/apartment_box.dart';
import '../../services/value_service.dart';

class ApartmentPage extends StatefulWidget {
  const ApartmentPage({super.key});

  @override
  State<StatefulWidget> createState() => _ApartmentPageState();
}

class _ApartmentPageState extends State<ApartmentPage> {
  bool _isLogin = false;
  bool _isLoading = true;
  ElectricityBill? _electricityBill;
  ApartmentStudentInfo? _studentInfo;
  String? _qrCodeUrl;
  Widget? _qrCode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (GlobalService.apartmentService == null) return;
    _isLogin = GlobalService.apartmentService!.isLogin;
    if (!_isLogin) {
      _refresh(() => _isLoading = false);
      return;
    }

    await _loadElectricityBill();
    await _loadInfo().then((info) {
      if (info == null) return;

      _qrCodeUrl =
          'http://gydb.swust.edu.cn/AppApi/images/qrCode/${info.studentNumber}';
      _qrCode = _buildQRCode();
    });

    _refresh(() => _isLoading = false);
  }

  Future<void> _loadElectricityBill() async {
    final electricityBillResult =
        await GlobalService.apartmentService!.getElectricityBill();
    if (electricityBillResult.status == Status.ok) {
      _refresh(() =>
          _electricityBill = electricityBillResult.value as ElectricityBill);
    } else {
      if (!mounted) return;
      showErrorToast(context, '获取失败：${electricityBillResult.value}');
    }
  }

  Future<ApartmentStudentInfo?> _loadInfo() async {
    final cached = ApartmentBox.get('studentInfo') as ApartmentStudentInfo?;
    if (cached != null) {
      _refresh(() => _studentInfo = cached);
      return cached;
    }

    final result = await GlobalService.apartmentService!.getStudentInfo();
    if (result.status != Status.ok) {
      if (!mounted) return null;
      showErrorToast(context, '获取信息失败：${result.value}');
      return null;
    }

    final info = result.value as ApartmentStudentInfo;
    _refresh(() => _studentInfo = info);
    return info;
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  Future<void> _refreshQRCode() async {
    _refresh(() => _qrCode = _buildQRCodeLoading());
    final bytes =
        (await NetworkAssetBundle(Uri.parse(_qrCodeUrl!)).load(_qrCodeUrl!))
            .buffer
            .asUint8List();
    _refresh(() => _qrCode = Image.memory(bytes));
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
            '宿舍事务',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: _isLogin
            ? _buildContent()
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '未登录公寓服务',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    Text(
                      '请转到「设置」页面的「账号管理」选项进行登录',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.all(MTheme.radius),
      shrinkWrap: true,
      children: joinGap(
        gap: 12,
        axis: Axis.vertical,
        widgets: [
          if (_electricityBill != null || _isLoading)
            Skeletonizer(
              enabled: _isLoading,
              child: _buildCard(
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '寝室电费',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '寝室房间：${_electricityBill?.roomName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('${_electricityBill?.remaining.intOrDouble}元')
                  ],
                ),
              ),
            ),
          if (_studentInfo != null)
            _buildCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '个人二维码',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '有效期三分钟',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _refreshQRCode();
                        },
                        icon: FaIcon(FontAwesomeIcons.rotateRight),
                      ),
                    ],
                  ),
                  _qrCode ?? _buildQRCodeLoading(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQRCodeLoading() {
    final size = MediaQuery.of(context).size;
    final dimension = size.width - (4 * MTheme.radius);
    return SizedBox(
      width: dimension,
      height: dimension,
      child: Center(
        child: CircularProgressIndicator(
          color: MTheme.primary2,
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    return Image.network(
      _qrCodeUrl!,
      fit: BoxFit.fill,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return CircularProgressIndicator(color: MTheme.primary2);
      },
      errorBuilder: (context, child, err) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.circleExclamation,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                '加载失败',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MTheme.radius),
        border: Border.all(color: MTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
