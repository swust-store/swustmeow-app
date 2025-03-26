import 'package:swustmeow/entity/apaertment/apartment_student_info.dart';
import 'package:swustmeow/entity/apaertment/electricity_bill.dart';
import 'package:swustmeow/entity/duifene/duifene_course.dart';
import 'package:swustmeow/entity/soa/score/points_data.dart';

import '../entity/chaoxing/chaoxing_course.dart';
import '../entity/chaoxing/chaoxing_exam.dart';
import '../entity/chaoxing/chaoxing_homework.dart';
import '../entity/duifene/duifene_homework.dart';
import '../entity/duifene/duifene_test.dart';
import '../entity/soa/course/course_entry.dart';
import '../entity/soa/course/course_type.dart';
import '../entity/soa/course/courses_container.dart';

class ShowcaseValues {
  static final now = DateTime(2025, 2, 17, 10, 54, 23);

  static List<Map<String, dynamic>> courseTable = [
    {
      'course_name': '综合英语1',
      'teacher_name': ['张伟'],
      'start_week': 1,
      'end_week': 15,
      'place': '东2A101',
      'weekday': 1,
      'number_of_day': 2,
      'display_name': '综合英语1',
      'start_section': 3,
      'end_section': 4,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '高等数学[A]1',
      'teacher_name': ['王明'],
      'start_week': 1,
      'end_week': 17,
      'place': '西6203',
      'weekday': 2,
      'number_of_day': 1,
      'display_name': '高等数学[A]1',
      'start_section': 1,
      'end_section': 2,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '大学体育与健康',
      'teacher_name': ['李强'],
      'start_week': 1,
      'end_week': 19,
      'place': '西区运动场',
      'weekday': 4,
      'number_of_day': 3,
      'display_name': '大学体育与健康',
      'start_section': 5,
      'end_section': 6,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': 'C语言程序设计基础',
      'teacher_name': ['刘芳'],
      'start_week': 1,
      'end_week': 16,
      'place': '东3B201',
      'weekday': 3,
      'number_of_day': 4,
      'display_name': 'C语言程序设计基础',
      'start_section': 7,
      'end_section': 8,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '大学生心理健康',
      'teacher_name': ['陈红'],
      'start_week': 5,
      'end_week': 12,
      'place': '西5301',
      'weekday': 5,
      'number_of_day': 5,
      'display_name': '大学生心理健康',
      'start_section': 9,
      'end_section': 10,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '高等数学[A]1',
      'teacher_name': ['王明'],
      'start_week': 1,
      'end_week': 17,
      'place': '西6205',
      'weekday': 4,
      'number_of_day': 2,
      'display_name': '高等数学[A]1',
      'start_section': 3,
      'end_section': 4,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '线性代数',
      'teacher_name': ['周杰'],
      'start_week': 2,
      'end_week': 15,
      'place': '东4A102',
      'weekday': 2,
      'number_of_day': 4,
      'display_name': '线性代数',
      'start_section': 7,
      'end_section': 8,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '大学物理1',
      'teacher_name': ['吴磊'],
      'start_week': 1,
      'end_week': 18,
      'place': '东1B305',
      'weekday': 3,
      'number_of_day': 1,
      'display_name': '大学物理1',
      'start_section': 1,
      'end_section': 2,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '数据结构与算法',
      'teacher_name': ['赵刚'],
      'start_week': 1,
      'end_week': 17,
      'place': '西7205',
      'weekday': 1,
      'number_of_day': 3,
      'display_name': '数据结构与算法',
      'start_section': 5,
      'end_section': 6,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '马克思主义基本原理',
      'teacher_name': ['李娜'],
      'start_week': 4,
      'end_week': 16,
      'place': '东5A208',
      'weekday': 5,
      'number_of_day': 2,
      'display_name': '马克思主义基本原理',
      'start_section': 3,
      'end_section': 4,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '软件工程',
      'teacher_name': ['周华'],
      'start_week': 1,
      'end_week': 18,
      'place': '东3A301',
      'weekday': 3,
      'number_of_day': 3,
      'display_name': '软件工程',
      'start_section': 5,
      'end_section': 6,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '人工智能导论',
      'teacher_name': ['张敏'],
      'start_week': 1,
      'end_week': 19,
      'place': '西6502',
      'weekday': 2,
      'number_of_day': 5,
      'display_name': '人工智能导论',
      'start_section': 9,
      'end_section': 10,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '概率论与数理统计',
      'teacher_name': ['孙丽'],
      'start_week': 3,
      'end_week': 17,
      'place': '西6304',
      'weekday': 4,
      'number_of_day': 1,
      'display_name': '概率论与数理统计',
      'start_section': 1,
      'end_section': 2,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '数字电路与逻辑设计',
      'teacher_name': ['吴斌'],
      'start_week': 3,
      'end_week': 19,
      'place': '西7305',
      'weekday': 4,
      'number_of_day': 4,
      'display_name': '数字电路与逻辑设计',
      'start_section': 7,
      'end_section': 8,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '数据库系统原理',
      'teacher_name': ['王涛'],
      'start_week': 3,
      'end_week': 15,
      'place': '西4401',
      'weekday': 6,
      'number_of_day': 3,
      'display_name': '数据库系统原理',
      'start_section': 5,
      'end_section': 6,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '操作系统',
      'teacher_name': ['李磊'],
      'start_week': 3,
      'end_week': 17,
      'place': '东4B202',
      'weekday': 5,
      'number_of_day': 4,
      'display_name': '操作系统',
      'start_section': 7,
      'end_section': 8,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    },
    {
      'course_name': '计算机网络',
      'teacher_name': ['陈浩'],
      'start_week': 2,
      'end_week': 14,
      'place': '东2B103',
      'weekday': 1,
      'number_of_day': 4,
      'display_name': '计算机网络',
      'start_section': 7,
      'end_section': 8,
      'is_custom': false,
      'container_id': '8dfc8d9471f6dcccdd08d659d7b18013fb418d76'
    }
  ];

