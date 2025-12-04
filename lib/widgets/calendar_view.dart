import 'package:flutter/material.dart';
import '../models/mark_card.dart';
import '../utils/date_calculator.dart';

// 日历视图组件
class CalendarView extends StatelessWidget {
  final DateTime currentDate;
  final List<MarkCard> activities;

  const CalendarView({
    super.key,
    required this.currentDate,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateCalculator.getStartDate(currentDate, 1);
    final endDate = DateCalculator.getEndDate(currentDate, 1);
    final daysInMonth = endDate.day;
    final firstWeekday = startDate.weekday; // 1=Monday, 7=Sunday

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 星期标题
          Row(
            children: ['一', '二', '三', '四', '五', '六', '日']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // 日历网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: firstWeekday - 1 + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) {
                  // 空白格子
                  return const SizedBox();
                }
                final day = index - (firstWeekday - 1) + 1;
                return _buildCalendarDayCard(day, currentDate, activities);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建日历日期卡片
  Widget _buildCalendarDayCard(
      int day, DateTime currentDate, List<MarkCard> activities) {
    final date = DateTime(currentDate.year, currentDate.month, day);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          // 活动图标（显示前3个活动的小图标，已打卡的显示打钩）
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: activities.take(3).map((activity) {
              final isChecked = activity.isCheckedIn(date);
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isChecked
                      ? activity.iconColor
                      : activity.iconColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check,
                        size: 4,
                        color: Colors.white,
                      )
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
