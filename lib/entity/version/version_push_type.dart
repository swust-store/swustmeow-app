import 'package:hive/hive.dart';

part 'version_push_type.g.dart';

@HiveType(typeId: 27)
enum VersionPushType {
  /// 小版本更新
  ///
  /// 通常用于小型修改，如页面布局样式变化。
  /// 可忽略此版本，用户忽略后不再弹出，直到下一个版本。
  @HiveField(0)
  minor,

  /// 大版本更新
  ///
  /// 通常用于大型修改，如修复重要 bug、更新大型功能，本更新优先级最高。
  /// 不可忽略，只能选择“关闭”，用户关闭后下次开启应用会继续弹出窗口。
  ///
  /// 更新链显示的更新通知示例：
  ///
  /// 当前 -> 1.0.1 (major) -> 1.0.2 (minor)
  ///
  /// 则显示 `1.0.1` 版本的更新通知；
  ///
  /// 当前 -> 1.0.1 (major) -> 1.0.2 (minor) -> 1.0.3 (major)
  ///
  /// 则根据最后一个 `major` 版本（即 `1.0.3` 版本）来通知用户更新。
  @HiveField(1)
  major;
}