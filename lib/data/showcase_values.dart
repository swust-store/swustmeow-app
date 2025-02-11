import '../entity/soa/course/course_entry.dart';
import '../entity/soa/course/course_type.dart';
import '../entity/soa/course/courses_container.dart';

class ShowcaseValues {
  static final now = DateTime(2025, 2, 17, 10, 54, 23);

  static List<Map<String, dynamic>> courseTable = [
    {
      "courseName": "综合英语1",
      "teacherName": ["张伟"],
      "startWeek": 1,
      "endWeek": 15,
      "place": "东2A101",
      "weekday": 1,
      "numberOfDay": 2,
      "displayName": "综合英语1"
    },
    {
      "courseName": "高等数学[A]1",
      "teacherName": ["王明"],
      "startWeek": 1,
      "endWeek": 17,
      "place": "西6203",
      "weekday": 2,
      "numberOfDay": 1,
      "displayName": "高等数学[A]1"
    },
    {
      "courseName": "大学体育与健康",
      "teacherName": ["李强"],
      "startWeek": 1,
      "endWeek": 19,
      "place": "西区运动场",
      "weekday": 4,
      "numberOfDay": 3,
      "displayName": "大学体育与健康"
    },
    {
      "courseName": "C语言程序设计基础",
      "teacherName": ["刘芳"],
      "startWeek": 1,
      "endWeek": 16,
      "place": "东3B201",
      "weekday": 3,
      "numberOfDay": 4,
      "displayName": "C语言程序设计基础"
    },
    {
      "courseName": "大学生心理健康",
      "teacherName": ["陈红"],
      "startWeek": 5,
      "endWeek": 12,
      "place": "西5301",
      "weekday": 5,
      "numberOfDay": 5,
      "displayName": "大学生心理健康"
    },
    {
      "courseName": "高等数学[A]1",
      "teacherName": ["王明"],
      "startWeek": 1,
      "endWeek": 17,
      "place": "西6205",
      "weekday": 4,
      "numberOfDay": 2,
      "displayName": "高等数学[A]1"
    },
    {
      "courseName": "线性代数",
      "teacherName": ["周杰"],
      "startWeek": 2,
      "endWeek": 15,
      "place": "东4A102",
      "weekday": 2,
      "numberOfDay": 4,
      "displayName": "线性代数"
    },
    {
      "courseName": "大学物理1",
      "teacherName": ["吴磊"],
      "startWeek": 1,
      "endWeek": 18,
      "place": "东1B305",
      "weekday": 3,
      "numberOfDay": 1,
      "displayName": "大学物理1"
    },
    {
      "courseName": "数据结构与算法",
      "teacherName": ["赵刚"],
      "startWeek": 1,
      "endWeek": 17,
      "place": "西7205",
      "weekday": 1,
      "numberOfDay": 3,
      "displayName": "数据结构与算法"
    },
    {
      "courseName": "马克思主义基本原理",
      "teacherName": ["李娜"],
      "startWeek": 4,
      "endWeek": 16,
      "place": "东5A208",
      "weekday": 5,
      "numberOfDay": 2,
      "displayName": "马克思主义基本原理"
    },
    {
      "courseName": "软件工程",
      "teacherName": ["周华"],
      "startWeek": 1,
      "endWeek": 18,
      "place": "东3A301",
      "weekday": 3,
      "numberOfDay": 3,
      "displayName": "软件工程"
    },
    {
      "courseName": "人工智能导论",
      "teacherName": ["张敏"],
      "startWeek": 1,
      "endWeek": 19,
      "place": "西6502",
      "weekday": 2,
      "numberOfDay": 5,
      "displayName": "人工智能导论"
    },
    {
      "courseName": "概率论与数理统计",
      "teacherName": ["孙丽"],
      "startWeek": 3,
      "endWeek": 17,
      "place": "西6304",
      "weekday": 4,
      "numberOfDay": 1,
      "displayName": "概率论与数理统计"
    },
    {
      "courseName": "数字电路与逻辑设计",
      "teacherName": ["吴斌"],
      "startWeek": 3,
      "endWeek": 19,
      "place": "西7305",
      "weekday": 4,
      "numberOfDay": 4,
      "displayName": "数字电路与逻辑设计"
    },
    {
      "courseName": "数据库系统原理",
      "teacherName": ["王涛"],
      "startWeek": 3,
      "endWeek": 15,
      "place": "西4401",
      "weekday": 6,
      "numberOfDay": 3,
      "displayName": "数据库系统原理"
    },
    {
      "courseName": "操作系统",
      "teacherName": ["李磊"],
      "startWeek": 3,
      "endWeek": 17,
      "place": "东4B202",
      "weekday": 5,
      "numberOfDay": 4,
      "displayName": "操作系统"
    },
    {
      "courseName": "计算机网络",
      "teacherName": ["陈浩"],
      "startWeek": 2,
      "endWeek": 14,
      "place": "东2B103",
      "weekday": 1,
      "numberOfDay": 4,
      "displayName": "计算机网络"
    }
  ];

  static final coursesContainers = [
    CoursesContainer(
      type: CourseType.normal,
      term: '2024-2025-下',
      entries: courseTable.map((c) => CourseEntry.fromJson(c)).toList(),
    )
  ];

