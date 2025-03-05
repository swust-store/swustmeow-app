import 'package:flutter/material.dart';

class AIModel {
  final String id;
  final String name;
  final String? description;
  final IconData? icon;

  const AIModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
} 