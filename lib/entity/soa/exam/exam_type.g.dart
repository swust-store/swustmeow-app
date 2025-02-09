// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamTypeAdapter extends TypeAdapter<ExamType> {
  @override
  final int typeId = 19;

  @override
  ExamType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExamType.finalExam;
      case 1:
        return ExamType.midExam;
      case 2:
        return ExamType.resitExam;
      default:
        return ExamType.finalExam;
    }
  }

  @override
  void write(BinaryWriter writer, ExamType obj) {
    switch (obj) {
      case ExamType.finalExam:
        writer.writeByte(0);
        break;
      case ExamType.midExam:
        writer.writeByte(1);
        break;
      case ExamType.resitExam:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
