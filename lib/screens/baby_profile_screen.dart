import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../models/baby.dart';
import 'package:intl/intl.dart';
import '../widgets/empty_baby_card.dart';

class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '宝宝信息',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: EmptyBabyCard(
          title: '还没有添加宝宝信息哦~',
          subtitle: '记录宝宝的成长每一刻',
          buttonText: '添加宝宝信息',
          onButtonPressed: () => _showAddBabyDialog(context),
        ),
      ),
    );
  }

  Widget _buildCurrentBabyCard(BuildContext context, Baby baby, BabyProvider babyProvider) {
    final babyColor = baby.gender == 'male' ? const Color(0xFF64B5F6) : const Color(0xFFF48FB1);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: babyColor.withAlpha(50), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: babyColor.withAlpha(25),
                        child: Text(
                          baby.name[0],
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: babyColor,
                          ),
                        ),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: babyColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      baby.gender == 'male' ? Icons.male : Icons.female,
                                      size: 14,
                                      color: babyColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      baby.gender == 'male' ? '男宝宝' : '女宝宝',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: babyColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '今天是你出生的第${baby.ageInDays}天',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: Colors.grey[400]),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditBabyDialog(context, baby);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, baby, babyProvider);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 10),
                            const Text('编辑', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                            const SizedBox(width: 10),
                            Text('删除', style: TextStyle(fontSize: 14, color: Colors.red[400])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('出生日期', DateFormat('yyyy年MM月dd日').format(baby.birthDate)),
                  if (baby.birthWeight != null)
                    _buildInfoRow('出生体重', '${baby.birthWeight}kg'),
                  if (baby.birthHeight != null)
                    _buildInfoRow('出生身高', '${baby.birthHeight}cm'),
                  _buildInfoRow('当前年龄', baby.ageString),
                ],
              ),
            ),
            if (baby.notes != null && baby.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note_outlined, size: 16, color: Colors.orange[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        baby.notes!,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.swap_horiz,
                  color: Colors.orange[400],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '切换宝宝',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...babies.map((baby) {
            final isSelected = baby.id == currentBaby.id;
            final babyColor = baby.gender == 'male' ? const Color(0xFF64B5F6) : const Color(0xFFF48FB1);
            return GestureDetector(
              onTap: isSelected
                  ? null
                  : () {
                      babyProvider.setCurrentBaby(baby);
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? babyColor.withAlpha(15) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: babyColor.withAlpha(100), width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: babyColor.withAlpha(50),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: babyColor.withAlpha(25),
                        child: Text(
                          baby.name[0],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: babyColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            baby.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? babyColor : const Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            baby.ageString,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 16,
                        ),
                      )
                    else
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[300],
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddBabyButton(BuildContext context) {
    return Center(
      child: _buildMinimalistButton(
        text: '+ 添加宝宝信息',
        onPressed: () => _showAddBabyDialog(context),
        isPrimary: true,
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
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部拖动条
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 标题
                  const Text(
                    '添加宝宝信息',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '记录宝宝的基本信息',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 宝宝姓名
                  _buildMinimalistTextField(
                    controller: nameController,
                    label: '宝宝姓名',
                    hint: '请输入宝宝姓名',
                    isRequired: true,
                  ),
                  const SizedBox(height: 24),

                  // 出生日期
                  _buildMinimalistDatePicker(
                    context: context,
                    label: '出生日期',
                    selectedDate: selectedDate,
                    onDateChanged: (date) => setState(() => selectedDate = date),
                  ),
                  const SizedBox(height: 24),

                  // 性别选择
                  _buildMinimalistGenderSelector(
                    selectedGender: selectedGender,
                    onGenderChanged: (gender) => setState(() => selectedGender = gender),
                  ),
                  const SizedBox(height: 24),

                  // 出生体重和身高
                  Row(
                    children: [
                      Expanded(
                        child: _buildMinimalistTextField(
                          controller: birthWeightController,
                          label: '出生体重',
                          hint: 'kg',
                          suffix: 'kg',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMinimalistTextField(
                          controller: birthHeightController,
                          label: '出生身高',
                          hint: 'cm',
                          suffix: 'cm',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 备注
                  _buildMinimalistTextField(
                    controller: notesController,
                    label: '备注',
                    hint: '选填，可添加备注信息',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // 按钮组
                  Row(
                    children: [
                      Expanded(
                        child: _buildMinimalistButton(
                          text: '取消',
                          onPressed: () => Navigator.pop(context),
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMinimalistButton(
                          text: '保存',
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('请输入宝宝姓名'),
                                  backgroundColor: Colors.orange[400],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
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
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 极简风格文本输入框
  Widget _buildMinimalistTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? suffix,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[400],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D2D2D),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // 极简风格日期选择器
  Widget _buildMinimalistDatePicker({
    required BuildContext context,
    required String label,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.orange[400]!,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: const Color(0xFF2D2D2D),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDateChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('yyyy年MM月dd日').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 极简风格性别选择器
  Widget _buildMinimalistGenderSelector({
    required String selectedGender,
    required ValueChanged<String> onGenderChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '性别',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                gender: 'male',
                label: '男宝宝',
                icon: Icons.male,
                isSelected: selectedGender == 'male',
                onTap: () => onGenderChanged('male'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(
                gender: 'female',
                label: '女宝宝',
                icon: Icons.female,
                isSelected: selectedGender == 'female',
                onTap: () => onGenderChanged('female'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String gender,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = gender == 'male' ? const Color(0xFF64B5F6) : const Color(0xFFF48FB1);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? color : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 极简风格按钮
  Widget _buildMinimalistButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF8A65) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : Colors.grey[600],
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
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部拖动条
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 标题
                  const Text(
                    '编辑宝宝信息',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '修改宝宝的基本信息',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 宝宝姓名
                  _buildMinimalistTextField(
                    controller: nameController,
                    label: '宝宝姓名',
                    hint: '请输入宝宝姓名',
                    isRequired: true,
                  ),
                  const SizedBox(height: 24),

                  // 出生日期
                  _buildMinimalistDatePicker(
                    context: context,
                    label: '出生日期',
                    selectedDate: selectedDate,
                    onDateChanged: (date) => setState(() => selectedDate = date),
                  ),
                  const SizedBox(height: 24),

                  // 性别选择
                  _buildMinimalistGenderSelector(
                    selectedGender: selectedGender,
                    onGenderChanged: (gender) => setState(() => selectedGender = gender),
                  ),
                  const SizedBox(height: 24),

                  // 出生体重和身高
                  Row(
                    children: [
                      Expanded(
                        child: _buildMinimalistTextField(
                          controller: birthWeightController,
                          label: '出生体重',
                          hint: 'kg',
                          suffix: 'kg',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMinimalistTextField(
                          controller: birthHeightController,
                          label: '出生身高',
                          hint: 'cm',
                          suffix: 'cm',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 备注
                  _buildMinimalistTextField(
                    controller: notesController,
                    label: '备注',
                    hint: '选填，可添加备注信息',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // 按钮组
                  Row(
                    children: [
                      Expanded(
                        child: _buildMinimalistButton(
                          text: '取消',
                          onPressed: () => Navigator.pop(context),
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMinimalistButton(
                          text: '保存',
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('请输入宝宝姓名'),
                                  backgroundColor: Colors.orange[400],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
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
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
          const SnackBar(content: Text('宝宝信息添加成功！'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加宝宝信息失败，请重试'), backgroundColor: Colors.red),
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
        content: Text('确定要删除 ${baby.name} 的信息吗？\n所有相关记录也将被删除。'),
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
                    const SnackBar(content: Text('宝宝信息已删除'), backgroundColor: Colors.green),
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
