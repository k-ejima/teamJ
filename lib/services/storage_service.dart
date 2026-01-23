import 'package:flutter/services.dart';

/// ストレージ状態を表すデータクラス

class StorageState {
  final double totalGB;

  final double freeGB;

  final double usedPercent;

  StorageState({
    required this.totalGB,

    required this.freeGB,

    required this.usedPercent,
  });
}

/// ストレージ情報を取得するサービス

class StorageService {
  static const MethodChannel _channel = MethodChannel('storage/info');

  /// 内部ストレージ情報を取得

  static Future<StorageState> fetchStorageInfo() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'getStorageInfo',
    );

    if (result == null) {
      throw Exception('Storage info is null');
    }

    final total = (result['internalTotal'] as int) / (1024 * 1024 * 1024);

    final free = (result['internalFree'] as int) / (1024 * 1024 * 1024);

    final used = total - free;

    return StorageState(
      totalGB: total,

      freeGB: free,

      usedPercent: used / total,
    );
  }
}
