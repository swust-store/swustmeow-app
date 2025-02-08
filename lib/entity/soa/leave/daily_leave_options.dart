import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_action.dart';
import 'package:swustmeow/entity/soa/leave/leave_type.dart';
import 'package:swustmeow/entity/soa/leave/vehicle_type.dart';
import 'package:swustmeow/utils/time.dart';

class DailyLeaveOptions {
  DailyLeaveOptions({
    required this.action,
    required this.leaveBeginDate,
    required this.leaveBeginTime,
    required this.leaveEndDate,
    required this.leaveEndTime,
    required this.leaveNumNo,
    required this.leaveType,
    required this.leaveThing,
    required this.area,
    required this.comeWhere1,
    required this.a1,
    required this.a2,
    required this.a3,
    required this.outAddress,
    required this.isTellRbl,
    required this.withNumNo,
    required this.jhrName,
    required this.jhrPhone,
    required this.outTel,
    required this.outMoveTel,
    required this.relation,
    required this.outName,
    required this.stuMoveTel,
    required this.stuOtherTel,
    required this.goDate,
    required this.goTime,
    required this.goVehicle,
    required this.backDate,
    required this.backTime,
    required this.backVehicle,
  });

  /// 请假操作
  DailyLeaveAction action;

  /// 请假开始日期
  final DateTime leaveBeginDate;

  /// 请假开始时
  final int leaveBeginTime;

  /// 请假结束日期
  final DateTime leaveEndDate;

  /// 请假结束时
  final int leaveEndTime;

  /// 一共请假多少天，范围 0~999
  final int leaveNumNo;

  /// 请假类型
  final LeaveType leaveType;

  /// 请假事由，可为空
  final String leaveThing;

  /// 地区代码
  final String area;

  /// 地区（由地区代码确定）
  final String comeWhere1;

  /// 省
  final String a1;

  /// 市
  final String a2;

  // 区
  final String a3;

  /// 详细地址，必填
  final String outAddress;

  /// 是否已告知家长
  final bool isTellRbl;

  /// 同行人数
  final int withNumNo;

  /// 家长或监护人姓名，可为空
  final String jhrName;

  /// 家长或监护人联系电话，可为空
  final String jhrPhone;

  /// 外出联系人固定电话，必填
  final String outTel;

  /// 外出联系人移动电话，必填
  final String outMoveTel;

  /// 外出联系人与本人关系，必填
  final String relation;

  /// 外出联系人姓名，必填
  final String outName;

  /// 本人移动电话，可为空
  final String stuMoveTel;

  /// 本人其他联系方式，可为空
  final String stuOtherTel;

  /// 去时日期
  final DateTime goDate;

  /// 去时时
  final int goTime;

  /// 去时交通工具
  final VehicleType goVehicle;

  /// 返时日期
  final DateTime backDate;

  /// 返时时
  final int backTime;

  /// 返时交通工具
  final VehicleType backVehicle;

