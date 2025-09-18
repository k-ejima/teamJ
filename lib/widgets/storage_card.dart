import 'package:flutter/material.dart';
import 'info_card.dart';
import '../services/storage_service.dart';

class StorageCard extends StatefulWidget {
  const StorageCard({super.key});

  @override
  State<StorageCard> createState() => _StorageCardState();
}

class _StorageCardState extends State<StorageCard> {
  String info = StorageService.initialInfo;

  void _measure() async {
    setState(() => info = "測定中...");
    await Future.delayed(const Duration(seconds: 2));
    setState(() => info = StorageService.updatedInfo);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _measure,
      child: InfoCard(
        icon: Icons.sd_storage, 
        text: info,
        title: "ストレージ",
        iconColor: Colors.teal
        ),
    );
  }
}
