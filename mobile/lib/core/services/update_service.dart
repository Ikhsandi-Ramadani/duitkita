import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      final currentBuild = int.tryParse(info.buildNumber) ?? 1;

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
}