  factory DailyLeaveOptions.fromHTML(String html) {
    final soup = BeautifulSoup(html);

    String getValueFromInput(String id) =>
        soup.find('input', id: id)!.getAttrValue('value') ?? '';

    String getValueFromSelect(String id) => soup
        .find('select', id: id)!
        .findAll('option')
        .singleWhere(
            (element) => element.getAttrValue('selected') == 'selected')
        .getAttrValue('value')!;

    String getTableSelectedValue(String id) => soup
        .find('table', id: id)!
        .findAll('input')
        .singleWhere((element) => element.getAttrValue('checked') == 'checked')
        .getAttrValue('value')!;

    final leaveBeginDate =
        DateTime.parse(getValueFromInput('AllLeave1_LeaveBeginDate'));
    final leaveBeginTime =
        int.parse(getValueFromSelect('AllLeave1_LeaveBeginTime'));
    final leaveEndDate =
        DateTime.parse(getValueFromInput('AllLeave1_LeaveEndDate'));
    final leaveEndTime =
        int.parse(getValueFromSelect('AllLeave1_LeaveEndTime'));
    final leaveNumNo = int.parse(getValueFromInput('AllLeave1_LeaveNumNo'));
    final leaveType =
        LeaveType.from(getTableSelectedValue('AllLeave1_LeaveType'));
    final leaveThing = soup.find('textarea', id: 'AllLeave1_LeaveThing')!.text;
    final area = getValueFromInput('AllLeave1_area');
    final comeWhere1 = getValueFromInput('AllLeave1_ComeWhere1');
    final a1 = getValueFromInput('A1');
    final a2 = getValueFromInput('A2');
    final a3 = getValueFromInput('A3');
    final outAddress = getValueFromInput('AllLeave1_OutAddress');
    final isTellRbl = soup
            .find('span', id: 'AllLeave1_IsTellRbl')!
            .findAll('input')
            .singleWhere(
                (element) => element.getAttrValue('checked') == 'checked')
            .getAttrValue('value') ==
        '1';
    final withNumNo = int.parse(getValueFromSelect('AllLeave1_WithNumNo'));
    final jhrName = getValueFromInput('AllLeave1_JHRName');
    final jhrPhone = getValueFromInput('AllLeave1_JHRPhone');
    final outTel = getValueFromInput('AllLeave1_OutTel');
    final outMoveTel = getValueFromInput('AllLeave1_OutMoveTel');
    final relation = getValueFromInput('AllLeave1_Relation');
    final outName = getValueFromInput('AllLeave1_OutName');
    final stuMoveTel = getValueFromInput('AllLeave1_StuMoveTel');
    final stuOtherTel = getValueFromInput('AllLeave1_OutMoveTel');
    final goDate = DateTime.parse(getValueFromInput('AllLeave1_GoDate'));
    final goTime = int.parse(getValueFromSelect('AllLeave1_GoTime'));
    final goVehicle =
        VehicleType.from(getTableSelectedValue('AllLeave1_GoVehicle'));
    final backDate = DateTime.parse(getValueFromInput('AllLeave1_BackDate'));
    final backTime = int.parse(getValueFromSelect('AllLeave1_BackTime'));
    final backVehicle =
        VehicleType.from(getTableSelectedValue('AllLeave1_BackVehicle'));

    return DailyLeaveOptions(
        action: DailyLeaveAction.edit,
        leaveBeginDate: leaveBeginDate,
        leaveBeginTime: leaveBeginTime,
        leaveEndDate: leaveEndDate,
        leaveEndTime: leaveEndTime,
        leaveNumNo: leaveNumNo,
        leaveType: leaveType,
        leaveThing: leaveThing,
        area: area,
        comeWhere1: comeWhere1,
        a1: a1,
        a2: a2,
        a3: a3,
        outAddress: outAddress,
        isTellRbl: isTellRbl,
        withNumNo: withNumNo,
        jhrName: jhrName,
        jhrPhone: jhrPhone,
        outTel: outTel,
        outMoveTel: outMoveTel,
        relation: relation,
        outName: outName,
        stuMoveTel: stuMoveTel,
        stuOtherTel: stuOtherTel,
        goDate: goDate,
        goTime: goTime,
        goVehicle: goVehicle,
        backDate: backDate,
        backTime: backTime,
        backVehicle: backVehicle);
  }

  Map<String, dynamic> toJson() {
    return {
      'AllLeave1\$LeaveBeginDate':
          '${leaveBeginDate.year}-${leaveBeginDate.month.padL2}-${leaveBeginDate.day.padL2}',
      'AllLeave1\$LeaveBeginTime': '$leaveBeginTime',
      'AllLeave1\$LeaveEndDate':
          '${leaveEndDate.year}-${leaveEndDate.month.padL2}-${leaveEndDate.day.padL2}',
      'AllLeave1\$LeaveEndTime': '$leaveEndTime',
      'AllLeave1\$LeaveNumNo': '$leaveNumNo',
      'AllLeave1\$LeaveType': leaveType.name,
      'AllLeave1\$LeaveThing': leaveThing,
      'AllLeave1\$area': area,
      'AllLeave1\$ComeWhere1': comeWhere1,
      'A1': a1,
      'A2': a2,
      'A3': a3,
      'AllLeave1\$OutAddress': outAddress,
      'AllLeave1\$IsTellRbl': isTellRbl ? '1' : '0',
      'AllLeave1\$WithNumNo': '$withNumNo',
      'AllLeave1\$JHRName': jhrName,
      'AllLeave1\$JHRPhone': jhrPhone,
      'AllLeave1\$OutTel': outTel,
      'AllLeave1\$OutMoveTel': outMoveTel,
      'AllLeave1\$Relation': relation,
      'AllLeave1\$OutName': outName,
      'AllLeave1\$StuMoveTel': stuMoveTel,
      'AllLeave1\$StuOtherTel': stuOtherTel,
      'AllLeave1\$GoDate':
          '${goDate.year}-${goDate.month.padL2}-${goDate.day.padL2}',
      'AllLeave1\$GoTime': '$goTime',
      'AllLeave1\$GoVehicle': goVehicle.name,
      'AllLeave1\$BackDate':
          '${backDate.year}-${backDate.month.padL2}-${backDate.day.padL2}',
      'AllLeave1\$BackTime': '$backTime',
      'AllLeave1\$BackVehicle': backVehicle.name
    };
  }
}
