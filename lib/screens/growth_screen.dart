import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/growth_record.dart';
import 'package:intl/intl.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _headCircumferenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
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
    _heightController.dispose();
    _weightController.dispose();
    _headCircumferenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成长记录'),
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
          final growthRecords = recordsProvider.growthRecords;

          return Column(
            children: [
              // 今日统计卡片
              _buildTodayStatsCard(recordsProvider, currentBaby?.id),
              // 快速记录区域
              _buildQuickRecordArea(context, currentBaby?.id),
              // 历史记录列表
              Expanded(
                child: _buildRecordsList(growthRecords),
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
    final todayGrowth = recordsProvider.growthRecords
        .where((r) => r.recordDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    if (todayGrowth.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('今日成长记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('暂无今日记录', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final lastRecord = todayGrowth.last;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日成长记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (lastRecord.height != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('身高', '${lastRecord.height}cm', Colors.blue),
                  _buildStatItem('体重', '${lastRecord.weight}kg', Colors.purple),
                ],
              ),
            if (lastRecord.headCircumference != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('头围', '${lastRecord.headCircumference}cm', Colors.orange),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickButton(context, '量身高', Icons.straighten, Colors.blue, () => _showQuickHeightDialog(context, babyId)),
                _buildQuickButton(context, '称体重', Icons.scale, Colors.purple, () => _showQuickWeightDialog(context, babyId)),
                _buildQuickButton(context, '量头围', Icons.circle, Colors.orange, () => _showQuickHeadCircumferenceDialog(context, babyId)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecordsList(List<GrowthRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text('暂无成长记录，点击右下角添加记录'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.child_care, color: Colors.white),
            ),
            title: Text(DateFormat('yyyy-MM-dd').format(record.recordDate)),
            subtitle: Text(
              '${record.height != null ? '身高:${record.height}cm ' : ''}'
              '${record.weight != null ? '体重:${record.weight}kg ' : ''}'
              '${record.headCircumference != null ? '头围:${record.headCircumference}cm' : ''}',
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
                PopupMenuItem(value: 'edit', child: const Text('编辑')),
                PopupMenuItem(value: 'delete', child: const Text('删除')),
              ],
            ),
            children: [
              if (record.notes != null)
                ListTile(
                  leading: const Icon(Icons.note, color: Colors.grey),
                  title: Text(record.notes!),
                ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.grey),
                title: Text('记录时间: ${DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt)}'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickHeightDialog(BuildContext context, String babyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录身高'),
        content: TextField(
          controller: _heightController,
          decoration: const InputDecoration(hintText: '输入身高(cm)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final height = double.tryParse(_heightController.text);
              if (height != null) {
                _saveGrowthRecord(context, babyId, height: height);
                _heightController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showQuickWeightDialog(BuildContext context, String babyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录体重'),
        content: TextField(
          controller: _weightController,
          decoration: const InputDecoration(hintText: '输入体重(kg)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(_weightController.text);
              if (weight != null) {
                _saveGrowthRecord(context, babyId, weight: weight);
                _weightController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showQuickHeadCircumferenceDialog(BuildContext context, String babyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录头围'),
        content: TextField(
          controller: _headCircumferenceController,
          decoration: const InputDecoration(hintText: '输入头围(cm)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final headCircumference = double.tryParse(_headCircumferenceController.text);
              if (headCircumference != null) {
                _saveGrowthRecord(context, babyId, headCircumference: headCircumference);
                _headCircumferenceController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _saveGrowthRecord(BuildContext context, String babyId, {double? height, double? weight, double? headCircumference}) {
    final record = GrowthRecord(
      babyId: babyId,
      recordDate: _selectedDate,
      height: height,
      weight: weight,
      headCircumference: headCircumference,
    );
    Provider.of<RecordsProvider>(context, listen: false).addGrowthRecord(record);
  }

  void _showAddRecordDialog(BuildContext context) {
    _selectedDate = DateTime.now();
    _heightController.clear();
    _weightController.clear();
    _headCircumferenceController.clear();
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
                  '添加成长记录',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // 日期选择
                ListTile(
                  title: const Text('记录日期'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                ),
                // 身高
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: '身高 (cm)',
                    hintText: '请输入身高',
                  ),
                  keyboardType: TextInputType.number,
                ),
                // 体重
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: '体重 (kg)',
                    hintText: '请输入体重',
                  ),
                  keyboardType: TextInputType.number,
                ),
                // 头围
                TextFormField(
                  controller: _headCircumferenceController,
                  decoration: const InputDecoration(
                    labelText: '头围 (cm)',
                    hintText: '请输入头围',
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

  void _showEditRecordDialog(BuildContext context, GrowthRecord record) {
    _selectedDate = record.recordDate;
    _heightController.text = record.height?.toString() ?? '';
    _weightController.text = record.weight?.toString() ?? '';
    _headCircumferenceController.text = record.headCircumference?.toString() ?? '';
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
                  '编辑成长记录',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('记录日期'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: '身高 (cm)',
                    hintText: '请输入身高',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: '体重 (kg)',
                    hintText: '请输入体重',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _headCircumferenceController,
                  decoration: const InputDecoration(
                    labelText: '头围 (cm)',
                    hintText: '请输入头围',
                  ),
                  keyboardType: TextInputType.number,
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

    final record = GrowthRecord(
      babyId: currentBaby.id,
      recordDate: _selectedDate,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      headCircumference: double.tryParse(_headCircumferenceController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Provider.of<RecordsProvider>(context, listen: false).addGrowthRecord(record);
    Navigator.pop(context);
  }

  void _updateRecord(BuildContext context, GrowthRecord oldRecord) {
    final record = oldRecord.copyWith(
      recordDate: _selectedDate,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      headCircumference: double.tryParse(_headCircumferenceController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Provider.of<RecordsProvider>(context, listen: false).updateGrowthRecord(record);
    Navigator.pop(context);
  }

  void _deleteRecord(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条成长记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<RecordsProvider>(context, listen: false).deleteGrowthRecord(recordId);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
