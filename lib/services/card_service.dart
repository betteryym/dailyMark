import 'package:flutter/material.dart';
import '../models/mark_card.dart';
import '../models/card_type.dart';
import '../utils/card_mapper.dart';

// 卡片数据服务（单例模式，用于在页面间共享数据）
class CardService {
  static final CardService _instance = CardService._internal();
  factory CardService() => _instance;
  CardService._internal();

  // 已添加到首页的卡片列表
  List<MarkCard> _addedCards = [];

  // 数据版本号，用于通知数据变化
  int _dataVersion = 0;

  // 获取当前数据版本
  int get dataVersion => _dataVersion;

  // 通知数据变化
  void _notifyDataChanged() {
    _dataVersion++;
  }

  // 初始化默认卡片
  void initialize() {
    if (_addedCards.isEmpty) {
      _addedCards = [
        CardMapper.getCardFromName('心情'),
      ];
    }
  }

  // 获取所有卡片
  List<MarkCard> getCards() {
    return List.unmodifiable(_addedCards);
  }

  // 添加卡片
  void addCard(String cardName) {
    if (_addedCards.any((card) => card.title == cardName)) {
      return;
    }
    _addedCards.add(CardMapper.getCardFromName(cardName));
    _notifyDataChanged();
  }

  // 添加自定义卡片（带图标和颜色）
  void addCustomCard(String cardName, IconData icon, Color color) {
    if (_addedCards.any((card) => card.title == cardName)) {
      return;
    }
    _addedCards.add(CardMapper.getCardFromCustom(cardName, icon, color));
    _notifyDataChanged();
  }

  // 添加自定义卡片（带图标、颜色和类型）
  void addCustomCardWithType(String cardName, IconData icon, Color color, CardType cardType) {
    if (_addedCards.any((card) => card.title == cardName)) {
      return;
    }
    _addedCards.add(CardMapper.getCardFromCustom(cardName, icon, color, cardType: cardType));
    _notifyDataChanged();
  }

  // 打卡（基础方法，用于累加计数型等简单类型）
  void checkInCard(int index) {
    if (index < 0 || index >= _addedCards.length) return;
    final now = DateTime.now();
    _addedCards[index] = _addedCards[index].addCheckIn(now);
    _notifyDataChanged();
  }