  static final coursesContainers = [
    CoursesContainer(
      type: CourseType.normal,
      term: '2024-2025-下',
      entries: courseTable.map((c) => CourseEntry.fromJson(c)).toList(),
      id: '8dfc8d9471f6dcccdd08d659d7b18013fb418d76',
    )
  ];

  static const examSchedules = [
    {
      'type': 'finalExam',
      'courseName': '数据结构',
      'weekNum': 14,
      'numberOfDay': 1,
      'weekday': 1,
      'date': '2024-12-02',
      'place': '东1',
      'classroom': '212',
      'seatNo': 15
    },
    {
      'type': 'midExam',
      'courseName': '操作系统',
      'weekNum': 7,
      'numberOfDay': 2,
      'weekday': 3,
      'date': '2024-10-16',
      'place': '东2',
      'classroom': '218',
      'seatNo': 22
    },
    {
      'type': 'resitExam',
      'courseName': '计算机网络',
      'weekNum': 1,
      'numberOfDay': 3,
      'weekday': 5,
      'date': '2024-09-01',
      'place': '东3',
      'classroom': '318',
      'seatNo': 30
    },
    {
      'type': 'finalExam',
      'courseName': '数据库系统',
      'weekNum': 15,
      'numberOfDay': 4,
      'weekday': 2,
      'date': '2024-12-09',
      'place': '东4',
      'classroom': '411',
      'seatNo': 45
    },
    {
      'type': 'midExam',
      'courseName': '编译原理',
      'weekNum': 7,
      'numberOfDay': 1,
      'weekday': 4,
      'date': '2024-10-18',
      'place': '东1',
      'classroom': '212',
      'seatNo': 10
    },
    {
      'type': 'finalExam',
      'courseName': '软件工程',
      'weekNum': 16,
      'numberOfDay': 2,
      'weekday': 6,
      'date': '2024-12-16',
      'place': '东2',
      'classroom': '218',
      'seatNo': 50
    },
    {
      'type': 'resitExam',
      'courseName': '人工智能',
      'weekNum': 1,
      'numberOfDay': 3,
      'weekday': 1,
      'date': '2024-09-03',
      'place': '东3',
      'classroom': '318',
      'seatNo': 5
    },
    {
      'type': 'midExam',
      'courseName': '计算机组成原理',
      'weekNum': 7,
      'numberOfDay': 4,
      'weekday': 3,
      'date': '2024-10-20',
      'place': '东4',
      'classroom': '411',
      'seatNo': 60
    },
    {
      'type': 'finalExam',
      'courseName': '算法设计与分析',
      'weekNum': 14,
      'numberOfDay': 1,
      'weekday': 5,
      'date': '2024-12-04',
      'place': '东1',
      'classroom': '212',
      'seatNo': 25
    },
    {
      'type': 'resitExam',
      'courseName': '网络安全',
      'weekNum': 1,
      'numberOfDay': 2,
      'weekday': 2,
      'date': '2024-09-05',
      'place': '东2',
      'classroom': '218',
      'seatNo': 35
    }
  ];

