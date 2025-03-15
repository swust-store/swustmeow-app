import 'package:flutter/material.dart';
import 'package:swustmeow/services/account/account_service.dart';

class Tool {
  final String id; // 唯一标识符
  final String name; // 工具名称
  final String path; // 路由路径
  final IconData icon; // 图标
  final Color color; // 颜色
  final Widget Function() pageBuilder; // 页面构建器
  final AccountService? Function()? serviceGetter; // 服务获取器
  bool isVisible; // 是否在首页显示
  int order; // 用户自定义排序
  final bool hiddenInShowcaseMode;

  Tool({
    required this.id,
    required this.name,
    required this.path,
    required this.icon,
    required this.color,
    required this.pageBuilder,
    this.serviceGetter,
    this.isVisible = true,
    required this.order,
    this.hiddenInShowcaseMode = false,
  });

  // 从JSON构造方法
  factory Tool.fromJson(Map<String, dynamic> json, List<Tool> defaultTools) {
    // 查找默认工具以获取不能序列化的属性
    final defaultTool = defaultTools.firstWhere((t) => t.id == json['id']);

    return Tool(
      id: json['id'],
      name: defaultTool.name,
      path: json['path'] ?? defaultTool.path,
      icon: defaultTool.icon,
      color: defaultTool.color,
      pageBuilder: defaultTool.pageBuilder,
      serviceGetter: defaultTool.serviceGetter,
      isVisible: json['isVisible'] ?? true,
      order: json['order'] ?? defaultTool.order,
      hiddenInShowcaseMode:
          json['hiddenInShowcaseMode'] ?? defaultTool.hiddenInShowcaseMode,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'isVisible': isVisible,
      'order': order,
      'hiddenInShowcaseMode': hiddenInShowcaseMode,
    };
  }

  // 创建副本
  Tool copyWith({
    String? name,
    String? path,
    IconData? icon,
    Color? color,
    Widget Function()? pageBuilder,
    AccountService Function()? serviceGetter,
    bool? isVisible,
    int? order,
    bool? hiddenInShowcaseMode,
  }) {
    return Tool(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      pageBuilder: pageBuilder ?? this.pageBuilder,
      serviceGetter: serviceGetter ?? this.serviceGetter,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      hiddenInShowcaseMode: hiddenInShowcaseMode ?? this.hiddenInShowcaseMode,
    );
  }

  @override
  String toString() {
    return '''Tool(
      id: $id,
      name: $name,
      path: $path,
      icon: $icon,
      color: $color,
      isVisible: $isVisible,
      order: $order,
      hiddenInShowcaseMode: $hiddenInShowcaseMode,
    )''';
  }
}
