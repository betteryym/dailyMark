import 'package:flutter/material.dart';
import '../models/mark_card.dart';
import '../utils/date_calculator.dart';

// 活动列表项组件
class ActivityItem extends StatelessWidget {
  final MarkCard activity;
  final DateTime currentDate;
  final int selectedPeriod;
  final DateTime startDate;

  const ActivityItem({
    super.key,
    required this.activity,
    required this.currentDate,
    required this.selectedPeriod,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final dotCount = DateCalculator.getDotCount(currentDate, selectedPeriod);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity.icon,
              color: activity.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // 活动名称
          Expanded(
            child: Text(
              activity.title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          // 记录圆点（根据周期显示不同数量）
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(dotCount, (dayIndex) {
                  // 计算对应的日期
                  DateTime date;
                  if (selectedPeriod == 0) {
                    // 周：从本周一开始
                    date = startDate.add(Duration(days: dayIndex));
                  } else {
                    // 年：每个月
                    date = DateTime(currentDate.year, dayIndex + 1, 1);
                  }

                  final isChecked = activity.isCheckedIn(date);

                  return Container(
                    width: selectedPeriod == 0 ? 16 : 8,
                    height: selectedPeriod == 0 ? 16 : 8,
                    margin: EdgeInsets.only(left: selectedPeriod == 0 ? 8 : 4),
                    decoration: BoxDecoration(
                      color: isChecked
                          ? activity.iconColor
                          : activity.iconColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: isChecked
                          ? Border.all(color: activity.iconColor, width: 2)
                          : null,
                    ),
                    child: isChecked
                        ? Icon(
                            Icons.check,
                            size: selectedPeriod == 0 ? 10 : 6,
                            color: Colors.white,
                          )
                        : null,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