  static const courseScores = [
    {
      'courseName': '数据结构',
      'courseId': 'CS101',
      'credit': 3.0,
      'courseType': '必修',
      'formalScore': '85',
      'resitScore': '',
      'points': 3.7,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '操作系统',
      'courseId': 'CS102',
      'credit': 4.0,
      'courseType': '必修',
      'formalScore': '58',
      'resitScore': '65',
      'points': 1.0,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '计算机网络',
      'courseId': 'CS103',
      'credit': 3.5,
      'courseType': '必修',
      'formalScore': '92',
      'resitScore': '',
      'points': 4.0,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '数据库系统',
      'courseId': 'CS104',
      'credit': 3.0,
      'courseType': '必修',
      'formalScore': '78',
      'resitScore': '',
      'points': 3.0,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '编译原理',
      'courseId': 'CS105',
      'credit': 4.0,
      'courseType': '必修',
      'formalScore': '55',
      'resitScore': '70',
      'points': 1.0,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '软件工程',
      'courseId': 'CS106',
      'credit': 3.0,
      'courseType': '必修',
      'formalScore': '88',
      'resitScore': '',
      'points': 3.7,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '人工智能',
      'courseId': 'CS107',
      'credit': 3.5,
      'courseType': '任选',
      'formalScore': '91',
      'resitScore': '',
      'points': 4.0,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '计算机组成原理',
      'courseId': 'CS108',
      'credit': 4.0,
      'courseType': '必修',
      'formalScore': '67',
      'resitScore': '',
      'points': 2.3,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '算法设计与分析',
      'courseId': 'CS109',
      'credit': 3.0,
      'courseType': '必修',
      'formalScore': '74',
      'resitScore': '',
      'points': 2.7,
      'scoreType': 'common',
      'term': '2024-2025-下'
    },
    {
      'courseName': '网络安全',
      'courseId': 'CS110',
      'credit': 3.5,
      'courseType': '任选',
      'formalScore': '82',
      'resitScore': '',
      'points': 3.3,
      'scoreType': 'common',
      'term': '2024-2025-下'
    }
  ];

