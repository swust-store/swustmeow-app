import 'package:forui/assets.dart';

enum VehicleType {
  car(
      '汽车',
      SvgAsset(
        'forui_assets',
        'car-front',
        'assets/icons/car-front.svg',
      )),
  train(
      '火车',
      SvgAsset(
        'forui_assets',
        'train-front',
        'assets/icons/train-front.svg',
      )),
  plane(
      '飞机',
      SvgAsset(
        'forui_assets',
        'plane',
        'assets/icons/plane.svg',
      )),
  bike(
      '自行车',
      SvgAsset(
        'forui_assets',
        'bike',
        'assets/icons/bike.svg',
      )),
  other(
      '其他',
      SvgAsset(
        'forui_assets',
        'ellipsis',
        'assets/icons/ellipsis.svg',
      ));

  final String name;
  final SvgAsset icon;

  const VehicleType(this.name, this.icon);

  factory VehicleType.from(String name) =>
      VehicleType.values.singleWhere((t) => t.name == name);
}
