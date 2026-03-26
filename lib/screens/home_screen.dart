import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../providers/records_provider.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';

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
      appBar: AppBar(
        title: const Text('丫丫日记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 快速记录功能
              _showQuickRecordDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // 婴儿档案切换
              Navigator.pushNamed(context, '/baby-profile');
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }

  void _showQuickRecordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '快速记录',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickRecordButton(
                    context,
                    icon: Icons.restaurant,
                    label: '喂养',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/feeding');
                    },
                  ),
                  _buildQuickRecordButton(
                    context,
                    icon: Icons.bedtime,
                    label: '睡眠',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/sleep');
                    },
                  ),
                  _buildQuickRecordButton(
                    context,
                    icon: Icons.baby_changing_station,
                    label: '换尿布',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/diaper');
                    },
                  ),
                  _buildQuickRecordButton(
                    context,
                    icon: Icons.trending_up,
                    label: '成长',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/growth');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickRecordButton(
    BuildContext context, {
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
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('还没有添加宝宝哦~'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/baby-profile');
                    },
                    child: const Text('添加宝宝档案'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.pink,
                  child: Text(
                    currentBaby.name[0],
                    style: const TextStyle(fontSize: 32, color: Colors.white),
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
                        ),
                      ),
                      Text(
                        '今天是你出生的第${DateTime.now().difference(currentBaby.birthDate).inDays}天',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    return Consumer<RecordsProvider>(
      builder: (context, recordsProvider, child) {
        final todayStats = recordsProvider.getTodayStats();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日统计',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('喂养', '${todayStats['feedingCount']}次', Colors.orange),
                    _buildStatItem('睡眠', '${todayStats['totalSleepDuration'].inHours}小时', Colors.blue),
                    _buildStatItem('换尿布', '${todayStats['diaperCount']}次', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildRecentRecords(BuildContext context) {
    return Consumer<RecordsProvider>(
      builder: (context, recordsProvider, child) {
        final recentRecords = recordsProvider.getRecentRecords(limit: 5);

        if (recentRecords.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最近记录',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('暂无记录，快去添加吧~'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '最近记录',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...recentRecords.map((record) {
                  IconData icon;
                  Color color;
                  String title;
                  String subtitle;
                  DateTime time;

                  if (record is FeedingRecord) {
                    icon = Icons.restaurant;
                    color = Colors.orange;
                    title = '${record.typeDisplayName}${record.amount != null ? ' ${record.amount}ml' : ''}';
                    subtitle = record.methodDisplayName;
                    time = record.feedTime;
                  } else if (record is SleepRecord) {
                    icon = Icons.bedtime;
                    color = Colors.blue;
                    title = record.type;
                    subtitle = record.durationString ?? '睡眠中';
                    time = record.startTime;
                  } else if (record is DiaperRecord) {
                    icon = Icons.baby_changing_station;
                    color = Colors.green;
                    title = '换尿布 - ${record.typeDisplayName}';
                    subtitle = record.statusDisplayName;
                    time = record.changeTime;
                  } else if (record is GrowthRecord) {
                    icon = Icons.trending_up;
                    color = Colors.purple;
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

                  return ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(title),
                    subtitle: Text(subtitle),
                    trailing: Text(
                      timeText,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
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
        _buildRecordCategoryCard(
          context,
          icon: Icons.restaurant,
          title: '喂养记录',
          subtitle: '记录喂奶时间、奶量、方式',
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, '/feeding'),
        ),
        _buildRecordCategoryCard(
          context,
          icon: Icons.bedtime,
          title: '睡眠记录',
          subtitle: '记录睡眠时间、质量',
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/sleep'),
        ),
        _buildRecordCategoryCard(
          context,
          icon: Icons.baby_changing_station,
          title: '换尿布记录',
          subtitle: '记录更换时间、状态',
          color: Colors.green,
          onTap: () => Navigator.pushNamed(context, '/diaper'),
        ),
        _buildRecordCategoryCard(
          context,
          icon: Icons.trending_up,
          title: '成长记录',
          subtitle: '记录身高、体重、头围',
          color: Colors.purple,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('统计分析页面开发中...'),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('设置页面开发中...'),
    );
  }
}