import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/diaper_record.dart';
import 'package:intl/intl.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  String _selectedType = 'wet';
  String _selectedStatus = 'normal';
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
        title: const Text('换尿布记录'),
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
          final diaperRecords = recordsProvider.diaperRecords;

          return Column(
            children: [
              // 今日统计卡片
              _buildTodayStatsCard(recordsProvider, currentBaby?.id),
              // 快速记录区域
              _buildQuickRecordArea(context, currentBaby?.id),
              // 历史记录列表
              Expanded(
                child: _buildRecordsList(diaperRecords),
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
    final todayDiaper = recordsProvider.diaperRecords
        .where((r) => r.changeTime.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日尿布统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('次数', '${todayDiaper.length}次', Colors.blue),
                _buildStatItem('小便', '${todayDiaper.where((r) => r.type == 'wet').length}次', Colors.lightBlue),
                _buildStatItem('大便', '${todayDiaper.where((r) => r.type == 'dirty').length}次', Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('正常', '${todayDiaper.where((r) => r.status == 'normal').length}次', Colors.green),
                _buildStatItem('警告', '${todayDiaper.where((r) => r.status != 'normal').length}次', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickTypeButton(context, '小便', Icons.water_drop, Colors.lightBlue, 'wet', () => _quickRecord(babyId, 'wet')),
                _buildQuickTypeButton(context, '大便', Icons.wc, Colors.brown, 'dirty', () => _quickRecord(babyId, 'dirty')),
                _buildQuickTypeButton(context, '混合', Icons.badge, Colors.orange, 'mixed', () => _quickRecord(babyId, 'mixed')),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const Text('状态', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickStatusButton(context, '正常', Icons.check_circle, Colors.green, 'normal', () => _quickRecord(babyId, 'wet', status: 'normal')),
                _buildQuickStatusButton(context, '稀便', Icons.remove_circle, Colors.orange, 'loose', () => _quickRecord(babyId, 'dirty', status: 'loose')),
                _buildQuickStatusButton(context, '硬便', Icons.block, Colors.deepOrange, 'hard', () => _quickRecord(babyId, 'dirty', status: 'hard')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTypeButton(
      BuildContext context, String label, IconData icon, Color color, String type, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickStatusButton(
      BuildContext context, String label, IconData icon, Color color, String status, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecordsList(List<DiaperRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text('暂无换尿布记录，点击右下角添加记录'));
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
              backgroundColor: _getStatusColor(record.status),
              child: Icon(
                record.type == 'dirty' ? Icons.wc : Icons.water_drop,
                color: Colors.white,
              ),
            ),
            title: Text('${record.typeDisplayName} ${record.statusDisplayName}'),
            subtitle: Text(
              '${DateFormat('MM-dd HH:mm').format(record.changeTime)}${record.notes != null ? ' | ${record.notes}' : ''}',
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'normal':
        return Colors.green;
      case 'loose':
        return Colors.orange;
      case 'hard':
        return Colors.deepOrange;
      case 'blood':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _quickRecord(String babyId, String type, {String status = 'normal'}) {
    final record = DiaperRecord(
      babyId: babyId,
      changeTime: DateTime.now(),
      type: type,
      status: status,
    );
    Provider.of<RecordsProvider>(context, listen: false).addDiaperRecord(record);
  }

  void _showAddRecordDialog(BuildContext context) {
    _selectedDateTime = DateTime.now();
    _selectedType = 'wet';
    _selectedStatus = 'normal';
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
                  '添加换尿布记录',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // 时间选择
                ListTile(
                  title: const Text('时间'),
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
                // 类型选择
                const Text('类型', style: TextStyle(fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('小便'),
                  value: 'wet',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('大便'),
                  value: 'dirty',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('混合'),
                  value: 'mixed',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                // 状态选择
                const Text('状态', style: TextStyle(fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('正常'),
                  value: 'normal',
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('稀便'),
                  value: 'loose',
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('硬便'),
                  value: 'hard',
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('带血'),
                  value: 'blood',
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value!),
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

  void _showEditRecordDialog(BuildContext context, DiaperRecord record) {
    _selectedDateTime = record.changeTime;
    _selectedType = record.type;
    _selectedStatus = record.status;
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
                  '编辑换尿布记录',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('时间'),
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
                const Text('类型', style: TextStyle(fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('小便'),
                  value: 'wet',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('大便'),
                  value: 'dirty',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('混合'),
                  value: 'mixed',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const Text('状态', style: TextStyle(fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('正常'),
                  value: 'normal',
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('稀便'),
                  value: 'loose',
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('硬便'),
                  value: 'hard',
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('带血'),
                  value: 'blood',
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value!),
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

    final record = DiaperRecord(
      babyId: currentBaby.id,
      changeTime: _selectedDateTime,
      type: _selectedType,
      status: _selectedStatus,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Provider.of<RecordsProvider>(context, listen: false).addDiaperRecord(record);
    Navigator.pop(context);
  }

  void _updateRecord(BuildContext context, DiaperRecord oldRecord) {
    final record = oldRecord.copyWith(
      changeTime: _selectedDateTime,
      type: _selectedType,
      status: _selectedStatus,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Provider.of<RecordsProvider>(context, listen: false).updateDiaperRecord(record);
    Navigator.pop(context);
  }

  void _deleteRecord(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条换尿布记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<RecordsProvider>(context, listen: false).deleteDiaperRecord(recordId);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
