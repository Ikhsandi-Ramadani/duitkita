import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<String?> unavailableReason() async {
    if (!await _localAuth.isDeviceSupported()) {
      return 'HP ini tidak mendukung biometrik';
    }
    if (!await _localAuth.canCheckBiometrics) {
      return 'Biometrik belum diaktifkan di pengaturan HP';
    }
    if ((await _localAuth.getAvailableBiometrics()).isEmpty) {
      return 'Belum ada sidik jari atau wajah yang terdaftar di HP';
    }
    return null;
  }

  Future<bool> authenticate({required String reason}) {
    return _localAuth.authenticate(
      localizedReason: reason,
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
  }

  bool isCancellation(LocalAuthException exception) {
    return exception.code == LocalAuthExceptionCode.userCanceled ||
        exception.code == LocalAuthExceptionCode.systemCanceled;
  }

  String userMessage(LocalAuthException exception) {
    return switch (exception.code) {
      LocalAuthExceptionCode.noBiometricHardware =>
        'HP ini tidak mendukung biometrik',
      LocalAuthExceptionCode.noBiometricsEnrolled =>
        'Daftarkan sidik jari atau wajah terlebih dahulu di pengaturan HP',
      LocalAuthExceptionCode.noCredentialsSet =>
        'Aktifkan kunci layar dan biometrik di pengaturan HP',
      LocalAuthExceptionCode.temporaryLockout =>
        'Biometrik terkunci sementara. Coba beberapa saat lagi',
      LocalAuthExceptionCode.biometricLockout =>
        'Biometrik terkunci. Buka kunci HP dengan PIN lalu coba lagi',
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
        'Sensor biometrik sedang tidak tersedia',
      LocalAuthExceptionCode.authInProgress =>
        'Verifikasi biometrik sedang berlangsung',
      LocalAuthExceptionCode.uiUnavailable =>
        'Dialog biometrik tidak dapat dibuka',
      _ => 'Gagal memverifikasi biometrik. Coba lagi',
    };
  }
}
