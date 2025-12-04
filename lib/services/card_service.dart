import '../models/mark_card.dart';
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
}
