import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bluetooth",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (connectedDevices.isEmpty) const Text("接続中のデバイスはありません"),
            for (var device in connectedDevices)
              Text("・${device['name']} (${device['address']})"),
          ],
        ),
      ),
    );
  }
}
