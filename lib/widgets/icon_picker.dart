import 'package:flutter/material.dart';

// 图标选择器组件
class IconPicker extends StatelessWidget {
  final IconData selectedIcon;
  final Color selectedColor;
  final Function(IconData) onIconChanged;
  final Function(Color) onColorChanged;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconChanged,
    required this.onColorChanged,
  });

  // 常用图标列表
  static final List<IconData> _icons = [
    Icons.mood,
    Icons.fitness_center,
    Icons.directions_run,
    Icons.menu_book,
    Icons.water_drop,
    Icons.local_drink,
    Icons.bedtime,
    Icons.wb_sunny,
    Icons.music_note,
    Icons.palette,
    Icons.edit,
    Icons.camera_alt,
    Icons.movie,
    Icons.shopping_cart,
    Icons.work,
    Icons.school,
    Icons.medication,
    Icons.restaurant,
    Icons.flight,
    Icons.favorite,
    Icons.star,
    Icons.check_circle,
    Icons.calendar_today,
    Icons.account_balance_wallet,
    Icons.spa,
    Icons.self_improvement,
    Icons.directions_walk,
    Icons.local_cafe,
    Icons.apple,
    Icons.eco,
  ];

  // 常用颜色列表
  static final List<Color> _colors = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.blueGrey,
    Colors.brown,
    Colors.deepPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图标选择
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            '选择图标',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(), // 添加弹性滚动效果
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _icons.length,
            itemBuilder: (context, index) {
              final icon = _icons[index];
              final isSelected = icon == selectedIcon;
              return GestureDetector(
                onTap: () => onIconChanged(icon),
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? selectedColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? selectedColor : Colors.grey.shade600,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // 颜色选择
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            '选择颜色',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(), // 添加弹性滚动效果
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _colors.length,
            itemBuilder: (context, index) {
              final color = _colors[index];
              final isSelected = color == selectedColor;
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

