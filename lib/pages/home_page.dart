import 'package:flutter/material.dart';
import '../models/mark_card.dart';
import '../models/card_type.dart';
import '../utils/card_mapper.dart';
import '../widgets/mark_card_widget.dart';
import '../widgets/add_card_bottom_sheet.dart';
import '../widgets/create_card_dialog.dart';
import '../widgets/check_in_dialog.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_filter_bar.dart';
import '../widgets/empty_state.dart';
import '../services/card_service.dart';

// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 随机生成的卡片名称列表
  late List<String> _availableCards;

  // 已添加到首页的卡片列表
  List<MarkCard> _addedCards = [];

  // 搜索相关状态
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _availableCards = CardMapper.generateRandomCardNames(10);
    // 从服务获取卡片数据
    CardService().initialize();
    _addedCards = List.from(CardService().getCards());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次页面显示时更新数据
    _addedCards = List.from(CardService().getCards());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 获取过滤后的卡片列表
  List<MarkCard> get _filteredCards {
    if (_searchQuery.isEmpty) {
      return _addedCards;
    }
    return _addedCards
        .where((card) =>
            card.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // 切换搜索状态
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      } else {
        // 延迟聚焦，确保搜索框已显示
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        });
      }
    });
  }

  // 更新搜索查询
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // 清除搜索
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  // 添加卡片到首页
  void _addCardToHome(String cardName) {
    // 检查是否已存在
    if (_addedCards.any((card) => card.title == cardName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('卡片 "$cardName" 已存在'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      CardService().addCard(cardName);
      _addedCards = List.from(CardService().getCards());
    });
  }

  // 打卡功能
  void _checkInCard(int index) {
    if (index < 0 || index >= _addedCards.length) return;

    final card = _addedCards[index];
    
    // 对于需要输入数据的类型，显示输入对话框
    if (card.cardType == CardType.rating ||
        card.cardType == CardType.timeRange ||
        card.cardType == CardType.max ||
        card.cardType == CardType.min ||
        card.cardType == CardType.overwrite) {
      showDialog(
        context: context,
        builder: (context) => CheckInDialog(
          card: card,
          onCheckIn: (data) {
            setState(() {
              CardService().checkInCardWithData(index, data);
              _addedCards = List.from(CardService().getCards());
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${card.title} 打卡成功！'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      );
    } else {
      // 其他类型直接打卡
      setState(() {
        CardService().checkInCard(index);
        _addedCards = List.from(CardService().getCards());
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${card.title} 打卡成功！'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // 删除卡片功能
  void _deleteCard(int index) {
    if (index < 0 || index >= _addedCards.length) return;

    final cardTitle = _addedCards[index].title;

    // 显示确认对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除卡片'),
          content: Text('确定要删除卡片 "$cardTitle" 吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  CardService().deleteCard(index);
                  _addedCards = List.from(CardService().getCards());
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除卡片 "$cardTitle"'),
                    duration: const Duration(seconds: 1),
                  ),
                );
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

  // 显示添加卡片对话框
  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddCardBottomSheet(
          availableCards: _availableCards,
          addedCards: _addedCards.map((card) => card.title).toList(),
          onAddNewCard: (String newCardName) {
            setState(() {
              _availableCards.add(newCardName);
            });
          },
          onSelectCard: (String cardName) {
            _addCardToHome(cardName);
            Navigator.pop(context); // 关闭底部表单
          },
          onSelectCustomCard: (String cardName, IconData icon, Color color) {
            _addCustomCardToHome(cardName, icon, color);
          },
          onDeleteCard: (String cardName) {
            // 从候选列表中删除卡片
            setState(() {
              _availableCards.remove(cardName);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已从候选列表中删除 "$cardName"'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onCreateNewCard: () {
            Navigator.pop(context); // 关闭当前底部表单
            _showCreateCardDialog(); // 显示新建卡片弹窗
          },
        );
      },
    );
  }

  // 添加自定义卡片到首页
  void _addCustomCardToHome(String cardName, IconData icon, Color color) {
    // 检查是否已存在
    if (_addedCards.any((card) => card.title == cardName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('卡片 "$cardName" 已存在'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      CardService().addCustomCard(cardName, icon, color);
      _addedCards = List.from(CardService().getCards());
    });
  }

  // 显示新建卡片弹窗
  void _showCreateCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CreateCardDialog(
          onCreateCard: (String cardName, IconData icon, Color color, CardType cardType) {
            // 检查是否已存在
            if (_addedCards.any((card) => card.title == cardName)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('卡片 "$cardName" 已存在'),
                  duration: const Duration(seconds: 1),
                ),
              );
              return;
            }

            setState(() {
              CardService().addCustomCardWithType(cardName, icon, color, cardType);
              _addedCards = List.from(CardService().getCards());
              // 将新卡片添加到候选列表
              if (!_availableCards.contains(cardName)) {
                _availableCards.add(cardName);
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('卡片 "$cardName" 创建成功！'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部搜索栏
            HomeSearchBar(
              isSearching: _isSearching,
              searchController: _searchController,
              searchQuery: _searchQuery,
              onToggleSearch: _toggleSearch,
              onSearchChanged: _updateSearchQuery,
              onClearSearch: _clearSearch,
              onAddCard: _showAddCardDialog,
            ),
            // 筛选栏
            const HomeFilterBar(),
            // 主内容区 - 卡片网格
            Expanded(
              child: _filteredCards.isEmpty
                  ? EmptyState(
                      message: _searchQuery.isNotEmpty
                          ? '没有找到匹配的卡片'
                          : '暂无卡片，点击右上角加号添加',
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.328125,
                        children: _filteredCards.map((card) {
                          final cardIndex = _addedCards.indexOf(card);
                          return MarkCardWidget(
                            key: ValueKey(card.title), // 使用卡片标题作为唯一标识
                            card: card,
                            onBadgeTap: () => _checkInCard(cardIndex),
                            onLongPress: () => _deleteCard(cardIndex),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
