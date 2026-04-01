import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/baby_provider.dart';
import '../../providers/records_provider.dart';
import '../../services/backup_service.dart';
import '../../services/notification_service.dart';
import '../../services/theme_service.dart';

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
  final NotificationService _notificationService = NotificationService();
  final ThemeService _themeService = ThemeService();

  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _clearDataConfirmed = false; // 清除数据确认状态

  // 通知设置状态
  bool _feedingReminderEnabled = false;
  int _feedingInterval = 3;
  bool _sleepReminderEnabled = false;
  int _sleepInterval = 4;
  bool _diaperReminderEnabled = false;
  int _diaperInterval = 2;

  // 主题设置状态
  AppThemeMode _themeMode = AppThemeMode.system;
  Color _themeColor = ThemeService.defaultPrimaryColor;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // 加载通知设置
    final notificationStatus = await _notificationService.getReminderStatus();
    final prefs = await SharedPreferences.getInstance();

    // 加载主题设置
    final themeMode = await _themeService.getThemeMode();
    final themeColor = await _themeService.getThemeColor();

    if (mounted) {
      setState(() {
        _feedingReminderEnabled = notificationStatus['feeding'] ?? false;
        _feedingInterval = prefs.getInt('feeding_reminder_interval') ?? 3;
        _sleepReminderEnabled = notificationStatus['sleep'] ?? false;
        _sleepInterval = prefs.getInt('sleep_reminder_interval') ?? 4;
        _diaperReminderEnabled = notificationStatus['diaper'] ?? false;
        _diaperInterval = prefs.getInt('diaper_reminder_interval') ?? 2;
        _themeMode = themeMode;
        _themeColor = themeColor;
      });
    }
  }

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
                onTap: () => _showLanguageSettings(context),
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
                onTap: () => _showPrivacyPolicy(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.description_outlined,
                title: '用户协议',
                subtitle: '使用条款和条件',
                onTap: () => _showUserAgreement(context),
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
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
                '通知提醒',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 24),

              // 喂养提醒
              _buildReminderItem(
                icon: Icons.restaurant,
                title: '喂养提醒',
                color: const Color(0xFFFF8A65),
                enabled: _feedingReminderEnabled,
                interval: _feedingInterval,
                onChanged: (enabled, interval) {
                  setSheetState(() {
                    _feedingReminderEnabled = enabled;
                    _feedingInterval = interval;
                  });
                  setState(() {});
                  _updateFeedingReminder(enabled, interval);
                },
              ),
              const Divider(height: 24),

              // 睡眠提醒
              _buildReminderItem(
                icon: Icons.bedtime,
                title: '睡眠提醒',
                color: const Color(0xFF64B5F6),
                enabled: _sleepReminderEnabled,
                interval: _sleepInterval,
                onChanged: (enabled, interval) {
                  setSheetState(() {
                    _sleepReminderEnabled = enabled;
                    _sleepInterval = interval;
                  });
                  setState(() {});
                  _updateSleepReminder(enabled, interval);
                },
              ),
              const Divider(height: 24),

              // 尿布提醒
              _buildReminderItem(
                icon: Icons.baby_changing_station,
                title: '尿布提醒',
                color: const Color(0xFF81C784),
                enabled: _diaperReminderEnabled,
                interval: _diaperInterval,
                onChanged: (enabled, interval) {
                  setSheetState(() {
                    _diaperReminderEnabled = enabled;
                    _diaperInterval = interval;
                  });
                  setState(() {});
                  _updateDiaperReminder(enabled, interval);
                },
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
      ),
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String title,
    required Color color,
    required bool enabled,
    required int interval,
    required Function(bool enabled, int interval) onChanged,
  }) {
    return Row(
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              Text(
                '每 $interval 小时提醒',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled,
          onChanged: (value) => onChanged(value, interval),
          activeTrackColor: color,
        ),
      ],
    );
  }

  Future<void> _updateFeedingReminder(bool enabled, int interval) async {
    if (enabled) {
      await _notificationService.scheduleFeedingReminder(
        babyId: 'default',
        hoursInterval: interval,
      );
    } else {
      await _notificationService.cancelFeedingReminder('default');
    }
  }

  Future<void> _updateSleepReminder(bool enabled, int interval) async {
    if (enabled) {
      await _notificationService.scheduleSleepReminder(
        babyId: 'default',
        hoursAfterWake: interval,
      );
    } else {
      await _notificationService.cancelSleepReminder('default');
    }
  }

  Future<void> _updateDiaperReminder(bool enabled, int interval) async {
    if (enabled) {
      await _notificationService.scheduleDiaperReminder(
        babyId: 'default',
        hoursInterval: interval,
      );
    } else {
      await _notificationService.cancelDiaperReminder('default');
    }
  }

  void _showThemeSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
                '主题设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 24),

              // 主题模式
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '外观模式',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildThemeModeButton(
                    icon: Icons.brightness_auto,
                    label: '跟随系统',
                    isSelected: _themeMode == AppThemeMode.system,
                    onTap: () {
                      setSheetState(() => _themeMode = AppThemeMode.system);
                      setState(() {});
                      _themeService.setThemeMode(AppThemeMode.system);
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildThemeModeButton(
                    icon: Icons.light_mode,
                    label: '浅色',
                    isSelected: _themeMode == AppThemeMode.light,
                    onTap: () {
                      setSheetState(() => _themeMode = AppThemeMode.light);
                      setState(() {});
                      _themeService.setThemeMode(AppThemeMode.light);
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildThemeModeButton(
                    icon: Icons.dark_mode,
                    label: '深色',
                    isSelected: _themeMode == AppThemeMode.dark,
                    onTap: () {
                      setSheetState(() => _themeMode = AppThemeMode.dark);
                      setState(() {});
                      _themeService.setThemeMode(AppThemeMode.dark);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 主题色
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '主题色',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ThemeService.themeColors.map((color) {
                  final isSelected = _themeColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() => _themeColor = color);
                      setState(() {});
                      _themeService.setThemeColor(color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withAlpha(128), blurRadius: 8, spreadRadius: 2)]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
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
      ),
    );
  }

  Widget _buildThemeModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF8A65).withAlpha(25) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: const Color(0xFFFF8A65), width: 1.5)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFFF8A65) : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFFFF8A65) : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
            const SizedBox(height: 20),
            const Text(
              '语言设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageItem(
              language: '简体中文',
              isSelected: true,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            _buildLanguageItem(
              language: 'English',
              isSelected: false,
              onTap: () {
                _showComingSoonSnackBar(context);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildLanguageItem(
              language: '繁體中文',
              isSelected: false,
              onTap: () {
                _showComingSoonSnackBar(context);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '关闭',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
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

  Widget _buildLanguageItem({
    required String language,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8A65).withAlpha(25) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFFFF8A65), width: 1.5)
              : Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Text(
              language,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? const Color(0xFFFF8A65) : const Color(0xFF2D2D2D),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFFFF8A65), size: 20),
          ],
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('更多语言支持敬请期待'),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// 处理备份操作
  Future<void> _handleBackup(BuildContext context) async {
    setState(() => _isBackingUp = true);

    try {
      final success = await _backupService.backupAndShare();

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar('备份已创建并分享');
      } else {
        _showErrorSnackBar('备份失败，请重试');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('备份失败: ${e.toString()}');
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

    // 在 await 之前获取 Provider 引用
    // ignore: use_build_context_synchronously
    final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);

    RestoreResult restoreResult;
    try {
      restoreResult = await _backupService.restoreFromFile(
        clearExisting: result == 'clear',
      );
    } catch (e) {
      _showErrorSnackBar('恢复失败: ${e.toString()}');
      setState(() => _isRestoring = false);
      return;
    }

    if (restoreResult.success) {
      await recordsProvider.loadAllRecords();
      await babyProvider.reloadBabies();
      _showSuccessSnackBar(restoreResult.message);
    } else {
      _showErrorSnackBar(restoreResult.message);
    }

    setState(() => _isRestoring = false);
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

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
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

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '隐私政策',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    '''**隐私政策**

**更新日期：2024年1月1日**

**概述**
芽芽日记高度重视您的隐私安全。本应用承诺保护用户的个人信息和宝宝数据安全。

**数据收集**
- 我们仅收集应用运行所必需的数据
- 宝宝档案信息（姓名、出生日期等）
- 喂养、睡眠、尿布、成长记录
- 应用使用统计（匿名）

**数据存储**
- 所有数据存储在您的本地设备上
- 我们不会将您的数据上传至任何服务器
- 数据备份文件的保管由您自行负责

**数据共享**
- 本应用不会与任何第三方共享您的数据
- 不包含任何广告追踪或分析功能

**权限使用**
- 通知权限：用于喂养、睡眠等提醒
- 存储权限：用于备份数据的导出和导入

**联系我们**
如有任何隐私相关问题，请通过应用内反馈功能联系我们。

**政策更新**
我们会定期更新此隐私政策，更新时会在应用内公告。''',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D2D2D),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserAgreement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '用户协议',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    '''**用户协议**

**更新日期：2024年1月1日**

**使用条款**
欢迎使用芽芽日记。在使用本应用之前，请仔细阅读以下条款。

**服务说明**
芽芽日记是一款婴儿生活记录应用，旨在帮助父母记录和追踪宝宝的日常活动。

**使用规则**
1. 您必须年满18周岁方可使用本应用
2. 您需对您添加的宝宝信息真实性负责
3. 请勿使用本应用进行任何违法活动
4. 请妥善保管您的设备及备份文件

**数据责任**
- 您对存储在本应用中的所有数据负责
- 我们建议您定期备份重要数据
- 因设备丢失或损坏导致的数据丢失，我们不承担责任

**知识产权**
- 芽芽日记及其内容的知识产权归我们所有
- 未经授权，不得对本应用进行反编译或修改

**免责声明**
- 本应用按"现状"提供服务，不提供任何明示或暗示保证
- 对于因使用本应用造成的任何直接或间接损失，我们不承担责任

**服务变更**
我们保留随时修改或终止服务的权利，修改时会在应用内公告。

**联系我们**
如有任何问题，请通过应用内反馈功能联系我们。

**管辖法律**
本协议受中华人民共和国法律管辖。''',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D2D2D),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
