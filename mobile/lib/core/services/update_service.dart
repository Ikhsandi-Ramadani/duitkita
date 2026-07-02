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
      final rawBuild = int.tryParse(info.buildNumber) ?? 1;
      // `flutter build apk --split-per-abi` offsets versionCode per ABI
      // (armeabi-v7a=1000+N, arm64-v8a=2000+N, x86=3000+N, x86_64=4000+N) so
      // Play-style multi-APK installs stay ordered. Strip that offset so the
      // update check compares the actual release build number, not the
      // ABI-mangled one — otherwise arm64 installs (2000+N) would need N to
      // be entered as e.g. 2004 in the admin panel instead of just 4.
      final currentBuild = rawBuild >= 1000 ? rawBuild % 1000 : rawBuild;

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
