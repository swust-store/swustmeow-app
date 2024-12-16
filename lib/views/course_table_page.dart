import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/utils/common.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/animated_text.dart';
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourseTable();
  }

  Future<void> _loadCourseTable() async {
    final cached = await Values.cachedCourseTableEntity;
    if (cached != null) {
      setState(() {
        entity = cached;
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    // 无本地缓存，尝试获取
    final prefs = await SharedPreferences.getInstance();
    final res = await getCourseTableEntity();

    Future<StatusContainer<String>?> reLogin() async {
      final username = prefs.getString('username');
      final password = prefs.getString('password');
      if (loginRetries == 3) {
        setState(() => loginRetries = 0);
        return null;
      }

      setState(() => loginRetries++);
      return await performLogin(username, password);
    }

    if (res.status != Status.ok) {
      // 尝试重新登录
      if (res.status == Status.notAuthorized) {
        final result = await reLogin();
        if (result == null) {
          if (context.mounted) {
            showErrorToast(context, '获取课程表失败：登录失败，请重新登录');
            await logOut(context);
          }
          return;
        }

        if (result.status == Status.ok) {
          final tgc = result.value!;
          await prefs.setString('TGC', tgc);
        }
        await _loadCourseTable();
      } else {
        if (context.mounted) {
          showErrorToast(context, '获取课程表失败：${res.value}');
        }
        return;
      }
    }

    setState(() {
      entity = res.value as CourseTableEntity;
      isLoading = false;
    });
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
            ).loading(isLoading,
                child: const Center(
                    child: AnimatedText(
                  textList: ['获取课表中   ', '获取课表中.  ', '获取课表中.. ', '获取课表中...'],
                  textStyle: TextStyle(fontSize: 14),
                )))));
  }
}
