import 'package:flutter/material.dart';

// 添加卡片底部表单
class AddCardBottomSheet extends StatefulWidget {
  final List<String> availableCards;
  final List<String> addedCards; // 已添加的卡片列表，用于判断是否显示
  final Function(String) onAddNewCard;
  final Function(String) onSelectCard; // 选择卡片时的回调

  const AddCardBottomSheet({
    super.key,
    required this.availableCards,
    required this.addedCards,
    required this.onAddNewCard,
    required this.onSelectCard,
  });

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _availableCards; // 使用本地状态管理列表
  ScrollController? _scrollController; // 保存滚动控制器引用

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
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNewCard() {
    final newCardName = _textController.text.trim();
    if (newCardName.isNotEmpty) {
      // 检查是否已存在
      if (_availableCards.contains(newCardName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('卡片 "$newCardName" 已存在'),
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      }
      
      // 更新本地状态
      setState(() {
        _availableCards.add(newCardName);
      });
      
      // 通知父组件
      widget.onAddNewCard(newCardName);
      _textController.clear();
      // 收起键盘
      _focusNode.unfocus();
      
      // 滚动到底部显示新添加的项
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController != null && _scrollController!.hasClients) {
          _scrollController!.animateTo(
            _scrollController!.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
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
          // 保存滚动控制器引用
          _scrollController = scrollController;
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
              // 标题
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  '添加卡片',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 卡片列表
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _availableCards.length + 1, // +1 用于添加新选项的行
                  itemBuilder: (context, index) {
                    // 最后一行：添加新选项
                    if (index == _availableCards.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: '输入新卡片名称',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (_) => _addNewCard(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _addNewCard,
                              icon: const Icon(Icons.add_circle),
                              color: Colors.black,
                              iconSize: 32,
                            ),
                          ],
                        ),
                      );
                    }
                    // 普通列表项
                    final cardName = _availableCards[index];
                    final isAdded = widget.addedCards.contains(cardName);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: isAdded
                            ? null
                            : () {
                                widget.onSelectCard(cardName);
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  cardName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isAdded
                                        ? Colors.grey.shade500
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (isAdded)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
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

