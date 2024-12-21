import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 2)
class Todo {
  const Todo(
      {required this.title, required this.color, required this.isFinished});

  @HiveField(0)
  final String title;

  @HiveField(1)
  final int color;

  @HiveField(2)
  final bool isFinished;
}
