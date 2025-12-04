import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';

// 标记卡片组件
class MarkCardWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final IconData badgeIcon;
  final VoidCallback? onBadgeTap; // 右上角图标点击回调
  final DateTime? lastCheckInDate; // 最后打卡时间

  const MarkCardWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.badgeIcon,
    this.onBadgeTap,
    this.lastCheckInDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 主要内容区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左上角图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                // 卡片名称（图标下方）
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // 左下角"上次"属性
          Positioned(
            left: 16,
            bottom: 16,
            child: SizedBox(
              height: 16, // 固定高度，避免文本变化导致布局移动
              child: Text(
                '上次: ${DateFormatter.formatLastCheckIn(lastCheckInDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          // 右上角图标
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onBadgeTap,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badgeIcon,
                  size: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
