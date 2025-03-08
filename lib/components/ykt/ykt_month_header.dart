import 'package:flutter/material.dart';
import 'package:swustmeow/data/m_theme.dart';

class YKTMonthHeader extends StatelessWidget {
  final String month;
  final double income;
  final double expenses;
  final bool isFirstMonth;

  const YKTMonthHeader({
    super.key,
    required this.month,
    required this.income,
    required this.expenses,
    this.isFirstMonth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: EdgeInsets.only(top: isFirstMonth ? 0 : 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MTheme.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '支出: ¥${(expenses / 100).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '收入: ¥${(income / 100).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
