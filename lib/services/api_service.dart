// lib/services/api_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import '../models/travel_story.dart';
import '../models/user.dart';

import 'token_storage.dart'
if (dart.library.html) 'token_storage_web.dart';

class ApiService {
  static Dio _dio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    if (!kIsWeb) {
      (dio.httpClientAdapter as dynamic).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    return dio;
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Auth ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio().post(
        '/auth/signup',
        data: {'username': username, 'email': email, 'password': password},
      );
      return {'success': true, 'message': response.data};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Signup failed'};
    }
  }

  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio().post(
        '/auth/signin',
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      final token = data['token'];
      if (token != null) await saveToken(token);
      return {'success': true, 'user': User.fromJson(data)};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Signin failed'};
    }
  }

  static Future<void> signout() async {
    final token = await getToken();
    t