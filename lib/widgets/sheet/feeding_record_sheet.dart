import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/feeding_record.dart';
import '../../providers/records_provider.dart';
import '../../providers/baby_provider.dart';
import 'base_record_sheet.dart';
import 'components/components.dart';

/// 喂养记录表单组件（策略模式）
///
/// 支持添加和编辑喂养记录，
/// 包含喂养时间、类型、方式（母乳亲喂）、奶量、备注等字段。
class FeedingRecordSheet extends BaseRecordSheet<FeedingRecordState> {
  final FeedingRecord? recordToEdit;

  FeedingRecordSheet({
    super.key,
    this.recordToEdit,
  }) : super(
          title: recordToEdit != null ? '编辑喂养记录' : '添加喂养记录',
          initialData: recordToEdit != null
              ? FeedingRecordState.fromRecord(recordToEdit)
              : null,
        );

  @override
  FeedingRecordState createInitialState() {
    return FeedingRecordState();
  }

  @override
  List<Widget> buildForm(BuildContext context, FeedingRecordState state, StateSetter setState) {
    return [
      SheetDatePicker(
        label: '喂养时间',
        selectedDateTime: state.feedTime,
        onChanged: (dt) => setState(() => state.feedTime = dt),
        primaryColor: const Color(0xFFFF8A65),
      ),
      const SizedBox(height: 20),
      SheetChipSelector(
        label: '喂养类型',
        selectedValue: state.type,
        onChanged: (type) {
          if (type != null) {
            setState(() => state.type = type);
          }
        },
        options: const [
          SheetChipOption(value: 'breast', label: '母乳亲喂', icon: Icons.favorite, color: Color(0xFFF48FB1)),
          SheetChipOption(value: 'pumped', label: '母乳瓶喂', icon: Icons.local_drink, color: Color(0xFFE91E63)),
          SheetChipOption(value: 'bottle', label: '奶粉', icon: Icons.local_dining, color: Color(0xFFFF8A65)),
          SheetChipOption(value: 'solid', label: '辅食', icon: Icons.restaurant, color: Color(0xFF81C784)),
        ],
      ),
      if (state.type == 'breast') ...[
        const SizedBox(height: 16),
        // 改造后的时长选择器：支持计时和手动两种模式
        _BreastFeedingDurationSelector(
          state: state,
          onStateChanged: setState,
        ),
      ],
      if (state.type != 'breast') ...[
        const SizedBox(height: 16),
        SheetTextField(
          controller: state.amountController,
          label: '奶量',
          hint: 'ml',
          suffix: 'ml',
        ),
      ],
      const SizedBox(height: 16),
      SheetTextField(
        controller: state.notesController,
        label: '备注',
        hint: '选填',
        maxLines: 2,
      ),
    ];
  }

  @override
  Future<void> saveRecord(BuildContext context, FeedingRecordState state) async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) return;

    // 如果是母乳亲喂且有未保存的计时，自动停止并保存
    int? leftDuration = state.leftDuration;
    int? rightDuration = state.rightDuration;
    int? mixedDuration = state.mixedDuration;

    if (state.type == 'breast') {
      // 如果计时正在进行或有累计时间，自动停止
      if (state.isTimerRunning || state.elapsedSeconds > 0 || state.leftElapsedSeconds > 0 || state.rightElapsedSeconds > 0) {
        // 计算最终时长（秒）
        int left = state.leftElapsedSeconds;
        int right = state.rightElapsedSeconds;

        if (state.activeSide == 'left') {
          left += state.elapsedSeconds;
        } else if (state.activeSide == 'right') {
          right += state.elapsedSeconds;
        }

        // 精确到秒，使用 floor 保留秒数
        leftDuration = left;
        rightDuration = right;
        mixedDuration = null;
      }

      // 如果是手动模式且没有输入，检查控制器文本（输入是分钟，转换为秒存储）
      if (!state.isTimerMode && leftDuration == null && rightDuration == null && mixedDuration == null) {
        final leftInput = int.tryParse(state.leftController.text);
        final rightInput = int.tryParse(state.rightController.text);
        final mixedInput = int.tryParse(state.mixedController.text);
        leftDuration = leftInput != null ? leftInput * 60 : null;
        rightDuration = rightInput != null ? rightInput * 60 : null;
        mixedDuration = mixedInput != null ? mixedInput * 60 : null;
      }
    }

    final record = FeedingRecord(
      id: recordToEdit?.id,
      babyId: currentBaby.id,
      feedTime: state.feedTime,
      amount: double.tryParse(state.amountController.text),
      type: state.type,
      leftDuration: state.type == 'breast' ? leftDuration : null,
      rightDuration: state.type == 'breast' ? rightDuration : null,
      mixedDuration: state.type == 'breast' ? mixedDuration : null,
      notes: state.notesController.text.isEmpty ? null : state.notesController.text,
    );

    final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
    if (recordToEdit != null) {
      await recordsProvider.updateFeedingRecord(record);
    } else {
      await recordsProvider.addFeedingRecord(record);
    }
  }
}

