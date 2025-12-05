import 'package:flutter/material.dart';
import '../models/mark_card.dart';
import '../utils/date_calculator.dart';

// 小型月度日历视图组件（用于单个卡片）
class MiniCalendarView extends StatelessWidget {
  final MarkCard activity;
  final DateTime currentDate;

  const MiniCalendarView({
    super.key,
    required this.activity,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateCalculator.getStartDate(currentDate, 1);
    final endDate = DateCalculator.getEndDate(currentDate, 1);
    final daysInMonth = endDate.day;
    final firstWeekday = startDate.weekday; // 1=Monday, 7=Sunday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 星期标题（简化版，只显示首字母）
        Row(
          children: ['一', '二', '三', '四', '五', '六', '日']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        // 日历网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemCount: firstWeekday - 1 + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              // 空白格子
              return const SizedBox();
            }
            final day = index - (firstWeekday - 1) + 1;
            return _buildMiniCalendarDay(day, currentDate, activity);
          },
        ),
      ],
    );
  }

  // 构建小型日历日期
  Widget _buildMiniCalendarDay(int day, DateTime currentDate, MarkCard activity) {
    final date = DateTime(currentDate.year, currentDate.month, day);
    final isChecked = activity.isCheckedIn(date);
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Container(
      decoration: BoxDecoration(
        color: isChecked
            ? activity.iconColor.withOpacity(0.2)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isChecked
              ? activity.iconColor
              : Colors.grey.shade200,
          width: isChecked ? 1.5 : 0.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 日期号（始终显示）
          Text(
            '$day',
            style: TextStyle(
              fontSize: isToday ? 12 : 10, // 今天日期增大两个号：10 + 2 = 12
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isChecked ? activity.iconColor : Colors.grey.shade600,
            ),
          ),
          // 已打卡时显示颜色块（在底部）
          if (isChecked)
            Positioned(
              bottom: 2,
              child: Container(
                width: 12,
                height: 3,
                decoration: BoxDecoration(
                  color: activity.iconColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

