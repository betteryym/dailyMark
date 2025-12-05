import 'package:flutter/material.dart';
import 'card_type.dart';

// 卡片数据模型
class MarkCard {
  final String title;
  final IconData icon;
  final Color iconColor;
  final IconData badgeIcon;
  final CardType cardType; // 卡片类型
  final List<DateTime> checkInDates; // 打卡日期列表
  
  // 不同类型的数据存储
  // rating: List<Map<String, dynamic>> - [{date: DateTime, rating: int}]
  // timeRange: List<Map<String, dynamic>> - [{date: DateTime, startTime: DateTime, endTime: DateTime}]
  // max: Map<String, dynamic> - {maxValue: double, date: DateTime}
  // min: Map<String, dynamic> - {minValue: double, date: DateTime}
  final Map<String, dynamic> typeData;

  MarkCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.badgeIcon,
    required this.cardType,
    List<DateTime>? checkInDates,
    Map<String, dynamic>? typeData,
  }) : checkInDates = checkInDates ?? [],
       typeData = typeData ?? {};

  // 复制并添加打卡日期
  MarkCard copyWith({
    String? title,
    IconData? icon,
    Color? iconColor,
    IconData? badgeIcon,
    CardType? cardType,
    List<DateTime>? checkInDates,
    Map<String, dynamic>? typeData,
  }) {
    return MarkCard(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      cardType: cardType ?? this.cardType,
      checkInDates: checkInDates ?? this.checkInDates,
      typeData: typeData ?? this.typeData,
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

  // 获取评分列表（rating类型）
  List<Map<String, dynamic>> get ratingData {
    if (cardType != CardType.rating) return [];
    return (typeData['ratings'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  // 获取时间范围列表（timeRange类型）
  List<Map<String, dynamic>> get timeRangeData {
    if (cardType != CardType.timeRange) return [];
    return (typeData['timeRanges'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  // 获取最大值（max类型）
  double? get maxValue {
    if (cardType != CardType.max) return null;
    return (typeData['maxValue'] as num?)?.toDouble();
  }

  // 获取最大值日期（max类型）
  DateTime? get maxValueDate {
    if (cardType != CardType.max) return null;
    return typeData['date'] as DateTime?;
  }

  // 获取最小值（min类型）
  double? get minValue {
    if (cardType != CardType.min) return null;
    return (typeData['minValue'] as num?)?.toDouble();
  }

  // 获取最小值日期（min类型）
  DateTime? get minValueDate {
    if (cardType != CardType.min) return null;
    return typeData['date'] as DateTime?;
  }

  // 获取平均评分（rating类型）- 已废弃，保留用于兼容
  double? get averageRating {
    if (cardType != CardType.rating || ratingData.isEmpty) return null;
    final ratings = ratingData.map((r) => r['rating'] as int).toList();
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  // 获取最新评分（rating类型）- 以最新的为准
  int? get latestRating {
    if (cardType != CardType.rating || ratingData.isEmpty) return null;
    // 按日期排序，获取最新的评分
    final sortedRatings = List<Map<String, dynamic>>.from(ratingData);
    sortedRatings.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA); // 降序，最新的在前
    });
    return sortedRatings.first['rating'] as int;
  }

  // 获取覆盖值（overwrite类型 - 时间）
  DateTime? get overwriteTime {
    if (cardType != CardType.overwrite) return null;
    return typeData['time'] as DateTime?;
  }

  // 获取覆盖值（overwrite类型 - 数值）
  double? get overwriteValue {
    if (cardType != CardType.overwrite) return null;
    return (typeData['value'] as num?)?.toDouble();
  }
}