/// 喂养记录表单状态
///
/// 存储喂养记录表单的临时数据，
/// 包括喂养时间、类型、左右侧时长、奶量和备注。
class FeedingRecordState {
  DateTime feedTime;
  String type;
  TextEditingController amountController;
  TextEditingController notesController;

  // 左右侧时长（分钟）
  int? leftDuration;
  int? rightDuration;
  int? mixedDuration;

  // 计时模式相关状态
  bool isTimerMode;           // true=计时模式, false=手动模式
  bool isTimerRunning;        // 计时器是否运行中
  String? activeSide;         // 当前正在计时的侧：'left', 'right', null
  int elapsedSeconds;         // 当前计时的已过秒数
  int leftElapsedSeconds;     // 左侧累计秒数
  int rightElapsedSeconds;     // 右侧累计秒数
  TextEditingController leftController;
  TextEditingController rightController;
  TextEditingController mixedController;

  FeedingRecordState({
    DateTime? feedTime,
    this.type = 'breast',
    TextEditingController? amountController,
    TextEditingController? notesController,
    this.leftDuration,
    this.rightDuration,
    this.mixedDuration,
    this.isTimerMode = false,
    this.isTimerRunning = false,
    this.activeSide,
    this.elapsedSeconds = 0,
    this.leftElapsedSeconds = 0,
    this.rightElapsedSeconds = 0,
    TextEditingController? leftController,
    TextEditingController? rightController,
    TextEditingController? mixedController,
  })  : feedTime = feedTime ?? DateTime.now(),
        amountController = amountController ?? TextEditingController(),
        notesController = notesController ?? TextEditingController(),
        leftController = leftController ?? TextEditingController(),
        rightController = rightController ?? TextEditingController(),
        mixedController = mixedController ?? TextEditingController();

  factory FeedingRecordState.fromRecord(FeedingRecord record) {
    final state = FeedingRecordState(
      feedTime: record.feedTime,
      type: record.type,
      leftDuration: record.leftDuration,
      rightDuration: record.rightDuration,
      mixedDuration: record.mixedDuration,
    );
    // 存储是秒，显示是分钟，需要转换
    if (record.leftDuration != null) {
      state.leftController.text = (record.leftDuration! ~/ 60).toString();
    }
    if (record.rightDuration != null) {
      state.rightController.text = (record.rightDuration! ~/ 60).toString();
    }
    if (record.mixedDuration != null) {
      state.mixedController.text = (record.mixedDuration! ~/ 60).toString();
    }
    state.amountController.text = record.amount?.toString() ?? '';
    state.notesController.text = record.notes ?? '';
    return state;
  }

  /// 计算总时长（分钟）
  int get totalDuration {
    final left = int.tryParse(leftController.text) ?? 0;
    final right = int.tryParse(rightController.text) ?? 0;
    final mixed = int.tryParse(mixedController.text) ?? 0;
    return left + right + mixed;
  }

