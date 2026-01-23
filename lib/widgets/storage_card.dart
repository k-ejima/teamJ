import 'package:flutter/material.dart';
import 'info_card.dart';
import '../services/storage_service.dart';

class StorageCard extends StatefulWidget {
  const StorageCard({super.key});

  @override
  State<StorageCard> createState() => _StorageCardState();
}

class _StorageCardState extends State<StorageCard> {
  StorageState? storageState;
  bool isLoading = false;

  Future<void> _measure() async {
    setState(() => isLoading = true);

    try {
      final result = await StorageService.fetchStorageInfo();
      setState(() {
        storageState = result;
      });
    } catch (e) {
      setState(() {
        storageState = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _buildText() {
    if (isLoading) {
      return "測定中...";
    }

    if (storageState == null) {
      return "タップして測定";
    }

    return "合計: ${storageState!.totalGB.toStringAsFixed(1)} GB\n"
        "空き: ${storageState!.freeGB.toStringAsFixed(1)} GB\n"
        "使用率: ${(storageState!.usedPercent * 100).toStringAsFixed(0)}%";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _measure,
      child: InfoCard(
        icon: Icons.sd_storage,
        title: "ストレージ",
        text: _buildText(),
        iconColor: Colors.teal,
      ),
    );
  }
}
