import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/baby_provider.dart';
import 'components/components.dart';

abstract class BaseRecordSheet<T> extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Color primaryColor;
  final T? initialData;

  const BaseRecordSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.primaryColor = const Color(0xFFFF8A65),
    this.initialData,
  });

  @override
  State<BaseRecordSheet<T>> createState() => _BaseRecordSheetState<T>();

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => this,
    );
  }

  // Abstract methods that subclasses must implement
  T createInitialState();
  List<Widget> buildForm(BuildContext context, T state, StateSetter setState);
  Future<void> saveRecord(BuildContext context, T state);
}

class _BaseRecordSheetState<T> extends State<BaseRecordSheet<T>> {
  late T _state;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _state = widget.initialData ?? widget.createInitialState();
  }

  Future<void> _handleSave() async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;

    if (currentBaby == null) {
      _showNoBabyPrompt();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.saveRecord(context, _state);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNoBabyPrompt() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
              child: Icon(Icons.child_care, color: Colors.orange[400], size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              '请先添加宝宝信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
            ),
            const SizedBox(height: 8),
            Text(
              '添加宝宝信息后才能记录喂养、睡眠、尿布等数据',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SheetActionButtons(
              onCancel: () => Navigator.pop(context),
              onSave: () {
                Navigator.pop(context);
                // TODO: Navigate to add baby
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHandle(),
              const SizedBox(height: 20),
              SheetHeader(
                title: widget.title,
                subtitle: widget.subtitle,
                primaryColor: widget.primaryColor,
              ),
              const SizedBox(height: 24),
              ...widget.buildForm(context, _state, setState),
              const SizedBox(height: 24),
              SheetActionButtons(
                onCancel: () => Navigator.pop(context),
                onSave: _handleSave,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
