import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'info_card.dart';

class StorageCard extends StatefulWidget {
  const StorageCard({super.key});

  @override
  State<StorageCard> createState() => _StorageCardState();
}

class _StorageCardState extends State<StorageCard> {
  StorageState? state;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await StorageService.fetchStorageInfo();
      setState(() {
        state = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = '取得失敗';
        loading = false;
      });
    }
  }

  String _buildText() {
    if (loading) {
      return '測定中...';
    }

    if (error != null || state == null) {
      return 'タップして再測定';
    }

    return
        '総容量: ${state!.totalGB.toStringAsFixed(1)} GB\n'
        '空き容量: ${state!.freeGB.toStringAsFixed(1)} GB\n'
        '使用率: ${(state!.usedPercent * 100).toStringAsFixed(1)} %';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: load,
      child: InfoCard(
        icon: Icons.sd_storage,
        title: 'ストレージ',
        text: _buildText(),
        iconColor: Colors.teal,
      ),
    );
  }
}
