import 'package:flutter/material.dart';
import 'dart:math';
import '../models/mark_card.dart';
import '../models/card_type.dart';

// 卡片工具类：处理卡片名称映射和随机生成
class CardMapper {
  // 卡片名称到图标和颜色的映射
  static final Map<String, (IconData, Color)> _cardMap = {
    '心情': (Icons.mood, Colors.orange),
    '奶茶': (Icons.local_drink, Colors.blue),
    '维生素': (Icons.medication, Colors.pink),
    '有氧训练': (Icons.directions_run, Colors.green),
    '阅读': (Icons.menu_book, Colors.orange),
    '冥想': (Icons.self_improvement, Colors.purple),
    '喝水': (Icons.water_drop, Colors.lightBlue),
    '运动': (Icons.fitness_center, Colors.red),
    '学习': (Icons.school, Colors.indigo),
    '写作': (Icons.edit, Colors.teal),
    '绘画': (Icons.palette, Colors.amber),
    '音乐': (Icons.music_note, Colors.deepPurple),
    '散步': (Icons.directions_walk, Colors.lightGreen),
    '瑜伽': (Icons.self_improvement, Colors.pinkAccent),
    '早睡': (Icons.bedtime, Colors.blueGrey),
    '早起': (Icons.wb_sunny, Colors.orangeAccent),
    '记账': (Icons.account_balance_wallet, Colors.green),
    '日记': (Icons.book, Colors.brown),
    '复盘': (Icons.assessment, Colors.cyan),
    '计划': (Icons.calendar_today, Colors.blue),
    '总结': (Icons.summarize, Colors.deepOrange),
  };

  // 预定义的卡片名称列表
  static final List<String> _cardNames = [
    '心情',
    '奶茶',
    '维生素',
    '有氧训练',
    '阅读',
    '冥想',
    '喝水',
    '运动',
    '学习',
    '写作',
    '绘画',
    '音乐',
    '散步',
    '瑜伽',
    '早睡',
    '早起',
    '记账',
    '日记',
    '复盘',
    '计划',
    '总结'
  ];

  // 根据名称获取卡片
  static MarkCard getCardFromName(String name) {
    final cardInfo = _cardMap[name];
    if (cardInfo != null) {
      // 如果名称在映射表中，使用映射的图标和颜色
      return MarkCard(
        title: name,
        icon: cardInfo.$1,
        iconColor: cardInfo.$2,
        badgeIcon: Icons.add,
        cardType: CardType.cumulative, // 默认累加计数型
      );
    } else {
      // 自定义卡片：根据文字内容智能匹配图标
      final matchedIcon = matchIconFromName(name);
      return MarkCard(
        title: name,
        icon: matchedIcon.$1,
        iconColor: matchedIcon.$2,
        badgeIcon: Icons.add,
        cardType: CardType.cumulative, // 默认累加计数型
      );
    }
  }

  // 根据名称、图标和颜色创建卡片（支持自定义）
  static MarkCard getCardFromCustom(
    String name,
    IconData icon,
    Color color, {
    CardType cardType = CardType.cumulative,
  }) {
    return MarkCard(
      title: name,
      icon: icon,
      iconColor: color,
      badgeIcon: Icons.add,
      cardType: cardType,
    );
  }

