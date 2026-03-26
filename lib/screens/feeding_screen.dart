import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/feeding_record.dart';
import 'package:intl/intl.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  String _selectedType = 'breast';
  String? _selectedMethod;
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
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('喂养记录'),
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
          final feedingRecords = recordsProvider.feedingRecords;

          return Column(
            children: [
              // 今日统计卡片
              _buildTodayStatsCard(recordsProvider, currentBaby?.id),
              // 快速记录区域
              _buildQuickRecordArea(context, currentBaby?.id),
              // 历史记录列表
              Expanded(
                child: _buildRecordsList(feedingRecords),
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
    final todayStats = recordsProvider.getTodayStats();
    final todayFeeding = recordsProvider.feedingRecords
        .where((r) => r.feedTime.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日喂养统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('次数', '${todayFeeding.length}次', Colors.orange),
                _buildStatItem('总量', '${todayStats['totalFeedingAmount'].toStringAsFixed(1)}ml', Colors.blue),
                _buildStatItem('平均间隔', _calculateAverageInterval(todayFeeding), Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAverageInterval(List<FeedingRecord> records) {
    if (records.length < 2) return '暂无数据';

    records.sort((a, b) => b.feedTime.compareTo(a.feedTime));
    final intervals = <Duration>[];

    for (int i = 0; i < records.length - 1; i++) {
      intervals.add(records[i].feedTime.difference(records[i + 1] as DateTime));
    }

    final averageMinutes = intervals.fold<int>(
      0,
      (sum, interval) => sum + interval.inMinutes,
    ) ~/ intervals.length;

    if (averageMinutes < 60) {
      return '$averageMinutes分钟';
    } else {
      final hours = averageMinutes ~/ 60;
      final minutes = averageMinutes % 60;
      return '$hours小时$minutes分钟';
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
                  '母乳',
                  Icons.favorite,
                  Colors.pink,
                  () => _quickRecord('breast', babyId),
                ),
                _buildQuickButton(
                  context,
                  '奶粉',
                  Icons.local_dining,
                  Colors.orange,
                  () => _quickRecord('bottle', babyId),
                ),
                _buildQuickButton(
                  context,
                  '辅食',
                  Icons.restaurant,
                  Colors.green,
                  () => _quickRecord('solid', babyId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
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

  Widget _buildRecordsList(List<FeedingRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Text('暂无喂养记录，点击右下角添加记录'),
      );
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
              backgroundColor: Colors.orange,
              child: const Icon(Icons.restaurant, color: Colors.white),
            ),
            title: Text('${record.typeDisplayName} ${record.amount != null ? '${record.amount}ml' : ''}'),
            subtitle: Text(
              '${DateFormat('MM-dd HH:mm').format(record.feedTime)}${record.method != null ? ' | 方式：${record.methodDisplayName}' : ''}${record.notes != null ? ' | ${record.notes}' : ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditRecordDialog(context, record);
                } else if (value == 'delete') {
                  _deleteRecord(context, record.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _quickRecord(String type, String babyId) {
    final record = FeedingRecord(
      babyId: babyId,
      feedTime: DateTime.now(),
      type: type,
    );
    Provider.of<RecordsProvider>(context, listen: false).addFeedingRecord(record);
  }

  void _showAddRecordDialog(BuildContext context) {
    _selectedDateTime = DateTime.now();
    _selectedType = 'breast';
    _selectedMethod = null;
    _amountController.clear();
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
                  '添加喂养记录',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // 喂养时间
                ListTile(
                  title: const Text('喂养时间'),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedDateTime = DateTime(
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
                // 喂养类型
                RadioListTile<String>(
                  title: const Text('母乳'),
                  value: 'breast',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('奶粉'),
                  value: 'bottle',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('辅食'),
                  value: 'solid',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                // 喂养方式（仅母乳）
                if (_selectedType == 'breast')
                  Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('左侧'),
                        value: 'left',
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('右侧'),
                        value: 'right',
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('混合'),
                        value: 'mixed',
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value!),
                      ),
                    ],
                  ),
                // 奶量
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: '奶量 (ml)',
                    hintText: '请输入奶量',
                  ),
                  keyboardType: TextInputType.number,
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

  void _showEditRecordDialog(BuildContext context, FeedingRecord record) {
    _selectedDateTime = record.feedTime;
    _selectedType = record.type;
    _selectedMethod = record.method;
    _amountController.text = record.amount?.toString() ?? '';
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
                  '编辑喂养记录',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // 喂养时间
                ListTile(
                  title: const Text('喂养时间'),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedDateTime = DateTime(
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
                // 喂养类型
                RadioListTile<String>(
                  title: const Text('母乳'),
                  value: 'breast',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('奶粉'),
                  value: 'bottle',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('辅食'),
                  value: 'solid',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                // 喂养方式（仅母乳）
                if (_selectedType == 'breast')
                  Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('左侧'),
                        value: 'left',
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('右侧'),
                        value: 'right',
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('混合'),
                        value: 'mixed',
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value!),
                      ),
                    ],
                  ),
                // 奶量
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: '奶量 (ml)',
                    hintText: '请输入奶量',
                  ),
                  keyboardType: TextInputType.number,
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
    if (!_formKey.currentState!.validate()) return;

    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;

    if (currentBaby == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加宝宝档案')),
      );
      return;
    }

    final record = FeedingRecord(
      babyId: currentBaby.id,
      feedTime: _selectedDateTime,
      amount: double.tryParse(_amountController.text),
      type: _selectedType,
      method: _selectedMethod,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Provider.of<RecordsProvider>(context, listen: false).addFeedingRecord(record);
    Navigator.pop(context);
  }

  void _updateRecord(BuildContext context, FeedingRecord oldRecord) {
    if (!_formKey.currentState!.validate()) return;

    final record = oldRecord.copyWith(
      feedTime: _selectedDateTime,
      amount: double.tryParse(_amountController.text),
      type: _selectedType,
      method: _selectedMethod,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Provider.of<RecordsProvider>(context, listen: false).updateFeedingRecord(record);
    Navigator.pop(context);
  }

  void _deleteRecord(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条喂养记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<RecordsProvider>(context, listen: false).deleteFeedingRecord(recordId);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}