import 'package:hive/hive.dart';

part 'duifene_runmode.g.dart';

@HiveType(typeId: 6)
enum DuiFenERunMode {
  @HiveField(0)
  foreground,
  @HiveField(1)
  background;
}
