import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import '../models/mark_card.dart';
import '../models/card_type.dart';

// 标记卡片组件
class MarkCardWidget extends StatelessWidget {
  final MarkCard card;
  final VoidCallback? onBadgeTap; // 右上角图标点击回调
  final VoidCallback? onLongPress; // 长按回调（用于删除）

  const MarkCardWidget({
    super.key,
    required this.card,
    this.onBadgeTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
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
                    color: card.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    card.icon,
                    color: card.iconColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                // 卡片名称（图标下方）
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                // 显示类型相关数据
                if (_hasTypeData()) ...[
                  const SizedBox(height: 8),
                  _buildTypeDataWidget(),
                ],
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
                '上次: ${DateFormatter.formatLastCheckIn(card.lastCheckInDate)}',
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
                  card.badgeIcon,
                  size: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  bool _hasTypeData() {
    switch (card.cardType) {
      case CardType.rating:
        return card.ratingData.isNotEmpty;
      case CardType.timeRange:
        return card.timeRangeData.isNotEmpty;
      case CardType.max:
        return card.maxValue != null;
      case CardType.min:
        return card.minValue != null;
      case CardType.overwrite:
        return card.overwriteTime != null || card.overwriteValue != null;
      default:
        return false;
    }
  }

  Widget _buildTypeDataWidget() {
    switch (card.cardType) {
      case CardType.rating:
        final latestRating = card.latestRating;
        if (latestRating == null) return const SizedBox.shrink();
        return Row(
          children: [
            ...List.generate(5, (index) {
              final rating = index + 1;
              return Icon(
                Icons.star,
                size: 12,
                color: rating <= latestRating
                    ? Colors.amber
                    : Colors.grey.shade300,
              );
            }),
            const SizedBox(width: 4),
            Text(
              '$latestRating',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );

      case CardType.timeRange:
        final lastRange = card.timeRangeData.isNotEmpty
            ? card.timeRangeData.last
            : null;
        if (lastRange == null) return const SizedBox.shrink();
        final startTime = lastRange['startTime'] as DateTime?;
        final endTime = lastRange['endTime'] as DateTime?;
        if (startTime == null || endTime == null) return const SizedBox.shrink();
        final duration = endTime.difference(startTime);
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        return Text(
          '$hours时$minutes分',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        );

      case CardType.max:
        final maxValue = card.maxValue;
        if (maxValue == null) return const SizedBox.shrink();
        return Text(
          '最高: $maxValue',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        );

      case CardType.min:
        final minValue = card.minValue;
        if (minValue == null) return const SizedBox.shrink();
        return Text(
          '最低: $minValue',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        );

      case CardType.overwrite:
        // 覆盖原值类型：显示时间或数值
        final overwriteTime = card.overwriteTime;
        final overwriteValue = card.overwriteValue;
        if (overwriteTime != null) {
          return Text(
            '${overwriteTime.hour.toString().padLeft(2, '0')}:${overwriteTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          );
        } else if (overwriteValue != null) {
          return Text(
            '$overwriteValue',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          );
        }
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }
}
