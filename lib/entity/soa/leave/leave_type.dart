import 'package:forui/forui.dart';

enum LeaveType {
  seekJob(
      '求职',
      SvgAsset(
        'forui_assets',
        'briefcase-business',
        'assets/icons/briefcase-business.svg',
      )),
  intern(
      '实习',
      SvgAsset(
        'forui_assets',
        'contact',
        'assets/icons/contact.svg',
      )),
  returnHome(
      '返家',
      SvgAsset(
        'forui_assets',
        'house',
        'assets/icons/house.svg',
      )),
  train(
      '培训',
      SvgAsset(
        'forui_assets',
        'tv',
        'assets/icons/tv.svg',
      )),
  trip(
      '旅游',
      SvgAsset(
        'forui_assets',
        'tree-palm',
        'assets/icons/tree-palm.svg',
      )),
  sickLeave(
      '病假',
      SvgAsset(
        'forui_assets',
        'pill',
        'assets/icons/pill.svg',
      )),
  personalLeave(
      '事假',
      SvgAsset(
        'forui_assets',
        'notepad-text',
        'assets/icons/notepad-text.svg',
      ));

  final String name;
  final SvgAsset icon;

  const LeaveType(this.name, this.icon);

  factory LeaveType.from(String name) =>
      LeaveType.values.singleWhere((t) => t.name == name);
}
