import 'package:flutter/material.dart';

/// 底部表单把手组件
///
/// 显示在底部弹窗顶部的灰色拖动条，
/// 提示用户可以拖动该区域来操作底部弹窗。
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
