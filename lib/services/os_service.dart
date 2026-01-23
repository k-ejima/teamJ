import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class OsService {
  static Future<String> getOsInfo() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      return "Android ${info.version.release}";
    }
    return "非対応OS";
  }
}
