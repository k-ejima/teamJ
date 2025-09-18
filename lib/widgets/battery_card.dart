import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'info_card.dart';

class BatteryCard extends StatefulWidget {
  const BatteryCard({super.key});

  @override
  State<BatteryCard> createState() => _BatteryCardState();
}

class _BatteryCardState extends State<BatteryCard> {
  final Battery _battery = Battery();
  BatteryState? _batteryState;
  Timer? _timer;

  String batteryInfo = "取得中...";
  String _chargingSpeed = "未計測";
  String _voltage = "未取得";
  String _temperature = "未取得";

  static const platform = MethodChannel('com.example.battery/info');

  @override
  void initState() {
    super.initState();

    _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryState = state;
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateBattery());
  }

  Future<void> _updateBattery() async {
    try {
      final level = await _battery.batteryLevel;
      setState(() {
        batteryInfo = "$level%";
      });
    } catch (e) {
      setState(() {
        batteryInfo = "取得失敗";
      });
    }
  }

  Future<void> _getChargingSpeed() async {
    try {
      final result = await platform.invokeMethod('getChargingSpeed');
      final mA = (result as int) ~/ 1000; // µA → mA
      setState(() {
        _chargingSpeed = "充電速度: +$mA mA";
      });
    } catch (e) {
      setState(() {
        _chargingSpeed = "取得失敗";
      });
    }
  }

  Future<void> _getBatteryDetails() async {
    try {
      final result = await platform.invokeMethod('getBatteryDetails');
      final voltageMv = result['voltage'] as int;
      final tempDeci = result['temperature'] as int;

      setState(() {
        _voltage = "${(voltageMv / 1000.0).toStringAsFixed(2)} V";
        _temperature = "${(tempDeci / 10.0).toStringAsFixed(1)} ℃";
      });
    } catch (e) {
      setState(() {
        _voltage = "取得失敗";
        _temperature = "取得失敗";
      });
    }
  }

  Future<void> _onTapBatteryCard() async {
    await _getChargingSpeed();
    await _getBatteryDetails();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  IconData _getBatteryIcon(int level) {
    if (_batteryState == BatteryState.charging) return Icons.battery_charging_full;
    if (level >= 75) return Icons.battery_full;
    if (level >= 50) return Icons.battery_6_bar;
    if (level >= 25) return Icons.battery_4_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(int level) {
    if (_batteryState == BatteryState.charging) return Colors.green;
    if (level >= 75) return Colors.green;
    if (level >= 50) return Colors.lightGreen;
    if (level >= 25) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    int batteryLevel = 0;
    try {
      batteryLevel = int.parse(batteryInfo.replaceAll('%', ''));
    } catch (_) {}

    return GestureDetector(
      onTap: _onTapBatteryCard,
      child: InfoCard(
        icon: _getBatteryIcon(batteryLevel),
        text: "$batteryInfo\n$_chargingSpeed\n電圧: $_voltage\n温度: $_temperature",
        title: "バッテリー",
        iconColor: _getBatteryColor(batteryLevel),
      ),
    );
  }
}
