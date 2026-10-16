import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class StorageException implements Exception {
  const StorageException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class StorageService {
  static const _keyUsers = 'halqat_users_v1';
  static const _keyCircles = 'halqat_circles_v1';
  static const _keyCurricula = 'halqat_curricula_v1';
  static const _keyPlans = 'halqat_plans_v1';
  static const _keyStudents = 'halqat_students_v1';
  static const _keyAttendance = 'halqat_attendance_v1';
  static const _keyGrades = 'halqat_grades_v1';
  static const _keyCurrentUserId = 'halqat_current_user_id_v1';
  static const _keyCloudSession = 'halqat_cloud_session_v1';

  static const _cloudflareApiBaseUrl = String.fromEnvironment(
    'CLOUDFLARE_API_BASE_URL',
  );

  final http.Client _httpClient = http.Client();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Map<String, int> _dataRevisions = {};
  final Map<String, Future<void>> _writeQueues = {};

  bool get isCloudEnabled => _cloudflareApiBaseUrl.trim().isNotEmpty;

  Uri _apiUri(String path) => Uri.parse(_cloudflareApiBaseUrl).resolve(path);

  Future<dynamic> _apiRequest(
    String method,
    String path, {
    Object? body,
  }) async {
    final request = http.Request(method, _apiUri(path));
    request.headers['Accept'] = 'application/json';
    if (isCloudEnabled && !kIsWeb) {
      final token = await _secureStorage.read(key: _keyCloudSession);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['X-App-Platform'] = 'native';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final response = await _httpClient.send(request);
    final responseBody = await response.stream.bytesToString();
    dynamic decoded;
    if (responseBody.isNotEmpty) {
      try {
        decoded = jsonDecode(responseBody);
      } on FormatException {
        throw StorageException(
          'استجابة الخادم غير صالحة (HTTP ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded is Map<String, dynamic> ? decoded['error']?.toString() : null;
      throw StorageException(
        message ?? 'تعذر الاتصال بالخادم (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }

  Future<List<T>?> _loadList<T>(
    String key,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    if (isCloudEnabled) {
      final decoded = await _apiRequest('GET', '/api/data/$key');
      if (decoded is! Map || decoded['data'] is! List) {
        throw const StorageException('استجابة البيانات من الخادم غير صالحة');
      }
      _dataRevisions[key] = (decoded['revision'] as num).toInt();
      return (decoded['data'] as List)
          .map((item) => fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    final List decoded = jsonDecode(jsonString);
    return decoded
        .map((item) => fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveList<T>(
    String key,
    List<T> values,
    Map<String, dynamic> Function(T) toMap,
  ) async {
    final listMap = values.map(toMap).toList();
    if (isCloudEnabled) {
      final previous = _writeQueues[key] ?? Future<void>.value();
      final current = previous
          .catchError((Object _) {})
          .then((_) => _saveCloudList(key, listMap));
      _writeQueues[key] = current;
      try {
        await current;
      } finally {
        if (identical(_writeQueues[key], current)) {
          _writeQueues.remove(key);
        }
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(listMap));
  }

  Future<void> _saveCloudList(
    String key,
    List<Map<String, dynamic>> listMap,
  ) async {
    final decoded = await _apiRequest(
      'PUT',
      '/api/data/$key',
      body: {'data': listMap, 'revision': _dataRevisions[key]},
    );
    if (decoded is! Map || decoded['revision'] is! num) {
      throw const StorageException('استجابة حفظ البيانات من الخادم غير صالحة');
    }
    _dataRevisions[key] = (decoded['revision'] as num).toInt();
  }

  Future<List<UserModel>?> loadUsers() async {
    if (isCloudEnabled) {
      final decoded = await _apiRequest('GET', '/api/users');
      if (decoded is! List) {
        throw const StorageException('استجابة المستخدمين من الخادم غير صالحة');
      }
      return decoded
          .map((item) =>
              UserModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return _loadList(_keyUsers, UserModel.fromMap);
  }

  Future<void> saveUsers(List<UserModel> users) async {
    if (isCloudEnabled) {
      await _apiRequest(
        'PUT',
        '/api/users',
        body: users.map((user) => user.toMap()).toList(),
      );
      return;
    }
    await _saveList(_keyUsers, users, (user) => user.toMap());
  }

  Future<UserModel> loginCloud(String username, String password) async {
    final decoded = await _apiRequest(
      'POST',
      '/api/auth/login',
      body: {'username': username, 'password': password},
    );
    if (decoded is! Map || decoded['user'] is! Map) {
      throw const StorageException('استجابة تسجيل الدخول من الخادم غير صالحة');
    }
    if (!kIsWeb) {
      final token = decoded['token'];
      if (token is! String || token.isEmpty) {
        throw const StorageException('لم يرسل الخادم رمز الجلسة الآمن للتطبيق');
      }
      await _secureStorage.write(key: _keyCloudSession, value: token);
    }
    return UserModel.fromMap(
      Map<String, dynamic>.from(decoded['user'] as Map),
    );
  }

  Future<UserModel?> restoreCloudSession() async {
    try {
      final decoded = await _apiRequest('GET', '/api/auth/me');
      if (decoded is! Map || decoded['user'] is! Map) {
        throw const StorageException('استجابة الجلسة من الخادم غير صالحة');
      }
      return UserModel.fromMap(
        Map<String, dynamic>.from(decoded['user'] as Map),
      );
    } on StorageException catch (error) {
      if (error.statusCode == 401) {
        if (!kIsWeb) {
          await _secureStorage.delete(key: _keyCloudSession);
        }
        return null;
      }
      rethrow;
    }
  }

  Future<void> logoutCloud() async {
    try {
      await _apiRequest('POST', '/api/auth/logout');
    } finally {
      if (!kIsWeb) {
        await _secureStorage.delete(key: _keyCloudSession);
      }
    }
  }

  Future<List<CircleModel>?> loadCircles() =>
      _loadList(_keyCircles, CircleModel.fromMap);

  Future<void> saveCircles(List<CircleModel> circles) =>
      _saveList(_keyCircles, circles, (circle) => circle.toMap());

  Future<List<CurriculumModel>?> loadCurricula() =>
      _loadList(_keyCurricula, CurriculumModel.fromMap);

  Future<void> saveCurricula(List<CurriculumModel> curricula) =>
      _saveList(_keyCurricula, curricula, (curriculum) => curriculum.toMap());

  Future<List<StudyPlanModel>?> loadStudyPlans() =>
      _loadList(_keyPlans, StudyPlanModel.fromMap);

  Future<void> saveStudyPlans(List<StudyPlanModel> plans) =>
      _saveList(_keyPlans, plans, (plan) => plan.toMap());

  Future<List<StudentModel>?> loadStudents() =>
      _loadList(_keyStudents, StudentModel.fromMap);

  Future<void> saveStudents(List<StudentModel> students) =>
      _saveList(_keyStudents, students, (student) => student.toMap());

  Future<List<AttendanceModel>?> loadAttendance() =>
      _loadList(_keyAttendance, AttendanceModel.fromMap);

  Future<void> saveAttendance(List<AttendanceModel> attendance) =>
      _saveList(_keyAttendance, attendance, (item) => item.toMap());

  Future<List<GradeModel>?> loadGrades() =>
      _loadList(_keyGrades, GradeModel.fromMap);

  Future<void> saveGrades(List<GradeModel> grades) =>
      _saveList(_keyGrades, grades, (grade) => grade.toMap());

  Future<String?> loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUserId);
  }

  Future<void> saveCurrentUserId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_keyCurrentUserId);
    } else {
      await prefs.setString(_keyCurrentUserId, id);
    }
  }
}
