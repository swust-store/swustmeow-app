// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 2;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      uuid: fields[0] as String,
      content: fields[1] as String,
      color: fields[2] as int,
      isFinished: fields[3] as bool,
      isNew: fields[4] as bool,
      origin: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.isFinished)
      ..writeByte(4)
      ..write(obj.isNew)
      ..writeByte(5)
      ..write(obj.origin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
