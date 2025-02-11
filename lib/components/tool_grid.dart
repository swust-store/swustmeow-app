import 'package:flutter/material.dart';

class ToolGrid extends StatelessWidget {
  const ToolGrid({super.key, required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1, // 正方形
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => Center(child: children[index]),
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
