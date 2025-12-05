import 'package:flutter/material.dart';
import '../models/card_type.dart';
import '../models/mark_card.dart';

// 打卡输入对话框
class CheckInDialog extends StatefulWidget {
  final MarkCard card;
  final Function(Map<String, dynamic>?) onCheckIn;

  const CheckInDialog({
    super.key,
    required this.card,
    required this.onCheckIn,
  });

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  // 评分类型
  int _selectedRating = 3;

  // 时间范围类型
  DateTime? _startTime;
  DateTime? _endTime;

  // 覆盖原值类型（时间）
  DateTime? _overwriteTime;

  // 最大值/最小值类型
  final TextEditingController _valueController = TextEditingController();
  
  // 覆盖原值类型（数值）
  final TextEditingController _overwriteValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化时间范围
    final now = DateTime.now();
    _startTime = DateTime(now.year, now.month, now.day, 22, 0); // 默认22:00
    _endTime = DateTime(now.year, now.month, now.day, 6, 0).add(const Duration(days: 1)); // 默认次日6:00
    
    // 初始化覆盖原值类型的时间（默认当前时间）
    _overwriteTime = now;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _overwriteValueController.dispose();
    super.dispose();
  }

  void _handleCheckIn() {
    Map<String, dynamic>? data;

    switch (widget.card.cardType) {
      case CardType.rating:
        data = {'rating': _selectedRating};
        break;

      case CardType.timeRange:
        if (_startTime == null || _endTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请选择开始和结束时间'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        if (_endTime!.isBefore(_startTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('结束时间必须晚于开始时间'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        data = {
          'startTime': _startTime,
          'endTime': _endTime,
        };
        break;

      case CardType.max:
      case CardType.min:
        final valueText = _valueController.text.trim();
        if (valueText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请输入数值'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        final value = double.tryParse(valueText);
        if (value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请输入有效的数值'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        data = {'value': value};
        break;

      case CardType.overwrite:
        // 覆盖原值类型：根据卡片名称判断是时间还是数值
        if (widget.card.title.contains('早起') || 
            widget.card.title.contains('起床') ||
            widget.card.title.contains('时间')) {
          // 时间类型
          if (_overwriteTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('请选择时间'),
                duration: Duration(seconds: 1),
              ),
            );
            return;
          }
          data = {'time': _overwriteTime};
        } else {
          // 数值类型
          final valueText = _overwriteValueController.text.trim();
          if (valueText.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('请输入数值'),
                duration: Duration(seconds: 1),
              ),
            );
            return;
          }
          final value = double.tryParse(valueText);
          if (value == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('请输入有效的数值'),
                duration: Duration(seconds: 1),
              ),
            );
            return;
          }
          data = {'value': value};
        }
        break;

      default:
        data = null;
        break;
    }

    widget.onCheckIn(data);
    Navigator.pop(context);
  }

  Future<void> _selectTime(bool isStartTime) async {
    final now = DateTime.now();
    final initialTime = isStartTime
        ? (_startTime ?? DateTime(now.year, now.month, now.day, 22, 0))
        : (_endTime ?? DateTime(now.year, now.month, now.day, 6, 0));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );

    if (picked != null) {
      setState(() {
        final date = DateTime(now.year, now.month, now.day);
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          picked.hour,
          picked.minute,
        );

        if (isStartTime) {
          _startTime = selectedDateTime;
        } else {
          _endTime = selectedDateTime;
          // 如果结束时间早于开始时间，自动调整为次日
          if (_startTime != null && _endTime!.isBefore(_startTime!)) {
            _endTime = _endTime!.add(const Duration(days: 1));
          }
        }
      });
    }
  }

  Future<void> _selectOverwriteTime() async {
    final now = DateTime.now();
    final initialTime = _overwriteTime ?? now;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );

    if (picked != null) {
      setState(() {
        final date = DateTime(now.year, now.month, now.day);
        _overwriteTime = DateTime(
          date.year,
          date.month,
          date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '打卡：${widget.card.title}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // 根据类型显示不同的输入界面
            _buildInputWidget(),
            const SizedBox(height: 24),
            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('确认打卡'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputWidget() {
    switch (widget.card.cardType) {
      case CardType.rating:
        return _buildRatingInput();
      case CardType.timeRange:
        return _buildTimeRangeInput();
      case CardType.max:
        return _buildValueInput('请输入最大值');
      case CardType.min:
        return _buildValueInput('请输入最小值');
      case CardType.overwrite:
        return _buildOverwriteInput();
      default:
        return const Text('点击确认即可打卡');
    }
  }

  Widget _buildRatingInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请选择评分（1-5星）',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = rating == _selectedRating;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = rating;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: isSelected ? Colors.amber : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeRangeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请选择时间范围',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // 开始时间
        InkWell(
          onTap: () => _selectTime(true),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '开始时间',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _startTime != null
                          ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                          : '未选择',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.access_time),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 结束时间
        InkWell(
          onTap: () => _selectTime(false),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '结束时间',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _endTime != null
                          ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                          : '未选择',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.access_time),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueInput(String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _valueController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '请输入数值',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.numbers),
          ),
        ),
      ],
    );
  }

  Widget _buildOverwriteInput() {
    // 根据卡片名称判断是时间还是数值
    final isTimeType = widget.card.title.contains('早起') || 
                       widget.card.title.contains('起床') ||
                       widget.card.title.contains('时间');
    
    if (isTimeType) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '请选择时间',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectOverwriteTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '时间',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _overwriteTime != null
                            ? '${_overwriteTime!.hour.toString().padLeft(2, '0')}:${_overwriteTime!.minute.toString().padLeft(2, '0')}'
                            : '未选择',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.access_time),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '请输入数值（将覆盖原值）',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _overwriteValueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '请输入数值',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.numbers),
            ),
          ),
        ],
      );
    }
  }
}

