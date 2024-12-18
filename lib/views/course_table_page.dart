import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/utils/common.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/animated_text.dart';
import '../components/course_table.dart';
import '../components/m_scaffold.dart';
import '../utils/router.dart';
import '../utils/status.dart';
import '../utils/user.dart';
import 'main_page.dart';

class CourseTablePage extends StatefulWidget {
  const CourseTablePage({super.key, required this.entries});

  final List<CourseEntry>? entries;

  @override
  State<StatefulWidget> createState() => _CourseTablePageState();
}

class _CourseTablePageState extends State<CourseTablePage> {
  late List<CourseEntry> entries;
  int loginRetries = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entries != null) {
      entries = widget.entries!;
    } else {
      entries = [];
      _loadCourseTable();
    }
  }

  List<CourseEntry>? _getCachedCourseEntries() {
    List<dynamic>? result =
        BoxService.courseEntryListBox.get('courseTableEntries');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  Future<void> _loadCourseTable() async {
    final cached = _getCachedCourseEntries();
    if (cached != null) {
      setState(() {
        entries = cached;
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    // 无本地缓存，尝试获取
    final prefs = await SharedPreferences.getInstance();
    final res = await getCourseEntries();

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

    fail(String message) => showErrorToast(context, '获取课程表失败：$message');

    if (res.status != Status.ok) {
      // 尝试重新登录
      if (res.status == Status.notAuthorized) {
        final result = await reLogin();
        if (result == null) {
          if (context.mounted) {
            fail('登录失败，请重新登录');
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
          fail(res.value);
        }
        return;
      }
    }

    if (res.value is String) {
      if (context.mounted) {
        fail(res.value);
      }
      return;
    }

    setState(() {
      entries = (res.value as List<dynamic>).cast();
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
            content: CourseTable(entries: entries).loading(isLoading,
                child: const Center(
                    child: AnimatedText(
                  textList: ['获取课表中   ', '获取课表中.  ', '获取课表中.. ', '获取课表中...'],
                  textStyle: TextStyle(fontSize: 14),
                )))));
  }
}
