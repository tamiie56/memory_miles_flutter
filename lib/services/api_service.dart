// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/travel_story.dart';
import '../models/user.dart';

import 'token_storage.dart'
if (dart.library.html) 'token_storage_web.dart';

class ApiService {
  // Dio instance with IPv4 forced
  static Dio _dio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
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
    try {
      await _dio().post(
        '/user/signout',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
    } catch (_) {}
    await clearToken();
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio().post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Something went wrong'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio().post(
        '/auth/reset-password',
        data: {'email': email, 'token': token, 'newPassword': newPassword},
      );
      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Something went wrong'};
    }
  }

  // ─── User ────────────────────────────────────────────────────────

  static Future<User?> getUser() async {
    final token = await getToken();
    try {
      final response = await _dio().get(
        '/user/getusers',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return User.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  // ─── Travel Stories ──────────────────────────────────────────────

  static Future<List<TravelStory>> getAllStories() async {
    final token = await getToken();
    try {
      final response = await _dio().get(
        '/travelStory/get-all',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      final List stories = response.data['stories'];
      return stories.map((s) => TravelStory.fromJson(s)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addStory({
    required String title,
    required String story,
    required List<String> mediaUrls,
    required List<String> visitedLocation,
    required DateTime visitedDate,
  }) async {
    final token = await getToken();
    try {
      final response = await _dio().post(
        '/travelStory/add',
        data: {
          'title': title,
          'story': story,
          'mediaUrls': mediaUrls,
          'visitedLocation': visitedLocation,
          'visitedDate': visitedDate.millisecondsSinceEpoch.toString(),
        },
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return {'success': true, 'story': TravelStory.fromJson(response.data['story'])};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Failed to add story'};
    }
  }

  static Future<Map<String, dynamic>> editStory({
    required String id,
    required String title,
    required String story,
    required List<String> mediaUrls,
    required List<String> visitedLocation,
    required DateTime visitedDate,
  }) async {
    final token = await getToken();
    try {
      final response = await _dio().post(
        '/travelStory/edit-story/$id',
        data: {
          'title': title,
          'story': story,
          'mediaUrls': mediaUrls,
          'visitedLocation': visitedLocation,
          'visitedDate': visitedDate.millisecondsSinceEpoch.toString(),
        },
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return {'success': true, 'story': TravelStory.fromJson(response.data['story'])};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Failed to update story'};
    }
  }

  static Future<bool> deleteStory(String id) async {
    final token = await getToken();
    try {
      await _dio().delete(
        '/travelStory/delete-story/$id',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateFavorite(String id, bool isFavorite) async {
    final token = await getToken();
    try {
      await _dio().put(
        '/travelStory/update-is-favorite/$id',
        data: {'isFavorite': isFavorite},
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<TravelStory>> searchStories(String query) async {
    final token = await getToken();
    try {
      final response = await _dio().get(
        '/travelStory/search',
        queryParameters: {'query': query},
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      final List stories = response.data['stories'];
      return stories.map((s) => TravelStory.fromJson(s)).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Media Upload ─────────────────────────────────────────────────

  static Future<List<String>> uploadMediaFiles(List<File> files) async {
    final token = await getToken();
    final formData = FormData();
    for (final file in files) {
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(file.path),
      ));
    }
    try {
      final response = await _dio().post(
        '/travelStory/image-upload',
        data: formData,
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return List<String>.from(response.data['mediaUrls']);
    } catch (_) {
      return [];
    }
  }

  static Future<List<String>> uploadMediaBytesList(
      List<Uint8List> bytesList, List<String> filenames) async {
    final token = await getToken();
    final formData = FormData();
    for (int i = 0; i < bytesList.length; i++) {
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(bytesList[i], filename: filenames[i]),
      ));
    }
    try {
      final response = await _dio().post(
        '/travelStory/image-upload',
        data: formData,
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return List<String>.from(response.data['mediaUrls']);
    } catch (_) {
      return [];
    }
  }
}