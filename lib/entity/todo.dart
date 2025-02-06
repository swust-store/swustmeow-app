import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 2)
class Todo {
  Todo(
      {required this.uuid,
      required this.content,
      required this.color,
      required this.isFinished,
      this.isNew = true,
      this.origin});

  /// 待办的 UUID
  @HiveField(0)
  final String uuid;


  /// 待办的内容
  @HiveField(1)
  String content;

  /// 待办的颜色
  @HiveField(2)
  final int color;


  /// 是否已完成
  @HiveField(3)
  bool isFinished;


  /// 是否是新创建的
  @HiveField(4)
  bool isNew;

  /// 待办来源
  ///
  /// 如：对分易作业
  @HiveField(5)
  String? origin;
}
