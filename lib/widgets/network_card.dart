// widgets/network_card.dart
import 'package:flutter/material.dart';
import 'info_card.dart';
import '../services/network_service.dart';

class NetworkCard extends StatefulWidget {
  const NetworkCard({super.key});

  @override
  State<NetworkCard> createState() => _NetworkCardState();
}

class _NetworkCardState extends State<NetworkCard> {
  String info = NetworkService.initialInfo;

  @override
  void initState() {
    super.initState();
    _measure(); // ← アプリ起動時に自動測定
  }


  void _measure() async {
    setState(() => info = "測定中...");
    final result = await NetworkService.measureSpeed();
    setState(() => info = result);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _measure,
      child: InfoCard(
        icon: Icons.wifi,
        text: info,
        title: "通信速度",
        iconColor: Colors.blue,
      ),
    );
  }
}