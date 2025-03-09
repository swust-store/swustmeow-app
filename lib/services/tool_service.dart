import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swustmeow/services/boxes/common_box.dart';
import '../entity/tool.dart';
import '../data/values.dart';

class ToolService {
  static const String _boxKey = 'userToolSettings';
  static const String _recentToolsKey = 'recentTools';
  static const int _maxRecentTools = 4; // 固定显示4个最近使用的工具

  // 加载用户工具设置
  static Future<void> loadToolSettings() async {
    try {
      final String? toolsJson = CommonBox.get(_boxKey) as String?;

      if (toolsJson != null) {
        final List<dynamic> toolsList = jsonDecode(toolsJson);
        final List<Tool> userTools = [];

        // 使用默认工具作为基础，应用用户设置
        for (var defaultTool in Values.defaultTools) {
          final toolData = toolsList.firstWhere(
            (t) => t['id'] == defaultTool.id,
            orElse: () => {'id': defaultTool.id},
          );

          userTools.add(Tool.fromJson(toolData, Values.defaultTools));
        }

        // 按用户排序
        userTools.sort((a, b) => a.order.compareTo(b.order));
        Values.tools.value = userTools;
      }
    } catch (e) {
      debugPrint('加载工具设置出错: $e');
      // 出错时使用默认工具
      Values.tools.value = [...Values.defaultTools];
    }
  }

  // 保存用户工具设置
  static Future<void> saveToolSettings() async {
    try {
      final List<Map<String, dynamic>> toolsData =
          Values.tools.value.map((tool) => tool.toJson()).toList();
      await CommonBox.put(_boxKey, jsonEncode(toolsData));
    } catch (e) {
      debugPrint('保存工具设置出错: $e');
    }
  }

  // 重置为默认工具设置
  static Future<void> resetToDefault() async {
    Values.tools.value = [...Values.defaultTools];
    await saveToolSettings();
  }

  // 更新工具顺序
  static Future<void> updateToolOrder(List<Tool> reorderedTools) async {
    for (int i = 0; i < reorderedTools.length; i++) {
      reorderedTools[i] = reorderedTools[i].copyWith(order: i);
    }

    Values.tools.value = reorderedTools;
    await saveToolSettings();
  }

  // 更新工具可见性
  static Future<void> updateToolVisibility(
      String toolId, bool isVisible) async {
    final List<Tool> updatedTools = [...Values.tools.value];
    final int index = updatedTools.indexWhere((tool) => tool.id == toolId);

    if (index != -1) {
      updatedTools[index] = updatedTools[index].copyWith(isVisible: isVisible);
      Values.tools.value = updatedTools;
      await saveToolSettings();
    }
  }

  // 记录工具使用
  static Future<void> recordToolUsage(String toolId) async {
    try {
      // 获取当前最近使用的工具列表
      List<String> recentTools = await getRecentTools();

      // 如果工具已经在列表中，先移除它
      recentTools.remove(toolId);

      // 将工具添加到列表最前面
      recentTools.insert(0, toolId);

      // 如果列表超过最大长度，删除最后的元素
      if (recentTools.length > _maxRecentTools) {
        recentTools = recentTools.sublist(0, _maxRecentTools);
      }

      // 保存更新后的列表
      await CommonBox.put(_recentToolsKey, jsonEncode(recentTools));
    } catch (e) {
      debugPrint('记录工具使用出错: $e');
    }
  }

  // 获取最近使用的工具
  static Future<List<String>> getRecentTools() async {
    try {
      final String? recentToolsJson = CommonBox.get(_recentToolsKey) as String?;

      if (recentToolsJson != null) {
        final List<dynamic> toolIds = jsonDecode(recentToolsJson);
        return toolIds.cast<String>();
      }
    } catch (e) {
      debugPrint('获取最近使用工具出错: $e');
    }

    return [];
  }

  // 清除最近使用记录
  static Future<void> clearRecentTools() async {
    await CommonBox.delete(_recentToolsKey);
  }
}
