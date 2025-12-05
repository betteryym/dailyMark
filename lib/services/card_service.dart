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

  // 打卡
  void checkInCard(int index) {
    if (index < 0 || index >= _addedCards.length) return;
    final now = DateTime.now();
    _addedCards[index] = _addedCards[index].addCheckIn(now);
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
