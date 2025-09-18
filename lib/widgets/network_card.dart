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

  void _measure() async {
    setState(() => info = "測定中...");
    await Future.delayed(const Duration(seconds: 2));
    setState(() => info = NetworkService.updatedInfo);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _measure,
      child: InfoCard(
        icon: Icons.wifi,
        text: info,
        title: "通信速度",
        iconColor: Colors.blue
        ),
    );
  }
}