  // 打卡（支持不同类型的数据）
  void checkInCardWithData(int index, Map<String, dynamic>? data) {
    if (index < 0 || index >= _addedCards.length) return;
    final card = _addedCards[index];
    final now = DateTime.now();
    MarkCard updatedCard;

    switch (card.cardType) {
      case CardType.rating:
        // 评分类型：需要 rating (1-5)，以最新的为准（同一天覆盖）
        if (data == null || data['rating'] == null) return;
        final rating = data['rating'] as int;
        if (rating < 1 || rating > 5) return;
        
        final newTypeData = Map<String, dynamic>.from(card.typeData);
        final ratings = (newTypeData['ratings'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        
        // 移除同一天的旧评分记录（以最新的为准）
        final dateOnly = DateTime(now.year, now.month, now.day);
        ratings.removeWhere((r) {
          final recordDate = r['date'] as DateTime;
          final recordDateOnly = DateTime(recordDate.year, recordDate.month, recordDate.day);
          return recordDateOnly == dateOnly;
        });
        
        // 添加新的评分记录
        ratings.add({
          'date': now,
          'rating': rating,
        });
        newTypeData['ratings'] = ratings;
        updatedCard = card.addCheckIn(now).copyWith(typeData: newTypeData);
        break;

      case CardType.timeRange:
        // 时间范围类型：需要 startTime 和 endTime
        if (data == null || data['startTime'] == null || data['endTime'] == null) return;
        final startTime = data['startTime'] as DateTime;
        final endTime = data['endTime'] as DateTime;
        if (endTime.isBefore(startTime)) return;
        
        final newTypeData = Map<String, dynamic>.from(card.typeData);
        final timeRanges = (newTypeData['timeRanges'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        timeRanges.add({
          'date': now,
          'startTime': startTime,
          'endTime': endTime,
        });
        newTypeData['timeRanges'] = timeRanges;
        updatedCard = card.addCheckIn(now).copyWith(typeData: newTypeData);
        break;

      case CardType.max:
        // 最大值类型：需要 value
        if (data == null || data['value'] == null) return;
        final value = (data['value'] as num).toDouble();
        final currentMax = card.maxValue;
        
        final newTypeData = Map<String, dynamic>.from(card.typeData);
        if (currentMax == null || value > currentMax) {
          newTypeData['maxValue'] = value;
          newTypeData['date'] = now;
        }
        updatedCard = card.addCheckIn(now).copyWith(typeData: newTypeData);
        break;

      case CardType.min:
        // 最小值类型：需要 value
        if (data == null || data['value'] == null) return;
        final value = (data['value'] as num).toDouble();
        final currentMin = card.minValue;
        
        final newTypeData = Map<String, dynamic>.from(card.typeData);
        if (currentMin == null || value < currentMin) {
          newTypeData['minValue'] = value;
          newTypeData['date'] = now;
        }
        updatedCard = card.addCheckIn(now).copyWith(typeData: newTypeData);
        break;

      case CardType.overwrite:
        // 覆盖原值类型：直接覆盖之前的值
        final newTypeData = Map<String, dynamic>.from(card.typeData);
        if (data != null) {
          if (data['time'] != null) {
            // 时间类型
            newTypeData['time'] = data['time'] as DateTime;
            newTypeData['date'] = now;
          } else if (data['value'] != null) {
            // 数值类型
            newTypeData['value'] = (data['value'] as num).toDouble();
            newTypeData['date'] = now;
          }
        }
        updatedCard = card.addCheckIn(now).copyWith(typeData: newTypeData);
        break;

      default:
        // 其他类型使用基础打卡方法
        updatedCard = card.addCheckIn(now);
        break;
    }

    _addedCards[index] = updatedCard;
    _notifyDataChanged();
  }

  // 根据标题查找卡片索引
  int findCardIndex(String title) {
    return _addedCards.indexWhere((card) => card.title == title);
  }

  // 删除卡片
  void deleteCard(int index) {
    if (index < 0 || index >= _addedCards.length) return;
    _addedCards.removeAt(index);
    _notifyDataChanged();
  }

  // 根据标题删除卡片
  void deleteCardByTitle(String title) {
    final index = findCardIndex(title);
    if (index != -1) {
      deleteCard(index);
    }
  }

  // 获取总记录次数（按不重复日期计算，同一天只算一次）
  int getTotalCheckInCount() {
    final recordedDates = <String>{};
    for (final card in _addedCards) {
      for (final date in card.checkInDates) {
        // 将日期转换为字符串（只包含年月日），用于去重
        final dateKey = '${date.year}-${date.month}-${date.day}';
        recordedDates.add(dateKey);
      }
    }
    return recordedDates.length;
  }

  // 获取记录天数（有打卡记录的不重复日期数量）
  int getRecordedDaysCount() {
    final recordedDates = <String>{};
    for (final card in _addedCards) {
      for (final date in card.checkInDates) {
        // 将日期转换为字符串（只包含年月日），用于去重
        final dateKey = '${date.year}-${date.month}-${date.day}';
        recordedDates.add(dateKey);
      }
    }
    return recordedDates.length;
  }

  // 获取指定月份的记录次数
  int getMonthCheckInCount(int year, int month) {
    final recordedDates = <String>{};
    for (final card in _addedCards) {
      for (final date in card.checkInDates) {
        if (date.year == year && date.month == month) {
          final dateKey = '${date.year}-${date.month}-${date.day}';
          recordedDates.add(dateKey);
        }
      }
    }
    return recordedDates.length;
  }

  // 获取指定月份的记录天数
  int getMonthRecordedDaysCount(int year, int month) {
    final recordedDates = <String>{};
    for (final card in _addedCards) {
      for (final date in card.checkInDates) {
        if (date.year == year && date.month == month) {
          final dateKey = '${date.year}-${date.month}-${date.day}';
          recordedDates.add(dateKey);
        }
      }
    }
    return recordedDates.length;
  }

  // 获取指定月份的使用天数（有打卡记录的卡片数量）
  int getMonthUsedDaysCount(int year, int month) {
    final usedCards = <String>{};
    for (final card in _addedCards) {
      for (final date in card.checkInDates) {
        if (date.year == year && date.month == month) {
          usedCards.add(card.title);
          break; // 只要这个月有记录就计数一次
        }
      }
    }
    return usedCards.length;
  }
}
