import 'package:flutter/material.dart';
import '../models/mark_card.dart';
import '../utils/card_mapper.dart';
import '../widgets/mark_card_widget.dart';
import '../widgets/add_card_bottom_sheet.dart';
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

    setState(() {
      CardService().checkInCard(index);
      _addedCards = List.from(CardService().getCards());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_addedCards[index].title} 打卡成功！'),
        duration: const Duration(seconds: 1),
      ),
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
                            icon: card.icon,
                            iconColor: card.iconColor,
                            title: card.title,
                            badgeIcon: card.badgeIcon,
                            onBadgeTap: () => _checkInCard(cardIndex),
                            lastCheckInDate: card.lastCheckInDate,
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
