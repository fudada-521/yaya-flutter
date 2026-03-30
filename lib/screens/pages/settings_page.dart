import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/records_provider.dart';
import '../../services/backup_service.dart';

/// 设置页面
///
/// 包含通用设置（通知提醒、主题设置、语言设置）、
/// 数据管理（数据备份、数据恢复、清除所有数据）、
/// 关于信息（关于芽芽日记、隐私政策、用户协议）。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BackupService _backupService = BackupService();
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _clearDataConfirmed = false; // 清除数据确认状态

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSettingsSection(
            context,
            title: '通用设置',
            icon: Icons.tune,
            iconColor: Colors.orange,
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.notifications_outlined,
                title: '通知提醒',
                subtitle: '设置喂养、睡眠等提醒',
                onTap: () => _showNotificationSettings(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.palette_outlined,
                title: '主题设置',
                subtitle: '深色模式、主题色',
                onTap: () => _showThemeSettings(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.language_outlined,
                title: '语言设置',
                subtitle: '简体中文',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            title: '数据管理',
            icon: Icons.folder_outlined,
            iconColor: Colors.blue,
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.backup_outlined,
                title: '数据备份',
                subtitle: '导出宝宝记录数据',
                trailing: _isBackingUp
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _isBackingUp ? null : () => _handleBackup(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.restore_outlined,
                title: '数据恢复',
                subtitle: '从备份文件恢复数据',
                trailing: _isRestoring
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _isRestoring ? null : () => _handleRestore(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.delete_forever_outlined,
                title: '清除所有数据',
                subtitle: '删除所有记录和宝宝信息',
                onTap: () => _showClearDataDialog(context),
                isDestructive: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            title: '关于',
            icon: Icons.info_outline,
            iconColor: Colors.purple,
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.child_care,
                title: '关于丫丫日记',
                subtitle: '版本 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                subtitle: '了解我们如何保护您的数据',
                onTap: () {},
              ),
              _buildSettingsItem(
                context,
                icon: Icons.description_outlined,
                title: '用户协议',
                subtitle: '使用条款和条件',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    final color = isDestructive ? Colors.red[400]! : Colors.grey[700]!;
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDestructive ? Colors.red : Colors.blue).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDestructive
                            ? Colors.red[400]
                            : const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (!isDisabled)
                Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildMinimalistDialog(context, title: '通知提醒', content: '通知功能开发中...'),
    );
  }

  void _showThemeSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildMinimalistDialog(context, title: '主题设置', content: '主题功能开发中...'),
    );
  }

  /// 处理备份操作
  Future<void> _handleBackup(BuildContext context) async {
    setState(() => _isBackingUp = true);

    try {
      final success = await _backupService.backupAndShare();

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar(context, '备份已创建并分享');
      } else {
        _showErrorSnackBar(context, '备份失败，请重试');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(context, '备份失败: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  /// 处理恢复操作
  Future<void> _handleRestore(BuildContext context) async {
    // 先显示恢复选项对话框
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRestoreOptionsSheet(context),
    );

    if (result == null || !mounted) return;

    setState(() => _isRestoring = true);

    try {
      final restoreResult = await _backupService.restoreFromFile(
        clearExisting: result == 'clear',
      );

      if (!mounted) return;

      if (restoreResult.success) {
        // 刷新数据
        await Provider.of<RecordsProvider>(context, listen: false).loadAllRecords();
        await Provider.of<BabyProvider>(context, listen: false).reloadBabies();

        _showSuccessSnackBar(context, restoreResult.message);
      } else {
        _showErrorSnackBar(context, restoreResult.message);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(context, '恢复失败: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  /// 构建恢复选项对话框
  Widget _buildRestoreOptionsSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const Text(
            '数据恢复',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请选择恢复方式',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildRestoreOption(
            context,
            icon: Icons.merge_outlined,
            title: '合并数据',
            subtitle: '保留现有数据，追加备份内容',
            onTap: () => Navigator.pop(context, 'merge'),
          ),
          const SizedBox(height: 12),
          _buildRestoreOption(
            context,
            icon: Icons.delete_sweep_outlined,
            title: '覆盖恢复',
            subtitle: '清除现有数据后导入备份',
            isDestructive: true,
            onTap: () => Navigator.pop(context, 'clear'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRestoreOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red[400]! : Colors.blue[400]!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red[50] : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red[400] : const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    // 重置确认状态
    _clearDataConfirmed = false;

    // 获取当前数据统计
    final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);

    final babiesCount = babyProvider.babies.length;
    final feedingCount = recordsProvider.feedingRecords.length;
    final sleepCount = recordsProvider.sleepRecords.length;
    final diaperCount = recordsProvider.diaperRecords.length;
    final growthCount = recordsProvider.growthRecords.length;
    final totalRecords = feedingCount + sleepCount + diaperCount + growthCount;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red[400],
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '清除所有数据',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '确定要删除所有数据吗？\n此操作不可恢复！',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                // 数据统计
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDataCountRow('宝宝档案', babiesCount, Icons.child_care),
                      const Divider(height: 12),
                      _buildDataCountRow('喂养记录', feedingCount, Icons.restaurant),
                      _buildDataCountRow('睡眠记录', sleepCount, Icons.bedtime),
                      _buildDataCountRow('尿布记录', diaperCount, Icons.baby_changing_station),
                      _buildDataCountRow('成长记录', growthCount, Icons.trending_up),
                      const Divider(height: 12),
                      _buildDataCountRow('总计', totalRecords, Icons.folder, isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 确认复选框
                GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      _clearDataConfirmed = !_clearDataConfirmed;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _clearDataConfirmed ? Colors.red[400] : Colors.transparent,
                          border: Border.all(
                            color: _clearDataConfirmed ? Colors.red[400]! : Colors.grey[400]!,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: _clearDataConfirmed
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '我已了解此操作不可恢复，确认删除',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '取消',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _clearDataConfirmed
                            ? () async {
                                Navigator.pop(dialogContext);
                                await recordsProvider.clearAllRecords();
                                await babyProvider.reloadBabies();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('所有数据已清除'),
                                      backgroundColor: Colors.green[400],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Opacity(
                          opacity: _clearDataConfirmed ? 1.0 : 0.5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '确认删除',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataCountRow(String label, int count, IconData icon, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            '$count 条',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? Colors.red[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '确定',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange[200]!, Colors.pink[200]!],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.child_care,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '丫丫日记',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '版本 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            Text(
              '丫丫日记是一款专业的婴儿生活记录应用，帮助爸爸妈妈记录宝宝的喂养、睡眠、换尿布和成长轨迹。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '© 2024 芽芽日记',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
