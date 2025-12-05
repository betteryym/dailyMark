import 'package:flutter/material.dart';
import '../utils/card_mapper.dart';

// 添加卡片底部表单
class AddCardBottomSheet extends StatefulWidget {
  final List<String> availableCards;
  final List<String> addedCards; // 已添加的卡片列表，用于判断是否显示
  final Function(String) onAddNewCard;
  final Function(String) onSelectCard; // 选择卡片时的回调
  final Function(String, IconData, Color)? onSelectCustomCard; // 选择自定义卡片时的回调
  final Function(String)? onDeleteCard; // 删除卡片时的回调
  final VoidCallback? onCreateNewCard; // 新建卡片时的回调

  const AddCardBottomSheet({
    super.key,
    required this.availableCards,
    required this.addedCards,
    required this.onAddNewCard,
    required this.onSelectCard,
    this.onSelectCustomCard,
    this.onDeleteCard,
    this.onCreateNewCard,
  });

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  late List<String> _availableCards; // 使用本地状态管理列表

  @override
  void initState() {
    super.initState();
    // 初始化列表，复制传入的列表
    _availableCards = List<String>.from(widget.availableCards);
  }

  @override
  void didUpdateWidget(AddCardBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当父组件更新 availableCards 时，同步更新本地状态
    if (widget.availableCards.length != _availableCards.length ||
        !widget.availableCards.every((card) => _availableCards.contains(card))) {
      setState(() {
        _availableCards = List<String>.from(widget.availableCards);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题和新建卡片按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '添加卡片',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.onCreateNewCard,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('新建卡片'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // 卡片列表（网格布局，每行5个）
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 每行5个
                    crossAxisSpacing: 8, // 列间距
                    mainAxisSpacing: 8, // 行间距
                    childAspectRatio: 0.75, // 宽高比
                  ),
                  itemCount: _availableCards.length,
                  itemBuilder: (context, index) {
                    final cardName = _availableCards[index];
                    final isAdded = widget.addedCards.contains(cardName);
                    // 获取卡片的图标和颜色
                    final cardInfo = CardMapper.matchIconFromName(cardName);

                    return InkWell(
                      onTap: isAdded
                          ? null
                          : () {
                              widget.onSelectCard(cardName);
                            },
                      onLongPress: widget.onDeleteCard != null
                          ? () {
                              // 显示确认对话框
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('删除卡片'),
                                    content: Text('确定要从候选列表中删除 "$cardName" 吗？'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(),
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                          widget.onDeleteCard!(cardName);
                                          setState(() {
                                            _availableCards.remove(cardName);
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('删除'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAdded
                              ? Colors.grey.shade100
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAdded
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 图标
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  cardInfo.$1,
                                  color: isAdded
                                      ? Colors.grey.shade400
                                      : cardInfo.$2,
                                  size: 32,
                                ),
                                if (isAdded)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 名称
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                cardName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isAdded
                                      ? Colors.grey.shade500
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

