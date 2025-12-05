import 'package:flutter/material.dart';
import '../models/mark_card.dart';
import '../services/card_service.dart';
import '../utils/date_calculator.dart';
import '../widgets/stat_card.dart';
import '../widgets/period_selector.dart';
import '../widgets/date_range_selector.dart';
import '../widgets/activity_item.dart';

// 趋势页
class TrendPage extends StatefulWidget {
  const TrendPage({super.key});

  @override
  State<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  // 时间周期选择：0=周, 1=月, 2=年
  int _selectedPeriod = 0;

  // 当前日期（用于计算日期范围）
  DateTime _currentDate = DateTime.now();

  // 记录上次的数据版本
  int _lastDataVersion = 0;

  @override
  void initState() {
    super.initState();
    CardService().initialize();
    _lastDataVersion = CardService().dataVersion;
  }

  // 获取活动数据
  List<MarkCard> get _activities {
    return CardService().getCards();
  }

  // 获取记录天数
  int get _recordedDaysCount {
    if (_selectedPeriod == 1) {
      // 月视图：显示当月记录天数
      return CardService().getMonthRecordedDaysCount(
        _currentDate.year,
        _currentDate.month,
      );
    }
    return CardService().getRecordedDaysCount();
  }

  // 获取记录次数（根据周期显示）
  int get _periodCheckInCount {
    if (_selectedPeriod == 1) {
      // 月视图：显示当月记录次数
      return CardService().getMonthCheckInCount(
        _currentDate.year,
        _currentDate.month,
      );
    }
    return CardService().getTotalCheckInCount();
  }

  // 获取当前周期的开始日期
  DateTime get _startDate {
    return DateCalculator.getStartDate(_currentDate, _selectedPeriod);
  }

  // 格式化日期范围显示
  String get _dateRangeText {
    return DateCalculator.getDateRangeText(_currentDate, _selectedPeriod);
  }

  // 切换到上一个周期
  void _previousPeriod() {
    setState(() {
      _currentDate = DateCalculator.previousPeriod(_currentDate, _selectedPeriod);
    });
  }

  // 切换到下一个周期
  void _nextPeriod() {
    setState(() {
      _currentDate = DateCalculator.nextPeriod(_currentDate, _selectedPeriod);
    });
  }

  // 切换周期时，重置到当前周期
  void _onPeriodChanged(int period) {
    setState(() {
      _selectedPeriod = period;
      _currentDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 检查数据是否变化
    final currentVersion = CardService().dataVersion;
    if (currentVersion != _lastDataVersion && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _lastDataVersion = currentVersion;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '趋势',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // 统计卡片区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '$_periodCheckInCount次',
                      label: '记录次数',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '$_recordedDaysCount天',
                      label: '记录天数',
                    ),
                  ),
                ],
              ),
            ),
            // 时间选择器
            PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
            ),
            // 日期范围显示
            DateRangeSelector(
              dateRangeText: _dateRangeText,
              onPrevious: _previousPeriod,
              onNext: _nextPeriod,
            ),
            // 活动跟踪列表
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _selectedPeriod == 1
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 4, // 再缩小50%：8 * 0.5 = 4
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _activities.length,
                        itemBuilder: (context, index) {
                          return ActivityItem(
                            activity: _activities[index],
                            currentDate: _currentDate,
                            selectedPeriod: _selectedPeriod,
                            startDate: _startDate,
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _activities.length,
                        itemBuilder: (context, index) {
                          return ActivityItem(
                            activity: _activities[index],
                            currentDate: _currentDate,
                            selectedPeriod: _selectedPeriod,
                            startDate: _startDate,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
