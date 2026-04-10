import 'package:flutter/material.dart';
import 'chart_type.dart';

/// 时间范围变化观察者接口
/// 观察者模式：定义所有观察者的共同接口
abstract class TimeRangeObserver {
  /// 当时间范围变化时回调
  void onTimeRangeChanged(TimeRange newRange);
}

/// 时间范围通知器
/// 采用观察者模式：管理时间范围状态，当状态变化时通知所有观察者
class TimeRangeNotifier extends ChangeNotifier {
  TimeRange _currentRange = TimeRange.all;
  final List<TimeRangeObserver> _observers = [];

  /// 构造函数
  /// [initialRange] 初始时间范围，默认为全部
  TimeRangeNotifier({TimeRange initialRange = TimeRange.all}) {
    _currentRange = initialRange;
  }

  /// 获取当前时间范围
  TimeRange get currentRange => _currentRange;

  /// 设置时间范围
  void setRange(TimeRange range) {
    if (_currentRange != range) {
      _currentRange = range;
      notifyListeners();
      _notifyObservers();
    }
  }

  /// 添加观察者
  void addObserver(TimeRangeObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  /// 移除观察者
  void removeObserver(TimeRangeObserver observer) {
    _observers.remove(observer);
  }

  /// 通知所有观察者
  void _notifyObservers() {
    for (var observer in _observers) {
      observer.onTimeRangeChanged(_currentRange);
    }
  }

  @override
  void dispose() {
    _observers.clear();
    super.dispose();
  }
}

/// 时间范围选择器组件
/// 使用观察者模式，当选择变化时通知所有监听者
class TimeRangeSelector extends StatelessWidget {
  final TimeRangeNotifier notifier;
  final ValueChanged<TimeRange>? onChanged;

  const TimeRangeSelector({
    super.key,
    required this.notifier,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '时间范围：',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TimeRange.values.map((range) {
                      final isSelected = notifier.currentRange == range;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            TimeRangeHelper.getDisplayName(range),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: Colors.grey[200],
                          onSelected: (selected) {
                            if (selected) {
                              notifier.setRange(range);
                              onChanged?.call(range);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
