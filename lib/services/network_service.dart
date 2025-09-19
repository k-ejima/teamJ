// services/network_service.dart
import 'package:http/http.dart' as http;
import 'dart:math';

class NetworkService {
  static const initialInfo = "Wi-Fi: 測定待ち...";

  /// 下り速度（ダウンロード）
  static Future<String> measureDownloadSpeed() async {
    final url = Uri.parse("https://speed.cloudflare.com/__down?bytes=10000000");
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes.length;
        final seconds = stopwatch.elapsedMilliseconds / 1000;
        final speedMbps = (bytes * 8) / (seconds * 1000000);
        return "下り ${speedMbps.toStringAsFixed(2)} Mbps";
      } else {
        return "下り測定失敗（${response.statusCode}）";
      }
    } catch (e) {
      return "下り測定失敗（$e）";
    }
  }

  /// 上り速度（アップロード）
  static Future<String> measureUploadSpeed() async {
    final url = Uri.parse("https://speed.cloudflare.com/__up");
    final data = List<int>.generate(5 * 1024 * 1024, (i) => Random().nextInt(256)); // 5MBのランダムデータ
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.post(url, body: data).timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final bytes = data.length;
        final seconds = stopwatch.elapsedMilliseconds / 1000;
        final speedMbps = (bytes * 8) / (seconds * 1000000);
        return "上り ${speedMbps.toStringAsFixed(2)} Mbps";
      } else {
        return "上り測定失敗（${response.statusCode}）";
      }
    } catch (e) {
      return "上り測定失敗（$e）";
    }
  }

  /// まとめて測定（Pingは除外）
  static Future<String> measureAll() async {
    final dl = await measureDownloadSpeed();
    final ul = await measureUploadSpeed();
    return "$dl\n$ul";
  }
}