  static const examSchedules = [
    {
      "type": "finalExam",
      "courseName": "数据结构",
      "weekNum": 14,
      "numberOfDay": 1,
      "weekday": 1,
      "date": "2024-12-02",
      "place": "东1",
      "classroom": "212",
      "seatNo": 15
    },
    {
      "type": "midExam",
      "courseName": "操作系统",
      "weekNum": 7,
      "numberOfDay": 2,
      "weekday": 3,
      "date": "2024-10-16",
      "place": "东2",
      "classroom": "218",
      "seatNo": 22
    },
    {
      "type": "resitExam",
      "courseName": "计算机网络",
      "weekNum": 1,
      "numberOfDay": 3,
      "weekday": 5,
      "date": "2024-09-01",
      "place": "东3",
      "classroom": "318",
      "seatNo": 30
    },
    {
      "type": "finalExam",
      "courseName": "数据库系统",
      "weekNum": 15,
      "numberOfDay": 4,
      "weekday": 2,
      "date": "2024-12-09",
      "place": "东4",
      "classroom": "411",
      "seatNo": 45
    },
    {
      "type": "midExam",
      "courseName": "编译原理",
      "weekNum": 7,
      "numberOfDay": 1,
      "weekday": 4,
      "date": "2024-10-18",
      "place": "东1",
      "classroom": "212",
      "seatNo": 10
    },
    {
      "type": "finalExam",
      "courseName": "软件工程",
      "weekNum": 16,
      "numberOfDay": 2,
      "weekday": 6,
      "date": "2024-12-16",
      "place": "东2",
      "classroom": "218",
      "seatNo": 50
    },
    {
      "type": "resitExam",
      "courseName": "人工智能",
      "weekNum": 1,
      "numberOfDay": 3,
      "weekday": 1,
      "date": "2024-09-03",
      "place": "东3",
      "classroom": "318",
      "seatNo": 5
    },
    {
      "type": "midExam",
      "courseName": "计算机组成原理",
      "weekNum": 7,
      "numberOfDay": 4,
      "weekday": 3,
      "date": "2024-10-20",
      "place": "东4",
      "classroom": "411",
      "seatNo": 60
    },
    {
      "type": "finalExam",
      "courseName": "算法设计与分析",
      "weekNum": 14,
      "numberOfDay": 1,
      "weekday": 5,
      "date": "2024-12-04",
      "place": "东1",
      "classroom": "212",
      "seatNo": 25
    },
    {
      "type": "resitExam",
      "courseName": "网络安全",
      "weekNum": 1,
      "numberOfDay": 2,
      "weekday": 2,
      "date": "2024-09-05",
      "place": "东2",
      "classroom": "218",
      "seatNo": 35
    }
  ];

  static const courseScores = [
    {
      "courseName": "数据结构",
      "courseId": "CS101",
      "credit": 3.0,
      "courseType": "必修",
      "formalScore": "85",
      "resitScore": "",
      "points": 3.7
    },
    {
      "courseName": "操作系统",
      "courseId": "CS102",
      "credit": 4.0,
      "courseType": "必修",
      "formalScore": "58",
      "resitScore": "65",
      "points": 1.0
    },
    {
      "courseName": "计算机网络",
      "courseId": "CS103",
      "credit": 3.5,
      "courseType": "必修",
      "formalScore": "92",
      "resitScore": "",
      "points": 4.0
    },
    {
      "courseName": "数据库系统",
      "courseId": "CS104",
      "credit": 3.0,
      "courseType": "必修",
      "formalScore": "78",
      "resitScore": "",
      "points": 3.0
    },
    {
      "courseName": "编译原理",
      "courseId": "CS105",
      "credit": 4.0,
      "courseType": "必修",
      "formalScore": "55",
      "resitScore": "70",
      "points": 1.0
    },
    {
      "courseName": "软件工程",
      "courseId": "CS106",
      "credit": 3.0,
      "courseType": "必修",
      "formalScore": "88",
      "resitScore": "",
      "points": 3.7
    },
    {
      "courseName": "人工智能",
      "courseId": "CS107",
      "credit": 3.5,
      "courseType": "任选",
      "formalScore": "91",
      "resitScore": "",
      "points": 4.0
    },
    {
      "courseName": "计算机组成原理",
      "courseId": "CS108",
      "credit": 4.0,
      "courseType": "必修",
      "formalScore": "67",
      "resitScore": "",
      "points": 2.3
    },
    {
      "courseName": "算法设计与分析",
      "courseId": "CS109",
      "credit": 3.0,
      "courseType": "必修",
      "formalScore": "74",
      "resitScore": "",
      "points": 2.7
    },
    {
      "courseName": "网络安全",
      "courseId": "CS110",
      "credit": 3.5,
      "courseType": "任选",
      "formalScore": "82",
      "resitScore": "",
      "points": 3.3
    }
  ];

  static const todos = [
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "content": "完成本周的编程作业",
      "color": 0,
      "isFinished": false,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440001",
      "content": "复习算法与数据结构",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440002",
      "content": "准备小组项目的中期检查",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440003",
      "content": "修复项目中已识别的关键Bug",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440004",
      "content": "学习并实践一种新的开发工具",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440005",
      "content": "为现有代码补充单元测试",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440006",
      "content": "阅读并理解项目相关技术文档",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440007",
      "content": "参加一次编程竞赛或黑客马拉松",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440008",
      "content": "优化项目中性能瓶颈的代码",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440009",
      "content": "撰写项目阶段性总结报告",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440010",
      "content": "参与开源社区贡献",
      "color": 0,
      "isFinished": true,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440011",
      "content": "复习常见面试题",
      "color": 0,
      "isFinished": false,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440012",
      "content": "学习并应用设计模式到项目中",
      "color": 0,
      "isFinished": false,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440013",
      "content": "完善项目文档",
      "color": 0,
      "isFinished": false,
      "isNew": true,
      "origin": null
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440014",
      "content": "参加一次技术分享会或讲座",
      "color": 0,
      "isFinished": false,
      "isNew": true,
      "origin": null
    }
  ];
}
