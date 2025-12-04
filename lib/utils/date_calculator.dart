import 'date_formatter.dart';

// 日期计算工具
class DateCalculator {
  // 获取周期的开始日期
  static DateTime getStartDate(DateTime currentDate, int period) {
    if (period == 0) {
      // 周：获取本周的第一天（周一）
      final weekday = currentDate.weekday;
      return currentDate.subtract(Duration(days: weekday - 1));
    } else if (period == 1) {
      // 月：获取本月的第一天
      return DateTime(currentDate.year, currentDate.month, 1);
    } else {
      // 年：获取本年的第一天
      return DateTime(currentDate.year, 1, 1);
    }
  }

  // 获取周期的结束日期
  static DateTime getEndDate(DateTime currentDate, int period) {
    if (period == 0) {
      // 周：获取本周的最后一天（周日）
      final weekday = currentDate.weekday;
      return currentDate.add(Duration(days: 7 - weekday));
    } else if (period == 1) {
      // 月：获取本月的最后一天
      return DateTime(currentDate.year, currentDate.month + 1, 0);
    } else {
      // 年：获取本年的最后一天
      return DateTime(currentDate.year, 12, 31);
    }
  }

  // 获取日期范围文本
  static String getDateRangeText(DateTime currentDate, int period) {
    if (period == 0) {
      // 周：显示完整日期范围
      final startDate = getStartDate(currentDate, period);
      final endDate = getEndDate(currentDate, period);
      return '${DateFormatter.formatDate(startDate)} - ${DateFormatter.formatDate(endDate)}';
    } else if (period == 1) {
      // 月：只显示年月
      return '${currentDate.year}年${currentDate.month}月';
    } else {
      // 年：只显示年份
      return '${currentDate.year}年';
    }
  }

  // 切换到上一个周期
  static DateTime previousPeriod(DateTime currentDate, int period) {
    if (period == 0) {
      // 周：减去7天
      return currentDate.subtract(const Duration(days: 7));
    } else if (period == 1) {
      // 月：减去1个月
      return DateTime(currentDate.year, currentDate.month - 1, 1);
    } else {
      // 年：减去1年
      return DateTime(currentDate.year - 1, currentDate.month, 1);
    }
  }

  // 切换到下一个周期
  static DateTime nextPeriod(DateTime currentDate, int period) {
    if (period == 0) {
      // 周：加上7天
      return currentDate.add(const Duration(days: 7));
    } else if (period == 1) {
      // 月：加上1个月
      return DateTime(currentDate.year, currentDate.month + 1, 1);
    } else {
      // 年：加上1年
      return DateTime(currentDate.year + 1, currentDate.month, 1);
    }
  }

  // 获取活动列表中的圆点数量
  static int getDotCount(DateTime currentDate, int period) {
    if (period == 0) {
      return 7; // 周：7天
    } else if (period == 1) {
      return getEndDate(currentDate, period).day; // 月：该月的天数
    } else {
      return 12; // 年：12个月
    }
  }
}
