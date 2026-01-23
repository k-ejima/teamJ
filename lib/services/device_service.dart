import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static Future<String> getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return "${info.manufacturer} ${info.model}";
      }

      return "非対応端末";
    } catch (e) {
      return "取得失敗";
    }
  }
}