  static const todos = [
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440000',
      'content': '完成本周的编程作业',
      'color': 0,
      'isFinished': false,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440001',
      'content': '复习算法与数据结构',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440002',
      'content': '准备小组项目的中期检查',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440003',
      'content': '修复项目中已识别的关键Bug',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440004',
      'content': '学习并实践一种新的开发工具',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440005',
      'content': '为现有代码补充单元测试',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440006',
      'content': '阅读并理解项目相关技术文档',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440007',
      'content': '参加一次编程竞赛或黑客马拉松',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440008',
      'content': '优化项目中性能瓶颈的代码',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440009',
      'content': '撰写项目阶段性总结报告',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440010',
      'content': '参与开源社区贡献',
      'color': 0,
      'isFinished': true,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440011',
      'content': '复习常见面试题',
      'color': 0,
      'isFinished': false,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440012',
      'content': '学习并应用设计模式到项目中',
      'color': 0,
      'isFinished': false,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440013',
      'content': '完善项目文档',
      'color': 0,
      'isFinished': false,
      'isNew': true,
      'origin': null
    },
    {
      'uuid': '550e8400-e29b-41d4-a716-446655440014',
      'content': '参加一次技术分享会或讲座',
      'color': 0,
      'isFinished': false,
      'isNew': true,
      'origin': null
    }
  ];

  static const pointsData = PointsData(
    totalCredits: 28,
    requiredCoursesCredits: 20,
    averagePoints: 3.8,
    requiredCoursesPoints: 3.8,
    degreeCoursesPoints: 4.2,
  );

  static const electricityBill = ElectricityBill(
    roomName: '东4A-403',
    remaining: 124.23,
  );

  static const apartmentStudentInfo = ApartmentStudentInfo(
    roomName: '东4A-403',
    bed: 4,
    className: '软工2403班',
    facultyName: '计算机科学与技术学院',
    grade: 2024,
    isCheckIn: true,
    realName: '张三',
    studentNumber: '5120248472',
    studentTypeName: '本科生',
  );

  static final duifeneCourses = [
    {'CourseName': '计算机网络', 'CourseID': 'CID876', 'TClassID': 'TID345'},
    {'CourseName': '数据库系统', 'CourseID': 'CID123', 'TClassID': 'TID987'},
    {'CourseName': '软件工程', 'CourseID': 'CID567', 'TClassID': 'TID654'},
    {'CourseName': '算法设计与分析', 'CourseID': 'CID456', 'TClassID': 'TID789'}
  ].map((course) => DuiFenECourse.fromJson(course)).toList();

  static final duifeneHomeworkList = [
    DuiFenEHomework(
      course: duifeneCourses[0],
      name: '网络协议实验报告-A12',
      endTime: DateTime(2024, 11, 29, 10, 30),
      finished: true,
      overdue: false,
    ),
    DuiFenEHomework(
      course: duifeneCourses[1],
      name: 'SQL性能优化实践-B45',
      endTime: DateTime(2024, 12, 05, 15, 00),
      finished: false,
      overdue: true,
    ),
    DuiFenEHomework(
      course: duifeneCourses[1],
      name: '数据库索引设计-C78',
      endTime: DateTime(2024, 12, 10, 20, 00),
      finished: false,
      overdue: false,
    ),
    DuiFenEHomework(
      course: duifeneCourses[2],
      name: 'UML状态图分析-D90',
      endTime: DateTime(2024, 12, 08, 18, 00),
      finished: true,
      overdue: false,
    ),
    DuiFenEHomework(
      course: duifeneCourses[3],
      name: '动态规划案例分析-E23',
      endTime: DateTime(2024, 12, 15, 12, 00),
      finished: true,
      overdue: true,
    ),
    DuiFenEHomework(
      course: duifeneCourses[3],
      name: '贪心算法实现-F56',
      endTime: DateTime(2024, 12, 20, 22, 00),
      finished: false,
      overdue: false,
    ),
  ];

  static final duifeneTestList = [
    DuiFenETest(
      course: duifeneCourses[0],
      name: '网络协议测试卷-G89',
      createTime: DateTime(2024, 11, 25, 14, 00),
      beginTime: DateTime(2024, 11, 30, 10, 00),
      endTime: DateTime(2024, 11, 30, 11, 30),
      submitTime: DateTime(2024, 11, 30, 11, 15),
      limitMinutes: 90,
      creatorName: '李老师',
      score: 88,
      finished: true,
      overdue: false,
    ),
    DuiFenETest(
      course: duifeneCourses[1],
      name: '数据库查询测试卷-H12',
      createTime: DateTime(2024, 11, 28, 16, 00),
      beginTime: DateTime(2024, 12, 03, 13, 00),
      endTime: DateTime(2024, 12, 03, 14, 00),
      submitTime: null,
      limitMinutes: 60,
      creatorName: '王老师',
      score: 0,
      finished: false,
      overdue: false,
    ),
    DuiFenETest(
      course: duifeneCourses[2],
      name: '软件测试用例测试卷-I34',
      createTime: DateTime(2024, 12, 01, 10, 00),
      beginTime: DateTime(2024, 12, 06, 15, 00),
      endTime: DateTime(2024, 12, 06, 16, 30),
      submitTime: DateTime(2024, 12, 06, 16, 10),
      limitMinutes: 90,
      creatorName: '张老师',
      score: 92,
      finished: true,
      overdue: false,
    ),
    DuiFenETest(
      course: duifeneCourses[3],
      name: '算法复杂度分析测试卷-J56',
      createTime: DateTime(2024, 12, 04, 12, 00),
      beginTime: DateTime(2024, 12, 09, 14, 00),
      endTime: DateTime(2024, 12, 09, 15, 00),
      submitTime: DateTime(2024, 12, 09, 14, 40),
      limitMinutes: 60,
      creatorName: '赵老师',
      score: 75,
      finished: true,
      overdue: false,
    ),
  ];

  static final chaoXingData = [
    {
      'course': ChaoXingCourse(
        courseName: '大学物理',
        teacherName: '张三',
        courseId: 101,
        classId: 202301,
        cpi: 85,
      ),
      'exams': [
        ChaoXingExam(title: '大学物理 期中考试', status: '待做'),
        ChaoXingExam(title: '大学物理 单元测试 1', status: '已过期'),
        ChaoXingExam(title: '大学物理 单元测试 2', status: '待做'),
        ChaoXingExam(title: '大学物理 期末考试', status: '待做'),
        ChaoXingExam(title: '大学物理 课堂小测', status: '已过期'),
      ],
      'homeworks': [
        ChaoXingHomework(title: '大学物理 实验报告 1', labels: [], status: '未交'),
        ChaoXingHomework(title: '大学物理 实验报告 2', labels: [], status: '已完成'),
        ChaoXingHomework(title: '大学物理 课后习题 第一章', labels: ['互评'], status: '已互评'),
        ChaoXingHomework(title: '大学物理 课后习题 第二章', labels: ['互评'], status: '未交'),
        ChaoXingHomework(
            title: '大学物理 小论文：经典力学的应用', labels: ['互评'], status: '已完成'),
      ],
    },
    {
      'course': ChaoXingCourse(
        courseName: '数据结构',
        teacherName: '李四',
        courseId: 102,
        classId: 202302,
        cpi: 90,
      ),
      'exams': [
        ChaoXingExam(title: '数据结构 期中考试', status: '待做'),
        ChaoXingExam(title: '数据结构 单元测试 1', status: '已过期'),
        ChaoXingExam(title: '数据结构 单元测试 2', status: '待做'),
        ChaoXingExam(title: '数据结构 期末考试', status: '已过期'),
      ],
      'homeworks': [
        ChaoXingHomework(title: '数据结构 课后作业 第三章', labels: ['互评'], status: '已互评'),
        ChaoXingHomework(title: '数据结构 代码实现：二叉树', labels: ['互评'], status: '未交'),
        ChaoXingHomework(title: '数据结构 代码实现：哈希表', labels: [], status: '已完成'),
        ChaoXingHomework(
            title: '数据结构 小论文：算法复杂度分析', labels: ['互评'], status: '未交'),
        ChaoXingHomework(title: '数据结构 课堂测试练习', labels: [], status: '已完成'),
      ],
    },
    {
      'course': ChaoXingCourse(
        courseName: '人工智能导论',
        teacherName: '王五',
        courseId: 103,
        classId: 202303,
        cpi: 88,
      ),
      'exams': [
        ChaoXingExam(title: '人工智能导论 期末考试', status: '待做'),
        ChaoXingExam(title: '人工智能导论 机器学习基础测验', status: '已过期'),
        ChaoXingExam(title: '人工智能导论 课堂小测', status: '待做'),
      ],
      'homeworks': [
        ChaoXingHomework(
            title: '人工智能导论 论文：机器学习的应用', labels: ['互评'], status: '已互评'),
        ChaoXingHomework(title: '人工智能导论 课后习题', labels: [], status: '已完成'),
        ChaoXingHomework(
            title: '人工智能导论 代码实现：神经网络', labels: [], status: '未交'),
        ChaoXingHomework(
            title: '人工智能导论 代码实现：逻辑回归', labels: [], status: '已完成'),
        ChaoXingHomework(
            title: '人工智能导论 小论文：强化学习简介', labels: ['互评'], status: '已互评'),
      ],
    },
    {
      'course': ChaoXingCourse(
        courseName: '软件工程',
        teacherName: '赵六',
        courseId: 104,
        classId: 202304,
        cpi: 92,
      ),
      'exams': [
        ChaoXingExam(title: '软件工程 期中考试', status: '待做'),
        ChaoXingExam(title: '软件工程 小组项目阶段报告', status: '已过期'),
        ChaoXingExam(title: '软件工程 期末考试', status: '待做'),
      ],
      'homeworks': [
        ChaoXingHomework(
            title: '软件工程 小组项目第一阶段报告', labels: ['互评'], status: '未交'),
        ChaoXingHomework(
            title: '软件工程 小组项目第二阶段报告', labels: [], status: '已完成'),
        ChaoXingHomework(
            title: '软件工程 期中作业：需求分析报告', labels: ['互评'], status: '已互评'),
        ChaoXingHomework(title: '软件工程 期末项目报告', labels: [], status: '未交'),
      ],
    },
    {
      'course': ChaoXingCourse(
        courseName: '计算机网络',
        teacherName: '钱七',
        courseId: 105,
        classId: 202305,
        cpi: 87,
      ),
      'exams': [
        ChaoXingExam(title: '计算机网络 期中考试', status: '已过期'),
        ChaoXingExam(title: '计算机网络 单元测试 1', status: '待做'),
        ChaoXingExam(title: '计算机网络 期末考试', status: '待做'),
      ],
      'homeworks': [
        ChaoXingHomework(
            title: '计算机网络 课后作业：TCP协议分析', labels: [], status: '已完成'),
        ChaoXingHomework(
            title: '计算机网络 代码实现：简单路由算法', labels: ['互评'], status: '未交'),
        ChaoXingHomework(
            title: '计算机网络 小论文：网络层协议', labels: ['互评'], status: '已互评'),
        ChaoXingHomework(
            title: '计算机网络 实验报告：路由器配置', labels: [], status: '未交'),
      ],
    },
  ];
}