  // 根据名称关键词匹配图标（公共方法，供外部调用）
  static (IconData, Color) matchIconFromName(String name) {
    final lowerName = name.toLowerCase();

    // 关键词到图标的映射（按优先级排序）
    final keywordMap = {
      // 运动健身类
      '运动': (Icons.fitness_center, Colors.red),
      '跑步': (Icons.directions_run, Colors.green),
      '健身': (Icons.fitness_center, Colors.red),
      '锻炼': (Icons.fitness_center, Colors.red),
      '瑜伽': (Icons.self_improvement, Colors.pinkAccent),
      '游泳': (Icons.pool, Colors.blue),
      '骑行': (Icons.directions_bike, Colors.orange),
      '爬山': (Icons.landscape, Colors.brown),
      '散步': (Icons.directions_walk, Colors.lightGreen),
      '有氧': (Icons.directions_run, Colors.green),
      '力量': (Icons.fitness_center, Colors.red),

      // 学习类
      '学习': (Icons.school, Colors.indigo),
      '读书': (Icons.menu_book, Colors.orange),
      '阅读': (Icons.menu_book, Colors.orange),
      '课程': (Icons.school, Colors.indigo),
      '考试': (Icons.quiz, Colors.purple),
      '复习': (Icons.menu_book, Colors.orange),
      '作业': (Icons.assignment, Colors.blue),
      '笔记': (Icons.note, Colors.teal),

      // 饮食类
      '吃饭': (Icons.restaurant, Colors.orange),
      '早餐': (Icons.breakfast_dining, Colors.orange),
      '午餐': (Icons.lunch_dining, Colors.orange),
      '晚餐': (Icons.dinner_dining, Colors.orange),
      '喝水': (Icons.water_drop, Colors.lightBlue),
      '咖啡': (Icons.local_cafe, Colors.brown),
      '茶': (Icons.local_drink, Colors.green),
      '奶茶': (Icons.local_drink, Colors.blue),
      '水果': (Icons.apple, Colors.red),
      '蔬菜': (Icons.eco, Colors.green),

      // 健康类
      '睡眠': (Icons.bedtime, Colors.blueGrey),
      '早睡': (Icons.bedtime, Colors.blueGrey),
      '早起': (Icons.wb_sunny, Colors.orangeAccent),
      '冥想': (Icons.self_improvement, Colors.purple),
      '放松': (Icons.spa, Colors.purple),
      '按摩': (Icons.spa, Colors.purple),
      '维生素': (Icons.medication, Colors.pink),
      '吃药': (Icons.medication, Colors.pink),
      '体检': (Icons.medical_services, Colors.red),

      // 工作类
      '工作': (Icons.work, Colors.blue),
      '会议': (Icons.meeting_room, Colors.indigo),
      '项目': (Icons.folder, Colors.blueGrey),
      '任务': (Icons.task, Colors.blue),
      '计划': (Icons.calendar_today, Colors.blue),
      '总结': (Icons.summarize, Colors.deepOrange),
      '复盘': (Icons.assessment, Colors.cyan),

      // 娱乐类
      '电影': (Icons.movie, Colors.purple),
      '音乐': (Icons.music_note, Colors.deepPurple),
      '游戏': (Icons.sports_esports, Colors.purple),
      '旅行': (Icons.flight, Colors.blue),
      '旅游': (Icons.flight, Colors.blue),
      '逛街': (Icons.shopping_bag, Colors.pink),
      '购物': (Icons.shopping_cart, Colors.pink),

      // 创作类
      '写作': (Icons.edit, Colors.teal),
      '绘画': (Icons.palette, Colors.amber),
      '拍照': (Icons.camera_alt, Colors.grey),
      '视频': (Icons.videocam, Colors.red),

      // 情感类
      '心情': (Icons.mood, Colors.orange),
      '开心': (Icons.sentiment_very_satisfied, Colors.yellow),
      '难过': (Icons.sentiment_very_dissatisfied, Colors.blue),

      // 社交类
      '朋友': (Icons.people, Colors.blue),
      '家人': (Icons.family_restroom, Colors.pink),
      '约会': (Icons.favorite, Colors.red),

      // 财务类
      '记账': (Icons.account_balance_wallet, Colors.green),
      '理财': (Icons.account_balance, Colors.green),
      '消费': (Icons.shopping_cart, Colors.orange),

      // 其他
      '日记': (Icons.book, Colors.brown),
      '打卡': (Icons.check_circle, Colors.green),
    };

    // 查找匹配的关键词
    for (final entry in keywordMap.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    // 如果没有匹配，使用默认图标和基于名称生成的颜色
    return (Icons.star, _generateColorFromName(name));
  }

  // 根据名称生成颜色（确保相同名称总是生成相同颜色）
  static Color _generateColorFromName(String name) {
    // 预定义的颜色列表
    final colors = [
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightGreen,
      Colors.blueGrey,
      Colors.brown,
    ];

    // 根据名称的哈希值选择颜色
    final hash = name.hashCode;
    final index = hash.abs() % colors.length;
    return colors[index];
  }

  // 生成随机卡片名称列表
  static List<String> generateRandomCardNames(int count) {
    final random = Random();
    // 从预定义列表中随机选择，确保不重复
    final selected = <String>{};
    while (selected.length < count && selected.length < _cardNames.length) {
      selected.add(_cardNames[random.nextInt(_cardNames.length)]);
    }
    return selected.toList();
  }
}
