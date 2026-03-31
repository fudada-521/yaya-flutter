import 'package:flutter/material.dart';
import 'record_bottom_sheet_helper.dart';
import 'pages/dashboard_page.dart';
import 'pages/records_page.dart';
import 'pages/statistics_page.dart';
import 'pages/settings_page.dart';

/// 首页组件
///
/// 包含底部导航栏和四个页面：
/// - DashboardPage：仪表盘（欢迎卡片、今日统计、最近记录）
/// - RecordsPage：记录分类列表
/// - StatisticsPage：统计分析页面
/// - SettingsPage：设置页面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const RecordsPage(),
    const StatisticsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '芽芽日记',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          _buildMinimalistIconButton(
            icon: Icons.add_circle_outline,
            onTap: () => _showQuickRecordDialog(context),
          ),
          _buildMinimalistIconButton(
            icon: Icons.person_outline,
            onTap: () => Navigator.pushNamed(context, '/baby-profile'),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildMinimalistBottomNav(),
    );
  }

  Widget _buildMinimalistIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey[700], size: 24),
      ),
    );
  }

  Widget _buildMinimalistBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, '首页'),
              _buildNavItem(1, Icons.list_alt_outlined, Icons.list_alt, '记录'),
              _buildNavItem(2, Icons.bar_chart_outlined, Icons.bar_chart, '统计'),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings, '设置'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF8A65).withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFFFF8A65) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFFFF8A65) : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickRecordDialog(BuildContext context) {
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
              '快速记录',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickRecordItem(
                  icon: Icons.restaurant,
                  label: '喂养',
                  color: const Color(0xFFFF8A65),
                  onTap: () {
                    Navigator.pop(context);
                    RecordBottomSheetHelper.showAddFeedingRecord(context);
                  },
                ),
                _buildQuickRecordItem(
                  icon: Icons.bedtime,
                  label: '睡眠',
                  color: const Color(0xFF64B5F6),
                  onTap: () {
                    Navigator.pop(context);
                    RecordBottomSheetHelper.showAddSleepRecord(context);
                  },
                ),
                _buildQuickRecordItem(
                  icon: Icons.baby_changing_station,
                  label: '换尿布',
                  color: const Color(0xFF81C784),
                  onTap: () {
                    Navigator.pop(context);
                    RecordBottomSheetHelper.showAddDiaperRecord(context);
                  },
                ),
                _buildQuickRecordItem(
                  icon: Icons.trending_up,
                  label: '成长',
                  color: const Color(0xFFBA68C8),
                  onTap: () {
                    Navigator.pop(context);
                    RecordBottomSheetHelper.showAddGrowthRecord(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickRecordItem(
                  icon: Icons.icecream,
                  label: '辅食',
                  color: const Color(0xFFFFB74D),
                  onTap: () {
                    Navigator.pop(context);
                    RecordBottomSheetHelper.showAddSolidFoodRecord(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRecordItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
