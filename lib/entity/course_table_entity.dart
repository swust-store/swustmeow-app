import 'course_table_entry_entity.dart';

class CourseTableEntity {
  const CourseTableEntity({required this.entries, required this.experiments});

  final List<CourseTableEntryEntity> entries;
  final List<CourseTableEntryEntity> experiments;
}
