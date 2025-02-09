// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_leave_options.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLeaveOptionsAdapter extends TypeAdapter<DailyLeaveOptions> {
  @override
  final int typeId = 15;

  @override
  DailyLeaveOptions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLeaveOptions(
      leaveType: fields[0] as LeaveType,
      leaveThing: fields[1] as String,
      area: fields[2] as String,
      comeWhere1: fields[3] as String,
      a1: fields[4] as String,
      a2: fields[5] as String,
      a3: fields[6] as String,
      outAddress: fields[7] as String,
      isTellRbl: fields[8] as bool,
      withNumNo: fields[9] as int,
      jhrName: fields[10] as String,
      jhrPhone: fields[11] as String,
      outTel: fields[12] as String,
      outMoveTel: fields[13] as String,
      relation: fields[14] as String,
      outName: fields[15] as String,
      stuMoveTel: fields[16] as String,
      stuOtherTel: fields[17] as String,
      goVehicle: fields[18] as VehicleType,
      backVehicle: fields[19] as VehicleType,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLeaveOptions obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.leaveType)
      ..writeByte(1)
      ..write(obj.leaveThing)
      ..writeByte(2)
      ..write(obj.area)
      ..writeByte(3)
      ..write(obj.comeWhere1)
      ..writeByte(4)
      ..write(obj.a1)
      ..writeByte(5)
      ..write(obj.a2)
      ..writeByte(6)
      ..write(obj.a3)
      ..writeByte(7)
      ..write(obj.outAddress)
      ..writeByte(8)
      ..write(obj.isTellRbl)
      ..writeByte(9)
      ..write(obj.withNumNo)
      ..writeByte(10)
      ..write(obj.jhrName)
      ..writeByte(11)
      ..write(obj.jhrPhone)
      ..writeByte(12)
      ..write(obj.outTel)
      ..writeByte(13)
      ..write(obj.outMoveTel)
      ..writeByte(14)
      ..write(obj.relation)
      ..writeByte(15)
      ..write(obj.outName)
      ..writeByte(16)
      ..write(obj.stuMoveTel)
      ..writeByte(17)
      ..write(obj.stuOtherTel)
      ..writeByte(18)
      ..write(obj.goVehicle)
      ..writeByte(19)
      ..write(obj.backVehicle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLeaveOptionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyLeaveOptions _$DailyLeaveOptionsFromJson(Map<String, dynamic> json) =>
    DailyLeaveOptions(
      leaveBeginDate: json['leaveBeginDate'] == null
          ? null
          : DateTime.parse(json['leaveBeginDate'] as String),
      leaveBeginTime: (json['leaveBeginTime'] as num?)?.toInt(),
      leaveEndDate: json['leaveEndDate'] == null
          ? null
          : DateTime.parse(json['leaveEndDate'] as String),
      leaveEndTime: (json['leaveEndTime'] as num?)?.toInt(),
      leaveNumNo: (json['leaveNumNo'] as num?)?.toInt(),
      leaveType: $enumDecode(_$LeaveTypeEnumMap, json['leaveType']),
      leaveThing: json['leaveThing'] as String,
      area: json['area'] as String,
      comeWhere1: json['comeWhere1'] as String,
      a1: json['a1'] as String,
      a2: json['a2'] as String,
      a3: json['a3'] as String,
      outAddress: json['outAddress'] as String,
      isTellRbl: json['isTellRbl'] as bool,
      withNumNo: (json['withNumNo'] as num).toInt(),
      jhrName: json['jhrName'] as String,
      jhrPhone: json['jhrPhone'] as String,
      outTel: json['outTel'] as String,
      outMoveTel: json['outMoveTel'] as String,
      relation: json['relation'] as String,
      outName: json['outName'] as String,
      stuMoveTel: json['stuMoveTel'] as String,
      stuOtherTel: json['stuOtherTel'] as String,
      goDate: json['goDate'] == null
          ? null
          : DateTime.parse(json['goDate'] as String),
      goTime: (json['goTime'] as num?)?.toInt(),
      goVehicle: $enumDecode(_$VehicleTypeEnumMap, json['goVehicle']),
      backDate: json['backDate'] == null
          ? null
          : DateTime.parse(json['backDate'] as String),
      backTime: (json['backTime'] as num?)?.toInt(),
      backVehicle: $enumDecode(_$VehicleTypeEnumMap, json['backVehicle']),
    );

Map<String, dynamic> _$DailyLeaveOptionsToJson(DailyLeaveOptions instance) =>
    <String, dynamic>{
      'leaveBeginDate': instance.leaveBeginDate?.toIso8601String(),
      'leaveBeginTime': instance.leaveBeginTime,
      'leaveEndDate': instance.leaveEndDate?.toIso8601String(),
      'leaveEndTime': instance.leaveEndTime,
      'leaveNumNo': instance.leaveNumNo,
      'leaveType': _$LeaveTypeEnumMap[instance.leaveType]!,
      'leaveThing': instance.leaveThing,
      'area': instance.area,
      'comeWhere1': instance.comeWhere1,
      'a1': instance.a1,
      'a2': instance.a2,
      'a3': instance.a3,
      'outAddress': instance.outAddress,
      'isTellRbl': instance.isTellRbl,
      'withNumNo': instance.withNumNo,
      'jhrName': instance.jhrName,
      'jhrPhone': instance.jhrPhone,
      'outTel': instance.outTel,
      'outMoveTel': instance.outMoveTel,
      'relation': instance.relation,
      'outName': instance.outName,
      'stuMoveTel': instance.stuMoveTel,
      'stuOtherTel': instance.stuOtherTel,
      'goDate': instance.goDate?.toIso8601String(),
      'goTime': instance.goTime,
      'goVehicle': _$VehicleTypeEnumMap[instance.goVehicle]!,
      'backDate': instance.backDate?.toIso8601String(),
      'backTime': instance.backTime,
      'backVehicle': _$VehicleTypeEnumMap[instance.backVehicle]!,
    };

const _$LeaveTypeEnumMap = {
  LeaveType.seekJob: 'seekJob',
  LeaveType.intern: 'intern',
  LeaveType.returnHome: 'returnHome',
  LeaveType.train: 'train',
  LeaveType.trip: 'trip',
  LeaveType.sickLeave: 'sickLeave',
  LeaveType.personalLeave: 'personalLeave',
};

const _$VehicleTypeEnumMap = {
  VehicleType.car: 'car',
  VehicleType.train: 'train',
  VehicleType.plane: 'plane',
  VehicleType.bike: 'bike',
  VehicleType.other: 'other',
};
