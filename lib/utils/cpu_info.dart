import 'package:flutter/services.dart';

class CpuInfo {
  static const platform = MethodChannel('com.example.cpu/info');

  static Future<String> getCpuFrequency() async {
    try {
      final result = await platform.invokeMethod('getCpuFrequency');
      return "$result MHz";
    } catch (e) {
      return "取得失敗";
    }
  }
}
