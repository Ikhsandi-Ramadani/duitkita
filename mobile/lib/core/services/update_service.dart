import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/format.dart';

class UpdateInfo {
  final String version;
  final int build;
  final String url;
  final String notes;
  final bool force;

  UpdateInfo({
    required this.version,
    required this.build,
    required this.url,
    required this.notes,
    required this.force,
  });
}

class UpdateService {
  final Dio _dio;

  UpdateService(this._dio);

  Future<UpdateInfo?> checkUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentBuild = normalizedBuildNumber(info.buildNumber);

      final res = await _dio.get('/version');
      final data = res.data as Map<String, dynamic>;
      final remoteBuild = data['build'] as int? ?? 1;

      if (remoteBuild > currentBuild) {
        return UpdateInfo(
          version: data['version'] as String,
          build: remoteBuild,
          url: data['url'] as String,
          notes: data['notes'] as String? ?? '',
          force: data['force'] as bool? ?? false,
        );
      }
      return null;
    } catch (_) {
      return null; // fail silently
    }
  }

  /// Downloads the APK at [url] to a local file, reporting 0.0-1.0 progress.
  /// Returns the local file path on success.
  Future<String> downloadApk(
    String url, {
    required void Function(double progress) onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/duitkita-update.apk');

    // Fresh Dio instance — the shared one carries auth headers/interceptors
    // meant for the API host, not the (often third-party) download host.
    final downloader = Dio();
    await downloader.download(
      url,
      file.path,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
    return file.path;
  }
}
