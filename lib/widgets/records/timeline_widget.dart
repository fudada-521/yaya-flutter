import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feeding_record.dart';
import '../../models/sleep_record.dart';
import '../../models/diaper_record.dart';
import '../../models/growth_record.dart';

class TimelineWidget extends StatelessWidget {
  final List<dynamic> records;
  final Function(dynamic record) onRecordTap;

  const TimelineWidget({
    super.key,
    required this.records,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              '暂无记录，快去添加吧~',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Group records by date
    final groupedRecords = _groupRecordsByDate(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedRecords.entries.map((entry) {
        return _buildDateSection(context, entry.key, entry.value);
      }).toList(),
    );
  }

  Map<String, List<dynamic>> _groupRecordsByDate(List<dynamic> records) {
    final Map<String, List<dynamic>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final record in records) {
      final recordDate = _getRecordDate(record);
      final recordDay = DateTime(recordDate.year, recordDate.month, recordDate.day);

      String dateKey;
      if (recordDay == today) {
        dateKey = '今天';
      } else if (recordDay == yesterday) {
        dateKey = '昨天';
      } else if (recordDay.isAfter(today.subtract(const Duration(days: 7)))) {
        dateKey = DateFormat('EEEE').format(recordDate); // Weekday name
      } else {
        dateKey = DateFormat('M月d日').format(recordDate);
      }

      grouped.putIfAbsent(dateKey, () => []).add(record);
    }

    return grouped;
  }

  Widget _buildDateSection(BuildContext context, String dateLabel, List<dynamic> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline items
        ...records.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          final isLast = index == records.length - 1;
          return _buildTimelineItem(context, record, isLast);
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, dynamic record, bool isLast) {
    final iconData = _getIcon(record);
    final color = _getColor(record);
    final title = _getTitle(record);
    final subtitle = _getSubtitle(record);
    final recordDate = _getRecordDate(record);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot and line (left side)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(77),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),
          // Date/time and record card (right side)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time (aligned with dot center)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${_formatDate(recordDate)} ${_formatTime(recordDate)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Record card
                  GestureDetector(
                    onTap: () => onRecordTap(record),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(iconData, color: color, size: 18),
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
                                if (subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getRecordDate(dynamic record) {
    if (record is FeedingRecord) return record.feedTime;
    if (record is SleepRecord) return record.startTime;
    if (record is DiaperRecord) return record.changeTime;
    if (record is GrowthRecord) return record.recordDate;
    return DateTime.now();
  }

  IconData _getIcon(dynamic record) {
    if (record is FeedingRecord) return Icons.restaurant;
    if (record is SleepRecord) return Icons.bedtime;
    if (record is DiaperRecord) return Icons.baby_changing_station;
    if (record is GrowthRecord) return Icons.trending_up;
    return Icons.circle;
  }

  Color _getColor(dynamic record) {
    if (record is FeedingRecord) return const Color(0xFFFF8A65);
    if (record is SleepRecord) return const Color(0xFF64B5F6);
    if (record is DiaperRecord) return const Color(0xFF81C784);
    if (record is GrowthRecord) return const Color(0xFFBA68C8);
    return Colors.grey;
  }

  String _getTitle(dynamic record) {
    if (record is FeedingRecord) {
      return record.typeDisplayName;
    }
    if (record is SleepRecord) {
      return record.type;
    }
    if (record is DiaperRecord) {
      return '换尿布 - ${record.typeDisplayName}';
    }
    if (record is GrowthRecord) {
      return '成长记录';
    }
    return '';
  }

  String _getSubtitle(dynamic record) {
    if (record is FeedingRecord) {
      final parts = <String>[];
      if (record.amount != null) parts.add('${record.amount}ml');
      if (record.methodDisplayName.isNotEmpty) parts.add(record.methodDisplayName);
      if (record.durationDisplayName.isNotEmpty) parts.add(record.durationDisplayName);
      return parts.join(' | ');
    }
    if (record is SleepRecord) {
      return record.durationString ?? '睡眠中';
    }
    if (record is DiaperRecord) {
      return record.statusDisplayName;
    }
    if (record is GrowthRecord) {
      final parts = <String>[];
      if (record.weight != null) parts.add('${record.weight}kg');
      if (record.height != null) parts.add('${record.height}cm');
      if (record.headCircumference != null) parts.add('头围${record.headCircumference}cm');
      return parts.isEmpty ? '' : parts.join(' | ');
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
