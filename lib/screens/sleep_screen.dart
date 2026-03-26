import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/sleep_record.dart';
import 'package:intl/intl.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime? _endTime;
  int _selectedQuality = 3;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecordsProvider>(context, listen: false).loadAllRecords();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('睡眠记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<RecordsProvider>(context, listen: false).loadAllRecords();
            },
          ),
        ],
      ),
      body: Consumer2<RecordsProvider, BabyProvider>(
        builder: (context, recordsProvider, babyProvider, child) {
          if (recordsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentBaby = babyProvider.currentBaby;
          final sleepRecords = recordsProvider.sleepRecords;

          return Column(
            children: [
              // 今日统计卡片
              _buildTodayStatsCard(recordsProvider, currentBaby?.id),
              // 快速记录区域
              _buildQuickRecordArea(context, currentBaby?.id),
              // 历史记录列表
              Expanded(
                child: _buildRecordsList(sleepRecords),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodayStatsCard(RecordsProvider recordsProvider, String? babyId) {
    final todaySleep = recordsProvider.sleepRecords
        .where((r) => r.startTime.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    final totalDuration = todaySleep.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + (r.duration ?? Duration.zero),
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日睡眠统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('次数', '${todaySleep.length}次', Colors.purple),
                _buildStatItem('总时长', _formatDuration(totalDuration), Colors.blue),
                _buildStatItem('平均质量', _calculateAverageQuality(todaySleep), Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) {
      return '$minutes分钟';
    }
    return '$hours小时$minutes分钟';
  }

  String _calculateAverageQuality(List<SleepRecord> records) {
    if (records.isEmpty) return '暂无数据';

    final average = records.fold<int>(
      0,
      (sum, r) => sum + (r.quality ?? 0),
    ) ~/ records.length;

    switch (average) {
      case 1:
        return '很差';
      case 2:
        return '较差';
      case 3:
        return '一般';
      case 4:
        return '良好';
      case 5:
        return '优秀';
      default:
        return '$average分';
    }
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildQuickRecordArea(BuildContext context, String? babyId) {
    if (babyId == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('请先添加宝宝档案'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/baby-profile'),
                child: const Text('添加宝宝'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速记录',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickButton(
                  context,
                  '午睡',
                  Icons.wb_sunny,
                  Colors.orange,
                  () => _quickRecord(babyId, false),
                ),
                _buildQuickButton(
                  context,
                  '夜间',
                  Icons.nightlight_round,
                  Colors.blue,
                  () => _quickRecord(babyId, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(
      BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecordsList(List<SleepRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text('暂无睡眠记录，点击右下角添加记录'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: const Icon(Icons.nightlight, color: Colors.white),
            ),
            title: Text(
              '${record.type} ${record.durationString ?? '未结束'}',
            ),
            subtitle: Text(
              '${DateFormat('MM-dd HH:mm').format(record.startTime)}${record.endTime != null ? ' - ${DateFormat('HH:mm').format(record.endTime!)}' : ''}${record.notes != null ? ' | ${record.notes}' : ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditRecordDialog(context, record);
                } else if (value == 'end') {
                  _endSleepRecord(context, record);
                } else if (value == 'delete') {
                  _deleteRecord(context, record.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                if (record.endTime == null) const PopupMenuItem(value: 'end', child: Text('结束睡眠')),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _quickRecord(String babyId, bool isNightSleep) {
    final record = SleepRecord(
      babyId: babyId,
      startTime: DateTime.now(),
    );
    Provider.of<RecordsProvider>(context, listen: false).addSleepRecord(record);
  }

  void _showAddRecordDialog(BuildContext context) {
    _startTime = DateTime.now();
    _endTime = null;
    _selectedQuality = 3;
    _notesController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '添加睡眠记录',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // 睡眠开始时间
                ListTile(
                  title: const Text('开始时间'),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_startTime)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_startTime),
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                // 睡眠质量
                const Text('睡眠质量', style: TextStyle(fontSize: 16)),
                ListTile(
                  title: Text(_getQualityText(_selectedQuality)),
                  subtitle: const Text('1=很差, 5=优秀'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(() {
                          if (_selectedQuality > 1) _selectedQuality--;
                        }),
                      ),
                      Text('$_selectedQuality'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() {
                          if (_selectedQuality < 5) _selectedQuality++;
                        }),
                      ),
                    ],
                  ),
                ),
                // 备注
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    hintText: '添加备注信息',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _saveRecord(context),
                      child: const Text('保存'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getQualityText(int quality) {
    switch (quality) {
      case 1:
        return '很差';
      case 2:
        return '较差';
      case 3:
        return '一般';
      case 4:
        return '良好';
      case 5:
        return '优秀';
      default:
        return '未知';
    }
  }

  void _showEditRecordDialog(BuildContext context, SleepRecord record) {
    _startTime = record.startTime;
    _endTime = record.endTime;
    _selectedQuality = record.quality ?? 3;
    _notesController.text = record.notes ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '编辑睡眠记录',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('开始时间'),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_startTime)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_startTime),
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                if (record.endTime == null)
                  SwitchListTile(
                    title: const Text('已结束'),
                    value: _endTime != null,
                    onChanged: (value) => setState(() => _endTime = value ? DateTime.now() : null),
                  ),
                ListTile(
                  title: Text(_getQualityText(_selectedQuality)),
                  subtitle: const Text('1=很差, 5=优秀'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(() {
                          if (_selectedQuality > 1) _selectedQuality--;
                        }),
                      ),
                      Text('$_selectedQuality'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() {
                          if (_selectedQuality < 5) _selectedQuality++;
                        }),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    hintText: '添加备注信息',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _updateRecord(context, record),
                      child: const Text('保存'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveRecord(BuildContext context) {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;

    if (currentBaby == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加宝宝档案')),
      );
      return;
    }

    final record = SleepRecord(
      babyId: currentBaby.id,
      startTime: _startTime,
      endTime: _endTime,
      quality: _selectedQuality,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Provider.of<RecordsProvider>(context, listen: false).addSleepRecord(record);
    Navigator.pop(context);
  }

  void _updateRecord(BuildContext context, SleepRecord oldRecord) {
    final record = oldRecord.copyWith(
      startTime: _startTime,
      endTime: _endTime,
      quality: _selectedQuality,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Provider.of<RecordsProvider>(context, listen: false).updateSleepRecord(record);
    Navigator.pop(context);
  }

  void _endSleepRecord(BuildContext context, SleepRecord record) {
    final updatedRecord = record.copyWith(
      endTime: DateTime.now(),
    );
    Provider.of<RecordsProvider>(context, listen: false).updateSleepRecord(updatedRecord);
  }

  void _deleteRecord(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条睡眠记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<RecordsProvider>(context, listen: false).deleteSleepRecord(recordId);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
