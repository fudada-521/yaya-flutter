import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../providers/records_provider.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';
import 'record_bottom_sheet_helper.dart';

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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 20),
          _buildTodaySummary(context),
          const SizedBox(height: 20),
          _buildRecentRecords(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, babyProvider, child) {
        final currentBaby = babyProvider.currentBaby;
        if (currentBaby == null) {
          return _buildEmptyBabyCard(context);
        }

        final babyColor = currentBaby.gender == 'male'
            ? const Color(0xFF64B5F6)
            : const Color(0xFFF48FB1);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [babyColor.withAlpha(200), babyColor.withAlpha(150)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(100),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withAlpha(50),
                  child: Text(
                    currentBaby.name[0],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      '你好，${currentBaby.name}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '第${currentBaby.ageInDays}天',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.waving_hand,
                color: Colors.white.withAlpha(200),
                size: 32,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyBabyCard(BuildContext context) {
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.child_care, size: 48, color: Colors.orange[300]),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '还没有添加宝宝哦~',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '点击下方按钮添加宝宝档案',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/baby-profile'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '添加宝宝',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    return Consumer<RecordsProvider>(
      builder: (context, recordsProvider, child) {
        final todayStats = recordsProvider.getTodayStats();
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
                      Icons.today,
                      color: Colors.orange[400],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '今日统计',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '喂养',
                    '${todayStats['feedingCount']}次',
                    const Color(0xFFFF8A65),
                    Icons.restaurant,
                  ),
                  _buildStatItem(
                    '睡眠',
                    '${todayStats['totalSleepDuration'].inHours}小时',
                    const Color(0xFF64B5F6),
                    Icons.bedtime,
                  ),
                  _buildStatItem(
                    '换尿布',
                    '${todayStats['diaperCount']}次',
                    const Color(0xFF81C784),
                    Icons.baby_changing_station,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildRecentRecords(BuildContext context) {
    return Consumer<RecordsProvider>(
      builder: (context, recordsProvider, child) {
        final recentRecords = recordsProvider.getRecentRecords(limit: 5);

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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.history,
                      color: Colors.purple[400],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '最近记录',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recentRecords.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '暂无记录，快去添加吧~',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentRecords.map((record) => _buildRecordItem(record)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordItem(dynamic record) {
    IconData icon;
    Color color;
    String title;
    String subtitle;
    DateTime time;

    if (record is FeedingRecord) {
      icon = Icons.restaurant;
      color = const Color(0xFFFF8A65);
      title =
          '${record.typeDisplayName}${record.amount != null ? ' ${record.amount}ml' : ''}';
      subtitle = record.methodDisplayName;
      time = record.feedTime;
    } else if (record is SleepRecord) {
      icon = Icons.bedtime;
      color = const Color(0xFF64B5F6);
      title = record.type;
      subtitle = record.durationString ?? '睡眠中';
      time = record.startTime;
    } else if (record is DiaperRecord) {
      icon = Icons.baby_changing_station;
      color = const Color(0xFF81C784);
      title = '换尿布 - ${record.typeDisplayName}';
      subtitle = record.statusDisplayName;
      time = record.changeTime;
    } else if (record is GrowthRecord) {
      icon = Icons.trending_up;
      color = const Color(0xFFBA68C8);
      title = '成长记录';
      subtitle = '${record.weight}kg, ${record.height}cm';
      time = record.recordDate;
    } else {
      return const SizedBox.shrink();
    }

    final timeDiff = DateTime.now().difference(time);
    String timeText;
    if (timeDiff.inDays > 0) {
      timeText = '${timeDiff.inDays}天前';
    } else if (timeDiff.inHours > 0) {
      timeText = '${timeDiff.inHours}小时前';
    } else if (timeDiff.inMinutes > 0) {
      timeText = '${timeDiff.inMinutes}分钟前';
    } else {
      timeText = '刚刚';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeText,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        _buildRecordCategoryCard(
          context,
          icon: Icons.restaurant,
          title: '喂养记录',
          subtitle: '记录喂奶时间、奶量、方式',
          color: const Color(0xFFFF8A65),
          onTap: () => Navigator.pushNamed(context, '/feeding'),
        ),
        const SizedBox(height: 12),
        _buildRecordCategoryCard(
          context,
          icon: Icons.bedtime,
          title: '睡眠记录',
          subtitle: '记录睡眠时间、质量',
          color: const Color(0xFF64B5F6),
          onTap: () => Navigator.pushNamed(context, '/sleep'),
        ),
        const SizedBox(height: 12),
        _buildRecordCategoryCard(
          context,
          icon: Icons.baby_changing_station,
          title: '换尿布记录',
          subtitle: '记录更换时间、状态',
          color: const Color(0xFF81C784),
          onTap: () => Navigator.pushNamed(context, '/diaper'),
        ),
        const SizedBox(height: 12),
        _buildRecordCategoryCard(
          context,
          icon: Icons.trending_up,
          title: '成长记录',
          subtitle: '记录身高、体重、头围',
          color: const Color(0xFFBA68C8),
          onTap: () => Navigator.pushNamed(context, '/growth'),
        ),
      ],
    );
  }

  Widget _buildRecordCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatisticsCard(context),
          const SizedBox(height: 16),
          _buildTrendOverview(context),
          const SizedBox(height: 16),
          _buildDetailedStats(context),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
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
                  Icons.analytics_outlined,
                  color: Colors.orange[400],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '今日统计',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<RecordsProvider>(
            builder: (context, recordsProvider, child) {
              final todayStats = recordsProvider.getTodayStats();
              return Column(
                children: [
                  _buildStatRow(
                    '今日喂养',
                    '${todayStats['feedingCount']}次',
                    const Color(0xFFFF8A65),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    '今日睡眠',
                    '${todayStats['totalSleepDuration'].inHours}小时',
                    const Color(0xFF64B5F6),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    '今日换尿布',
                    '${todayStats['diaperCount']}次',
                    const Color(0xFF81C784),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendOverview(BuildContext context) {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.timeline, color: Colors.blue[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '趋势概览',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrendItem(
                context,
                '喂养',
                Icons.restaurant,
                const Color(0xFFFF8A65),
                () {
                  Navigator.pushNamed(context, '/feeding');
                },
              ),
              _buildTrendItem(
                context,
                '睡眠',
                Icons.bedtime,
                const Color(0xFF64B5F6),
                () {
                  Navigator.pushNamed(context, '/sleep');
                },
              ),
              _buildTrendItem(
                context,
                '尿布',
                Icons.baby_changing_station,
                const Color(0xFF81C784),
                () {
                  Navigator.pushNamed(context, '/diaper');
                },
              ),
              _buildTrendItem(
                context,
                '成长',
                Icons.trending_up,
                const Color(0xFFBA68C8),
                () {
                  Navigator.pushNamed(context, '/growth');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
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

  Widget _buildDetailedStats(BuildContext context) {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.storage, color: Colors.green[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '详细统计',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<RecordsProvider>(
            builder: (context, recordsProvider, child) {
              final allRecords = recordsProvider.getRecentRecords(limit: 50);
              final feedingRecords = recordsProvider.feedingRecords;
              final totalFeeding = feedingRecords.length;
              final totalFeedingAmount = feedingRecords.fold<double>(
                0,
                (sum, r) => sum + (r.amount ?? 0),
              );
              final sleepRecords = recordsProvider.sleepRecords;
              final totalSleepDuration = sleepRecords.fold<Duration>(
                Duration.zero,
                (sum, r) => sum + (r.duration ?? Duration.zero),
              );
              final diaperRecords = recordsProvider.diaperRecords;
              final totalDiaper = diaperRecords.length;

              return Column(
                children: [
                  _buildDetailStat(
                    '累计喂养次数',
                    '$totalFeeding次',
                    const Color(0xFFFF8A65),
                  ),
                  if (totalFeedingAmount > 0) ...[
                    const SizedBox(height: 10),
                    _buildDetailStat(
                      '累计奶量',
                      '${totalFeedingAmount.toStringAsFixed(0)}ml',
                      const Color(0xFFFF8A65),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _buildDetailStat(
                    '累计睡眠次数',
                    '${sleepRecords.length}次',
                    const Color(0xFF64B5F6),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailStat(
                    '累计睡眠时长',
                    '${totalSleepDuration.inHours}小时',
                    const Color(0xFF64B5F6),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailStat(
                    '累计换尿布次数',
                    '$totalDiaper次',
                    const Color(0xFF81C784),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '数据基于最近${allRecords.length}条记录',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                onTap: () => _showBackupSettings(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.restore_outlined,
                title: '数据恢复',
                subtitle: '从备份文件恢复数据',
                onTap: () => _showRestoreSettings(context),
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
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red[400]! : Colors.grey[700]!;
    return GestureDetector(
      onTap: onTap,
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
            Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
          ],
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

  void _showBackupSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildMinimalistDialog(context, title: '数据备份', content: '备份功能开发中...'),
    );
  }

  void _showRestoreSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildMinimalistDialog(context, title: '数据恢复', content: '恢复功能开发中...'),
    );
  }

  void _showClearDataDialog(BuildContext context) {
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                    onTap: () async {
                      Navigator.pop(context);
                      await Provider.of<RecordsProvider>(context, listen: false).clearAllRecords();
                      await Provider.of<BabyProvider>(context, listen: false).reloadBabies();
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
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '删除',
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
            const SizedBox(height: 16),
          ],
        ),
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
