import 'package:flutter/material.dart';

class Tool {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String routeName;
  final List<String> tags;

  const Tool({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.routeName,
    this.tags = const [],
  });
}

class ToolCategory {
  final String id;
  final String title;
  final IconData icon;
  final List<Tool> tools;

  const ToolCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.tools,
  });
}