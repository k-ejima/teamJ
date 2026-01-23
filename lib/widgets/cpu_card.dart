import 'package:flutter/material.dart';
import '../utils/cpu_info.dart';
import 'info_card.dart';

class CpuCard extends StatefulWidget {
  const CpuCard({super.key});

  @override
  State<CpuCard> createState() => _CpuCardState();
}

class _CpuCardState extends State<CpuCard> {
  String _cpuFreq = "取得中...";

  @override
  void initState() {
    super.initState();
    _loadCpuFrequency();
  }

  Future<void> _loadCpuFrequency() async {
    final freq = await CpuInfo.getCpuFrequency();
    setState(() {
      _cpuFreq = freq;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loadCpuFrequency, // ← タップで再取得
      child: InfoCard(
        icon: Icons.memory,
        title: "CPU周波数",
        text: _cpuFreq,
        iconColor: Colors.blueAccent,
      ),
    );
  }
}