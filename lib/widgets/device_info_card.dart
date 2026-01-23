import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../services/os_service.dart';
import 'info_card.dart';

class DeviceInfoCard extends StatefulWidget {
  const DeviceInfoCard({super.key});

  @override
  State<DeviceInfoCard> createState() => _DeviceInfoCardState();
}

class _DeviceInfoCardState extends State<DeviceInfoCard> {
  String info = "タップして取得";

  Future<void> fetch() async {
    final device = await DeviceService.getDeviceName();
    final os = await OsService.getOsInfo();
    setState(() {
      info = "$device\n$os";
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: fetch,
      child: InfoCard(
        icon: Icons.phone_android,
        title: "端末情報",
        text: info,
        iconColor: Colors.green,
      ),
    );
  }
}