  /// 格式化秒数为 mm:ss
  String formatSeconds(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// 获取总计时时长字符串（包含当前正在计时的秒数）
  String get totalTimerDisplay {
    final total = leftElapsedSeconds + rightElapsedSeconds + elapsedSeconds;
    final mins = total ~/ 60;
    final secs = total % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// 母乳亲喂时长选择器组件
///
/// 支持两种模式：
/// - 计时模式：开始/暂停/停止，使用计时器记录左右侧时长
/// - 手动模式：手动输入左右侧或混合时长
class _BreastFeedingDurationSelector extends StatefulWidget {
  final FeedingRecordState state;
  final StateSetter onStateChanged;

  const _BreastFeedingDurationSelector({
    required this.state,
    required this.onStateChanged,
  });

  @override
  State<_BreastFeedingDurationSelector> createState() => _BreastFeedingDurationSelectorState();
}

class _BreastFeedingDurationSelectorState extends State<_BreastFeedingDurationSelector> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(String side) {
    // 取消并清理旧定时器
    _timer?.cancel();
    _timer = null;

    // 创建一个新的定时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 检查这个定时器是否还是当前活跃的定时器
      // 如果不是（已被替换），则不再执行
      if (_timer != timer) return;

      widget.onStateChanged(() {
        if (side == 'left') {
          widget.state.leftElapsedSeconds++;
        } else if (side == 'right') {
          widget.state.rightElapsedSeconds++;
        }
      });
    });

    // 更新状态
    widget.onStateChanged(() {
      widget.state.isTimerRunning = true;
      widget.state.activeSide = side;
    });
  }

  void _switchSide(String newSide) {
    // 启动新的计时
    _startTimer(newSide);
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    widget.onStateChanged(() {
      widget.state.isTimerRunning = false;
    });
  }

