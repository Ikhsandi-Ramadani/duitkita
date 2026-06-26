import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' show basename;

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
        print('[API] ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('[API] ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('[API ERROR] ${error.response?.statusCode} ${error.requestOptions.uri}: ${error.response?.data}');
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

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'identifier': identifier, 'password': password},
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
    final res = await _dio.get('/me');
    return res.data as Map<String, dynamic>;
  }

  Future<void> setPin(String pin) async {
    await _dio.put('/me/pin', data: {'pin': pin});
  }

  Future<bool> verifyPin(String pin) async {
    final res = await _dio.post('/me/pin/verify', data: {'pin': pin});
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

  // -------------------------------------------------------------------------
  // Household member endpoints
  // -------------------------------------------------------------------------

  Future<void> removeMember(int userId) async {
    await _dio.delete('/household/members/$userId');
  }

  // -------------------------------------------------------------------------
  // Notification endpoints
  // -------------------------------------------------------------------------

  Future<void> markNotificationRead(int id) async {
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.put('/notifications/read-all');
  }

  // -------------------------------------------------------------------------
  // Transaction splits
  // -------------------------------------------------------------------------

  /// Returns the splits list for a synced transaction.
  Future<List<Map<String, dynamic>>> getTransactionSplits(int serverId) async {
    final res = await _dio.get('/transactions/$serverId');
    final splits = res.data['splits'] as List? ?? [];
    return splits.cast<Map<String, dynamic>>();
  }

  /// Replaces all splits for a synced transaction.
  Future<List<Map<String, dynamic>>> updateSplits(
      int serverId, List<Map<String, dynamic>> splits) async {
    final res = await _dio.put(
      '/transactions/$serverId/splits',
      data: {'splits': splits},
    );
    return (res.data['splits'] as List).cast<Map<String, dynamic>>();
  }

  // -------------------------------------------------------------------------
  // Receipt upload
  // -------------------------------------------------------------------------

  /// Uploads [imageFile] as the receipt for [transactionId].
  /// Returns the server-relative path, e.g. `/storage/receipts/abc.jpg`.
  Future<String> uploadReceipt(int transactionId, File imageFile) async {
    final formData = FormData.fromMap({
      'receipt': await MultipartFile.fromFile(
        imageFile.path,
        filename: basename(imageFile.path),
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final res = await _dio.post(
      '/transactions/$transactionId/receipt',
      data: formData,
    );
    return res.data['receipt_url'] as String;
  }
}
