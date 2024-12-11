import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:toastification/toastification.dart';

import '../components/course_table.dart';
import '../components/m_scaffold.dart';
import '../data/values.dart';
import '../entity/course_table/course_table_entity.dart';
import '../utils/router.dart';
import '../utils/status.dart';
import '../utils/user.dart';
import 'main_page.dart';

class CourseTablePage extends StatefulWidget {
  const CourseTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _CourseTablePageState();
}

class _CourseTablePageState extends State<CourseTablePage> {
  CourseTableEntity entity = CourseTableEntity(entries: []);
  int loginRetries = 0;

  @override
  void initState() {
    super.initState();
    _loadCourseTable();
  }

  void _loadCourseTable() async {
    final cached = await Values.cachedCourseTableEntity;
    if (cached != null) {
      setState(() => entity = cached);
      return;
    }

    // 无本地缓存，尝试获取
    final res = await getCourseTableEntity();
    if (res.status != Status.ok) {
      _showErrorAlert('获取课程表失败：${res.value}');
      return;
    }

    setState(() => entity = res.value as CourseTableEntity);
  }

  void _showErrorAlert(String message) {
    toastification.show(
        context: context,
        title: const Text(
          '错误',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        description: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w400),
        ),
        autoCloseDuration: const Duration(seconds: 5),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        showProgressBar: false);
  }

  @override
  Widget build(BuildContext context) {
    return MScaffold(
        child: FScaffold(
            contentPad: false,
            header: FHeader.nested(
              title: const Text(
                '课程表',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              prefixActions: [
                FHeaderAction(
                    icon: FIcon(FAssets.icons.chevronLeft),
                    onPress: () {
                      pushTo(context, const MainPage());
                    })
              ],
            ),
            content: CourseTable(
              entity: entity,
            )));
  }
}
