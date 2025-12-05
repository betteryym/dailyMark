import 'package:flutter/material.dart';

// 卡片类型枚举
enum CardType {
  cumulative, // 累加计数型
  overwrite,  // 覆盖原值类型
  append,     // 列表追加类型
  rating,     // 评分等级型
  timeRange,  // 时间范围型
  max,        // 最大值记录型
  min,        // 最小值记录型
}

// 卡片类型工具类
class CardTypeHelper {
  // 获取类型显示名称
  static String getTypeName(CardType type) {
    switch (type) {
      case CardType.cumulative:
        return '累加计数型';
      case CardType.overwrite:
        return '覆盖原值类型';
      case CardType.append:
        return '列表追加类型';
      case CardType.rating:
        return '评分等级型';
      case CardType.timeRange:
        return '时间范围型';
      case CardType.max:
        return '最大值记录型';
      case CardType.min:
        return '最小值记录型';
    }
  }

  // 获取类型描述
  static String getTypeDescription(CardType type) {
    switch (type) {
      case CardType.cumulative:
        return '每次打卡累加计数';
      case CardType.overwrite:
        return '每次打卡覆盖原值';
      case CardType.append:
        return '每次打卡追加到列表';
      case CardType.rating:
        return '每次打卡记录评分（1-5星）';
      case CardType.timeRange:
        return '每次打卡记录时间范围';
      case CardType.max:
        return '记录并更新最大值';
      case CardType.min:
        return '记录并更新最小值';
    }
  }

  // 根据卡片类型和名称获取打卡图标
  static IconData getCheckInIcon(CardType type, String cardTitle) {
    switch (type) {
      case CardType.rating:
        return Icons.star; // 评分类型使用星星图标
      case CardType.timeRange:
        return Icons.access_time; // 时间范围类型使用时钟图标
      case CardType.overwrite:
        // 覆盖原值类型：根据卡片名称判断
        if (cardTitle.contains('早起') || 
            cardTitle.contains('起床') ||
            cardTitle.contains('时间')) {
          return Icons.access_time; // 时间类型使用时钟图标
        } else {
          return Icons.edit; // 数值类型使用编辑图标
        }
      case CardType.max:
        return Icons.trending_up; // 最大值类型使用上升趋势图标
      case CardType.min:
        return Icons.trending_down; // 最小值类型使用下降趋势图标
      case CardType.append:
        return Icons.add_circle; // 列表追加类型使用加号圆圈图标
      case CardType.cumulative:
      default:
        return Icons.add; // 累加计数型使用加号图标
    }
  }
}

