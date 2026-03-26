import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../models/baby.dart';
import 'package:intl/intl.dart';

class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宝宝档案'),
      ),
      body: Consumer<BabyProvider>(
        builder: (context, babyProvider, child) {
          if (babyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (babyProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(babyProvider.error!, style: TextStyle(color: Colors.red[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 重新初始化
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final babies = babyProvider.babies;
          final currentBaby = babyProvider.currentBaby;

          if (babies.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentBabyCard(context, currentBaby!, babyProvider),
                const SizedBox(height: 20),
                _buildBabyListSection(context, babies, currentBaby, babyProvider),
                const SizedBox(height: 20),
                _buildAddBabyButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '还没有添加宝宝哦~',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮添加宝宝档案',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddBabyDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('添加宝宝'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBabyCard(BuildContext context, Baby baby, BabyProvider babyProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: baby.gender == 'male' ? Colors.blue : Colors.pink,
                  child: Text(
                    baby.name[0],
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baby.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            baby.gender == 'male' ? Icons.male : Icons.female,
                            size: 16,
                            color: baby.gender == 'male' ? Colors.blue : Colors.pink,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            baby.gender == 'male' ? '男宝宝' : '女宝宝',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '今天是你出生的第${baby.ageInDays}天',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditBabyDialog(context, baby);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, baby, babyProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('编辑')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow('出生日期', DateFormat('yyyy年MM月dd日').format(baby.birthDate)),
            if (baby.birthWeight != null)
              _buildInfoRow('出生体重', '${baby.birthWeight}kg'),
            if (baby.birthHeight != null)
              _buildInfoRow('出生身高', '${baby.birthHeight}cm'),
            _buildInfoRow('当前年龄', baby.ageString),
            if (baby.notes != null && baby.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '备注: ${baby.notes}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBabyListSection(BuildContext context, List<Baby> babies, Baby currentBaby, BabyProvider babyProvider) {
    if (babies.length <= 1) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '切换宝宝',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...babies.map((baby) {
              final isSelected = baby.id == currentBaby.id;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: baby.gender == 'male' ? Colors.blue : Colors.pink,
                  child: Text(
                    baby.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(baby.name),
                subtitle: Text(baby.ageString),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: isSelected
                    ? null
                    : () {
                        babyProvider.setCurrentBaby(baby);
                      },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBabyButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _showAddBabyDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('添加宝宝'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  void _showAddBabyDialog(BuildContext context) {
    final nameController = TextEditingController();
    final birthWeightController = TextEditingController();
    final birthHeightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedGender = 'male';

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '添加宝宝',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '宝宝姓名 *',
                    hintText: '请输入宝宝姓名',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('出生日期 *'),
                  subtitle: Text(DateFormat('yyyy年MM月dd日').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                const Text('性别 *', style: TextStyle(fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('男宝宝'),
                  value: 'male',
                  groupValue: selectedGender,
                  onChanged: (value) => setState(() => selectedGender = value!),
                ),
                RadioListTile<String>(
                  title: const Text('女宝宝'),
                  value: 'female',
                  groupValue: selectedGender,
                  onChanged: (value) => setState(() => selectedGender = value!),
                ),
                TextField(
                  controller: birthWeightController,
                  decoration: const InputDecoration(
                    labelText: '出生体重 (kg)',
                    hintText: '可选',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: birthHeightController,
                  decoration: const InputDecoration(
                    labelText: '出生身高 (cm)',
                    hintText: '可选',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    hintText: '可选',
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
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请输入宝宝姓名')),
                          );
                          return;
                        }
                        _saveBaby(
                          context,
                          name: nameController.text.trim(),
                          birthDate: selectedDate,
                          gender: selectedGender,
                          birthWeight: double.tryParse(birthWeightController.text),
                          birthHeight: double.tryParse(birthHeightController.text),
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                        Navigator.pop(context);
                      },
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

  void _showEditBabyDialog(BuildContext context, Baby baby) {
    final nameController = TextEditingController(text: baby.name);
    final birthWeightController = TextEditingController(text: baby.birthWeight?.toString() ?? '');
    final birthHeightController = TextEditingController(text: baby.birthHeight?.toString() ?? '');
    final notesController = TextEditingController(text: baby.notes ?? '');
    DateTime selectedDate = baby.birthDate;
    String selectedGender = baby.gender;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '编辑宝宝信息',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '宝宝姓名 *',
                    hintText: '请输入宝宝姓名',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('出生日期 *'),
                  subtitle: Text(DateFormat('yyyy年MM月dd日').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                const Text('性别 *', style: TextStyle(fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('男宝宝'),
                  value: 'male',
                  groupValue: selectedGender,
                  onChanged: (value) => setState(() => selectedGender = value!),
                ),
                RadioListTile<String>(
                  title: const Text('女宝宝'),
                  value: 'female',
                  groupValue: selectedGender,
                  onChanged: (value) => setState(() => selectedGender = value!),
                ),
                TextField(
                  controller: birthWeightController,
                  decoration: const InputDecoration(
                    labelText: '出生体重 (kg)',
                    hintText: '可选',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: birthHeightController,
                  decoration: const InputDecoration(
                    labelText: '出生身高 (cm)',
                    hintText: '可选',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    hintText: '可选',
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
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请输入宝宝姓名')),
                          );
                          return;
                        }
                        _updateBaby(
                          context,
                          baby: baby,
                          name: nameController.text.trim(),
                          birthDate: selectedDate,
                          gender: selectedGender,
                          birthWeight: double.tryParse(birthWeightController.text),
                          birthHeight: double.tryParse(birthHeightController.text),
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                        Navigator.pop(context);
                      },
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

  Future<void> _saveBaby(
    BuildContext context, {
    required String name,
    required DateTime birthDate,
    required String gender,
    double? birthWeight,
    double? birthHeight,
    String? notes,
  }) async {
    final baby = Baby(
      name: name,
      birthDate: birthDate,
      gender: gender,
      birthWeight: birthWeight,
      birthHeight: birthHeight,
      notes: notes,
    );
    final success = await Provider.of<BabyProvider>(context, listen: false).addBaby(baby);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('宝宝添加成功！'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加宝宝失败，请重试'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateBaby(
    BuildContext context, {
    required Baby baby,
    required String name,
    required DateTime birthDate,
    required String gender,
    double? birthWeight,
    double? birthHeight,
    String? notes,
  }) async {
    final updatedBaby = baby.copyWith(
      name: name,
      birthDate: birthDate,
      gender: gender,
      birthWeight: birthWeight,
      birthHeight: birthHeight,
      notes: notes,
    );
    final success = await Provider.of<BabyProvider>(context, listen: false).updateBaby(updatedBaby);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('宝宝信息更新成功！'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新宝宝信息失败，请重试'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Baby baby, BabyProvider babyProvider) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${baby.name} 的档案吗？\n所有相关记录也将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await babyProvider.deleteBaby(baby.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('宝宝已删除'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除失败，请重试'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
