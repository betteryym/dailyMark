// 卡片类型枚举
enum CardType {
  cumulative, // 累加计数型
  overwrite,  // 覆盖原值类型
  append,     // 列表追加类型
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
    }
  }
}

