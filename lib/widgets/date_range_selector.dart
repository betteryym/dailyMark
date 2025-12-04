import 'package:flutter/material.dart';

// 日期范围选择器组件
class DateRangeSelector extends StatelessWidget {
  final String dateRangeText;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const DateRangeSelector({
    super.key,
    required this.dateRangeText,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            dateRangeText,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