  void _stopAndSave() {
    _timer?.cancel();
    _timer = null;

    // 计算最终时长（秒）
    int left = widget.state.leftElapsedSeconds;
    int right = widget.state.rightElapsedSeconds;

    // 如果有当前正在计时的，也要加上
    if (widget.state.activeSide == 'left') {
      left += widget.state.elapsedSeconds;
    } else if (widget.state.activeSide == 'right') {
      right += widget.state.elapsedSeconds;
    }

    widget.onStateChanged(() {
      widget.state.isTimerRunning = false;
      widget.state.leftDuration = left; // 精确到秒
      widget.state.rightDuration = right; // 精确到秒
      widget.state.activeSide = null;
      widget.state.elapsedSeconds = 0;
      widget.state.leftElapsedSeconds = 0;
      widget.state.rightElapsedSeconds = 0;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    widget.onStateChanged(() {
      widget.state.isTimerRunning = false;
      widget.state.elapsedSeconds = 0;
      widget.state.leftElapsedSeconds = 0;
      widget.state.rightElapsedSeconds = 0;
      widget.state.activeSide = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 模式切换 Tab
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _resetTimer();
                  widget.onStateChanged(() {
                    widget.state.isTimerMode = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !widget.state.isTimerMode
                        ? const Color(0xFFF48FB1).withAlpha(25)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                    border: Border.all(
                      color: !widget.state.isTimerMode
                          ? const Color(0xFFF48FB1)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '手动输入',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: !widget.state.isTimerMode ? FontWeight.w600 : FontWeight.w500,
                        color: !widget.state.isTimerMode
                            ? const Color(0xFFF48FB1)
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  widget.onStateChanged(() {
                    widget.state.isTimerMode = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.state.isTimerMode
                        ? const Color(0xFFF48FB1).withAlpha(25)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                    border: Border.all(
                      color: widget.state.isTimerMode
                          ? const Color(0xFFF48FB1)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: widget.state.isTimerMode
                              ? const Color(0xFFF48FB1)
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '计时模式',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: widget.state.isTimerMode ? FontWeight.w600 : FontWeight.w500,
                            color: widget.state.isTimerMode
                                ? const Color(0xFFF48FB1)
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 计时模式
        if (widget.state.isTimerMode) ...[
          _buildTimerMode(),
        ] else ...[
          // 手动模式
          _buildManualMode(),
        ],
      ],
    );
  }

  /// 计时模式 UI
  Widget _buildTimerMode() {
    return Column(
      children: [
        // 左侧/右侧切换（按钮上显示带秒数的时间）
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.state.isTimerRunning && widget.state.activeSide == 'left') {
                    // 点击当前激活的左侧，暂停
                    _pauseTimer();
                  } else if (widget.state.isTimerRunning && widget.state.activeSide == 'right') {
                    // 右侧在计时，切换到左侧
                    _switchSide('left');
                  } else if (!widget.state.isTimerRunning) {
                    // 没有在计时，开始左侧计时
                    _startTimer('left');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: widget.state.activeSide == 'left'
                        ? const Color(0xFFF48FB1).withAlpha(25)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.state.activeSide == 'left'
                          ? const Color(0xFFF48FB1)
                          : Colors.grey[300]!,
                      width: widget.state.activeSide == 'left' ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.state.isTimerRunning && widget.state.activeSide == 'left'
                                ? Icons.pause_circle_filled
                                : (widget.state.leftElapsedSeconds > 0 ? Icons.play_circle_filled : Icons.circle),
                            size: 16,
                            color: widget.state.activeSide == 'left'
                                ? const Color(0xFFF48FB1)
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '左侧',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.state.activeSide == 'left'
                                  ? const Color(0xFFF48FB1)
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(widget.state.leftElapsedSeconds),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.state.activeSide == 'left'
                              ? const Color(0xFFF48FB1)
                              : Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.state.isTimerRunning && widget.state.activeSide == 'right') {
                    // 点击当前激活的右侧，暂停
                    _pauseTimer();
                  } else if (widget.state.isTimerRunning && widget.state.activeSide == 'left') {
                    // 左侧在计时，切换到右侧
                    _switchSide('right');
                  } else if (!widget.state.isTimerRunning) {
                    // 没有在计时，开始右侧计时
                    _startTimer('right');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: widget.state.activeSide == 'right'
                        ? const Color(0xFFF48FB1).withAlpha(25)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.state.activeSide == 'right'
                          ? const Color(0xFFF48FB1)
                          : Colors.grey[300]!,
                      width: widget.state.activeSide == 'right' ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.state.isTimerRunning && widget.state.activeSide == 'right'
                                ? Icons.pause_circle_filled
                                : (widget.state.rightElapsedSeconds > 0 ? Icons.play_circle_filled : Icons.circle),
                            size: 16,
                            color: widget.state.activeSide == 'right'
                                ? const Color(0xFFF48FB1)
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '右侧',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.state.activeSide == 'right'
                                  ? const Color(0xFFF48FB1)
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(widget.state.rightElapsedSeconds),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.state.activeSide == 'right'
                              ? const Color(0xFFF48FB1)
                              : Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 重置按钮
        if (widget.state.leftElapsedSeconds > 0 || widget.state.rightElapsedSeconds > 0) ...[
          GestureDetector(
            onTap: _resetTimer,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '重置',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 格式化时长为 mm:ss 或 hh:mm:ss
  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      if (secs > 0) {
        return '${h}h${m}m${secs}s';
      }
      return m > 0 ? '${h}h${m}m' : '${h}h';
    }
    if (secs > 0) {
      return '${mins}m${secs}s';
    }
    return '${mins}m';
  }

  /// 手动模式 UI
  Widget _buildManualMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左右侧输入
        Row(
          children: [
            Expanded(
              child: _buildDurationInput(
                label: '左侧',
                controller: widget.state.leftController,
                onChanged: (value) {
                  widget.onStateChanged(() {
                    widget.state.leftDuration = int.tryParse(value);
                    if (value.isNotEmpty) {
                      widget.state.mixedController.clear();
                      widget.state.mixedDuration = null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDurationInput(
                label: '右侧',
                controller: widget.state.rightController,
                onChanged: (value) {
                  widget.onStateChanged(() {
                    widget.state.rightDuration = int.tryParse(value);
                    if (value.isNotEmpty) {
                      widget.state.mixedController.clear();
                      widget.state.mixedDuration = null;
                    }
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 或分隔符
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '或',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 12),

        // 混合输入
        _buildDurationInput(
          label: '混合（无法区分时）',
          controller: widget.state.mixedController,
          onChanged: (value) {
            widget.onStateChanged(() {
              widget.state.mixedDuration = int.tryParse(value);
              if (value.isNotEmpty) {
                widget.state.leftController.clear();
                widget.state.rightController.clear();
                widget.state.leftDuration = null;
                widget.state.rightDuration = null;
              }
            });
          },
        ),
        const SizedBox(height: 16),

        // 总时长显示
        if (widget.state.totalDuration > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 18, color: Colors.green[400]),
                const SizedBox(width: 8),
                Text(
                  '总时长：${widget.state.totalDuration} 分钟',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDurationInput({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF48FB1),
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                ),
              ),
              Text(
                '分钟',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
