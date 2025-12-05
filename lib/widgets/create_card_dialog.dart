import 'package:flutter/material.dart';
import '../models/card_type.dart';
import 'icon_picker.dart';
import '../utils/card_mapper.dart';

// 新建卡片弹窗
class CreateCardDialog extends StatefulWidget {
  final Function(String, IconData, Color, CardType) onCreateCard;

  const CreateCardDialog({
    super.key,
    required this.onCreateCard,
  });

  @override
  State<CreateCardDialog> createState() => _CreateCardDialogState();
}

class _CreateCardDialogState extends State<CreateCardDialog> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  
  // 图标和颜色选择状态
  IconData _selectedIcon = Icons.star;
  Color _selectedColor = Colors.orange;
  bool _showIconPicker = false;
  
  // 卡片类型选择
  CardType? _selectedCardType;

  @override
  void initState() {
    super.initState();
    // 默认选择累加计数型
    _selectedCardType = CardType.cumulative;
    // 监听文本变化，自动更新图标和颜色
    _nameController.addListener(_updateDefaultIconAndColor);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateDefaultIconAndColor);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _updateDefaultIconAndColor() {
    if (_nameController.text.isNotEmpty && !_showIconPicker) {
      final matched = CardMapper.matchIconFromName(_nameController.text);
      setState(() {
        _selectedIcon = matched.$1;
        _selectedColor = matched.$2;
      });
    }
  }

  void _createCard() {
    final cardName = _nameController.text.trim();
    if (cardName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入卡片名称'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_selectedCardType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择卡片类型'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    widget.onCreateCard(cardName, _selectedIcon, _selectedColor, _selectedCardType!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 拖拽指示器
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 标题
                  const Text(
                    '新建卡片',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 卡片名称输入
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '卡片名称 *',
                      hintText: '输入卡片名称',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 卡片类型选择
                  const Text(
                    '卡片类型 *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...CardType.values.map((type) {
                    final isSelected = _selectedCardType == type;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCardType = type;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black.withOpacity(0.05)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: isSelected ? Colors.black : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      CardTypeHelper.getTypeName(type),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      CardTypeHelper.getTypeDescription(type),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  // 图标和颜色选择
                  Row(
                    children: [
                      // 图标预览
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showIconPicker = !_showIconPicker;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _selectedColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _selectedIcon,
                            color: _selectedColor,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '图标和颜色',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '点击左侧图标进行选择',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 图标选择器
                  if (_showIconPicker)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: IconPicker(
                        selectedIcon: _selectedIcon,
                        selectedColor: _selectedColor,
                        onIconChanged: (icon) {
                          setState(() {
                            _selectedIcon = icon;
                          });
                        },
                        onColorChanged: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 32),
                  // 创建按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '创建卡片',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

