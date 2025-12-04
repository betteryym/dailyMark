import 'package:flutter/material.dart';

// 卡片数据模型
class MarkCard {
  final String title;
  final IconData icon;
  final Color iconColor;
  final IconData badgeIcon;
  final List<DateTime> checkInDates; // 打卡日期列表

  MarkCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.badgeIcon,
    List<DateTime>? checkInDates,
  }) : checkInDates = checkInDates ?? [];

  // 复制并添加打卡日期
  MarkCard copyWith({
    String? title,
    IconData? icon,
    Color? iconColor,
    IconData? badgeIcon,
    List<DateTime>? checkInDates,
  }) {
    return MarkCard(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      checkInDates: checkInDates ?? this.checkInDates,
    );
  }

  // 检查指定日期是否已打卡
  bool isCheckedIn(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return checkInDates.any((checkInDate) {
      final checkInOnly = DateTime(
        checkInDate.year,
        checkInDate.month,
        checkInDate.day,
      );
      return checkInOnly == dateOnly;
    });
  }

  // 添加打卡
  MarkCard addCheckIn(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    // 移除同一天的旧记录（如果存在）
    final newCheckInDates = checkInDates.where((checkInDate) {
      final checkInOnly = DateTime(
        checkInDate.year,
        checkInDate.month,
        checkInDate.day,
      );
      return checkInOnly != dateOnly;
    }).toList();
    // 添加新的打卡记录（包含完整的时分秒）
    newCheckInDates.add(date);
    return copyWith(checkInDates: newCheckInDates);
  }

  // 获取最后打卡时间
  DateTime? get lastCheckInDate {
    if (checkInDates.isEmpty) return null;
    // 返回最新的打卡时间
    return checkInDates.reduce((a, b) => a.isAfter(b) ? a : b);
  }
}
