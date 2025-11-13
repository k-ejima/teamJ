import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'info_card.dart';

class BluetoothCard extends StatefulWidget {
  const BluetoothCard({super.key});

  @override
  State<BluetoothCard> createState() => _BluetoothCardState();
}

class _BluetoothCardState extends State<BluetoothCard> {
  static const platform = MethodChannel('samples.flutter.dev/bluetooth');
  List<Map<String, String>> connectedDevices = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDevices();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _updateDevices(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateDevices() async {
    try {
      final List<dynamic> devices = await platform.invokeMethod(
        'getPairedDevices',
      );
      setState(() {
        connectedDevices = devices
            .map((e) => Map<String, String>.from(e))
            .toList();
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to get devices: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 接続デバイス一覧をテキスト化
    String deviceText = connectedDevices.isEmpty
        ? "接続中のデバイスはありません"
        : connectedDevices
              .map((device) => "・${device['name']} (${device['address']})")
              .join("\n");

    return InfoCard(
      icon: Icons.bluetooth,
      title: "Bluetooth",
      text: deviceText,
      iconColor: Colors.blueAccent,
    );
  }
}
