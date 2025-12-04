// 日期时间格式化工具
class DateFormatter {
  // 格式化最后打卡时间显示
  static String formatLastCheckIn(DateTime? date) {
    if (date == null) return '-';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkInDate = DateTime(date.year, date.month, date.day);

    // 格式化时分（确保分钟是两位数）
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    if (checkInDate == today) {
      return '今天 $timeStr';
    } else if (checkInDate == yesterday) {
      return '昨天 $timeStr';
    } else {
      // 显示日期和时分：月/日 HH:mm
      return '${date.month}/${date.day} $timeStr';
    }
  }

  // 格式化日期（年月日）
  static String formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
