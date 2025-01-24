import 'package:json_annotation/json_annotation.dart';

part 'duifene_class.g.dart';

@JsonSerializable()
class DuiFenEClass {
  const DuiFenEClass(
      {required this.courseName,
      required this.courseId,
      required this.tClassId});

  @JsonKey(name: 'CourseName')
  final String courseName;
  @JsonKey(name: 'CourseID')
  final String courseId;
  @JsonKey(name: 'TClassID')
  final String tClassId;

  factory DuiFenEClass.fromJson(Map<String, dynamic> json) =>
      _$DuiFenEClassFromJson(json);

  Map<String, dynamic> toJson() => _$DuiFenEClassToJson(this);
}
