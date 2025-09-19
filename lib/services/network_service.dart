// services/network_service.dart
import 'package:http/http.dart' as http;

class NetworkService {
  static const initialInfo = "Wi-Fi: 測定待ち...";
  static const updatedInfo = "Wi-Fi: 測定完了";

  /// 通信速度を測定して結果を返す（文字列形式）
  static Future<String> measureSpeed() async {
    final url = Uri.parse("https://speed.cloudflare.com/__down?bytes=10000000"); // 10MB
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes.length;
        final seconds = stopwatch.elapsedMilliseconds / 1000;
        final speedMbps = (bytes * 8) / (seconds * 1000000);
        return "Wi-Fi速度:\n下り ${speedMbps.toStringAsFixed(2)} Mbps";
      } else {
        return "Wi-Fi速度: 測定失敗（${response.statusCode}）";
      }
    } catch (e) {
      return "Wi-Fi速度: 測定失敗（$e）";
    }
  }
}