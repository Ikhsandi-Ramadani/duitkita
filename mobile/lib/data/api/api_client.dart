import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api',
);
const _kTokenKey = 'auth_token';

class ApiClient {
  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _kTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  late final Dio _dio;
  final FlutterSecureStorage _storage;

  Dio get dio => _dio;

  // -------------------------------------------------------------------------
  // Token management
  // -------------------------------------------------------------------------

  Future<void> persistToken(String token) =>
      _storage.write(key: _kTokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _kTokenKey);

  Future<String?> getToken() => _storage.read(key: _kTokenKey);

  // -------------------------------------------------------------------------
  // Auth endpoints
  // -------------------------------------------------------------------------

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final res = await _dio.post('/auth/register', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> join(Map<String, dynamic> body) async {
    final res = await _dio.post('/auth/join', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    if (data['token'] != null) {
      await persistToken(data['token'] as String);
    }
    return data;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await clearToken();
    }
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  Future<void> setPin(String pin) async {
    await _dio.post('/auth/pin', data: {'pin': pin});
  }

  Future<bool> verifyPin(String pin) async {
    final res = await _dio.post('/auth/pin/verify', data: {'pin': pin});
    return (res.data as Map<String, dynamic>)['valid'] == true;
  }

  // -------------------------------------------------------------------------
  // Sync endpoints (used by SyncService)
  // -------------------------------------------------------------------------

  Future<Map<String, dynamic>> pushTransactions(
      List<Map<String, dynamic>> transactions) async {
    final res = await _dio.post(
      '/sync/transactions',
      data: {'transactions': transactions},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pullSince(int sinceTimestamp) async {
    final res = await _dio.get('/sync', queryParameters: {'since': sinceTimestamp});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> initialPull() async {
    final meData = await me();
    final syncData = await pullSince(0);
    return {'me': meData, 'sync': syncData};
  }
}
