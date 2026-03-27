import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/growth_record.dart';
import 'package:intl/intl.dart';
import 'record_bottom_sheet_helper.dart';
import '../widgets/empty_baby_card.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecordsProvider>(context, listen: false).loadAllRecords();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFBA68C8).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up, color: Color(0xFFBA68C8), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              '成长记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[600]),
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
              const SizedBox(height: 16),
              _buildTodayStatsCard(recordsProvider, currentBaby?.id),
              _buildQuickRecordArea(context, currentBaby?.id),
              Expanded(
                child: _buildRecordsList(growthRecords),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBA68C8), Color(0xFFCE93D8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBA68C8).withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => RecordBottomSheetHelper.showAddGrowthRecord(context),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStatsCard(RecordsProvider recordsProvider, String? babyId) {
    final growthRecords = recordsProvider.growthRecords;
    final latestRecord = growthRecords.isNotEmpty ? growthRecords.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                child: Icon(Icons.analytics_outlined, color: Colors.purple[400], size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                latestRecord != null ? '最新记录' : '今日成长记录',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (latestRecord != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (latestRecord.height != null)
                  _buildStatItem('身高', '${latestRecord.height}cm', const Color(0xFF64B5F6), Icons.straighten),
                if (latestRecord.weight != null)
                  _buildStatItem('体重', '${latestRecord.weight}kg', const Color(0xFFBA68C8), Icons.scale),
                if (latestRecord.headCircumference != null)
                  _buildStatItem('头围', '${latestRecord.headCircumference}cm', const Color(0xFFFF8A65), Icons.circle_outlined),
              ],
            )
          else
            Center(
              child: Text(
                '暂无记录',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
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
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickRecordArea(BuildContext context, String? babyId) {
    if (babyId == null) {
      return _buildNoBabyCard(context);
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt, color: Colors.deepPurple[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '快速记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton('量身高', Icons.straighten, const Color(0xFF64B5F6), () => RecordBottomSheetHelper.showQuickHeightRecord(context)),
              _buildQuickButton('称体重', Icons.scale, const Color(0xFFBA68C8), () => RecordBottomSheetHelper.showQuickWeightRecord(context)),
              _buildQuickButton('量头围', Icons.circle_outlined, const Color(0xFFFF8A65), () => RecordBottomSheetHelper.showQuickHeadCircumferenceRecord(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoBabyCard(BuildContext context) {
    return EmptyBabyCard(
      title: '还没有添加宝宝信息哦~',
      subtitle: '点击下方按钮添加宝宝档案',
      buttonText: '添加宝宝信息',
      onButtonPressed: () => Navigator.pushNamed(context, '/baby-profile'),
    );
  }

  Widget _buildQuickButton(String label, IconData icon, Color color, VoidCallback onTap) {
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
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecordsList(List<GrowthRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('暂无成长记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text('点击右下角按钮添加记录', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(GrowthRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => RecordBottomSheetHelper.showEditGrowthRecord(context, record),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBA68C8).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.child_care, color: Color(0xFFBA68C8), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy年MM月dd日').format(record.recordDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '记录时间: ${DateFormat('HH:mm').format(record.createdAt)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      onSelected: (value) {
                        if (value == 'edit') {
                          RecordBottomSheetHelper.showEditGrowthRecord(context, record);
                        } else if (value == 'delete') {
                          RecordBottomSheetHelper.showDeleteConfirm(
                            context,
                            title: '确认删除',
                            message: '确定要删除这条成长记录吗？',
                            onConfirm: () => Provider.of<RecordsProvider>(context, listen: false).deleteGrowthRecord(record.id),
                          );
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
                  ],
                ),
                if (record.height != null || record.weight != null || record.headCircumference != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (record.height != null)
                          _buildRecordStatItem('身高', '${record.height}cm', const Color(0xFF64B5F6)),
                        if (record.weight != null)
                          _buildRecordStatItem('体重', '${record.weight}kg', const Color(0xFFBA68C8)),
                        if (record.headCircumference != null)
                          _buildRecordStatItem('头围', '${record.headCircumference}cm', const Color(0xFFFF8A65)),
                      ],
                    ),
                  ),
                ],
                if (record.notes != null && record.notes!.isNotEmpty) ...[
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
                            record.notes!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[700],
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
        ),
      ),
    );
  }

  Widget _buildRecordStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
