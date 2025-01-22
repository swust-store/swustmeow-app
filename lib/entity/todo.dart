import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 2)
class Todo {
  Todo(
      {required this.uuid,
      required this.content,
      required this.color,
      required this.isFinished,
      this.isNew = true});

  @HiveField(0)
  final String uuid;

  @HiveField(1)
  String content;

  @HiveField(2)
  final int color;

  @HiveField(3)
  bool isFinished;

  @HiveField(4)
  bool isNew;
}
