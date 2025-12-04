import 'package:flutter/material.dart';
import 'dart:math';
import '../models/mark_card.dart';

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
    final cardInfo = _cardMap[name] ?? (Icons.circle, Colors.grey);
    return MarkCard(
      title: name,
      icon: cardInfo.$1,
      iconColor: cardInfo.$2,
      badgeIcon: Icons.add,
    );
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
