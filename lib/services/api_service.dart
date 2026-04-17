// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/travel_story.dart';
import '../models/user.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';

  // ─── Token helpers ───────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
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
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'message': data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Signup failed'};
    }
  }

  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // token response body থেকে নাও (Flutter Web এর জন্য)
      final token = data['token'];
      if (token != null) {
        await saveToken(token);
      }
      return {'success': true, 'user': User.fromJson(data)};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Signin failed'};
    }
  }

  static Future<void> signout() async {
    final headers = await _headers();
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/user/signout'),
      headers: headers,
    );
    await clearToken();
  }

  // ─── User ────────────────────────────────────────────────────────

  static Future<User?> getUser() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/user/getusers'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // ─── Travel Stories ──────────────────────────────────────────────

  static Future<List<TravelStory>> getAllStories() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/travelStory/get-all'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List stories = data['stories'];
      return stories.map((s) => TravelStory.fromJson(s)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> addStory({
    required String title,
    required String story,
    required String imageUrl,
    required List<String> visitedLocation,
    required DateTime visitedDate,
  }) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/travelStory/add'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'story': story,
        'imageUrl': imageUrl,
        'visitedLocation': visitedLocation,
        'visitedDate': visitedDate.millisecondsSinceEpoch.toString(),
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true, 'story': TravelStory.fromJson(data['story'])};
    }
    return {'success': false, 'message': data['message'] ?? 'Failed to add story'};
  }

  static Future<Map<String, dynamic>> editStory({
    required String id,
    required String title,
    required String story,
    required String imageUrl,
    required List<String> visitedLocation,
    required DateTime visitedDate,
  }) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/travelStory/edit-story/$id'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'story': story,
        'imageUrl': imageUrl,
        'visitedLocation': visitedLocation,
        'visitedDate': visitedDate.millisecondsSinceEpoch.toString(),
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'story': TravelStory.fromJson(data['story'])};
    }
    return {'success': false, 'message': data['message'] ?? 'Failed to update story'};
  }

  static Future<bool> deleteStory(String id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/travelStory/delete-story/$id'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateFavorite(String id, bool isFavorite) async {
    final headers = await _headers();
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/travelStory/update-is-favorite/$id'),
      headers: headers,
      body: jsonEncode({'isFavorite': isFavorite}),
    );
    return response.statusCode == 200;
  }

  static Future<List<TravelStory>> searchStories(String query) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/travelStory/search?query=${Uri.encodeComponent(query)}'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List stories = data['stories'];
      return stories.map((s) => TravelStory.fromJson(s)).toList();
    }
    return [];
  }

  // ─── Image Upload ─────────────────────────────────────────────────

  static Future<String?> uploadImage(File imageFile) async {
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/travelStory/image-upload'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      final data = jsonDecode(respStr);
      return data['imageUrl'];
    }
    return null;
  }

  static Future<String?> uploadImageBytes(Uint8List bytes, String filename) async {
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/travelStory/image-upload'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      final data = jsonDecode(respStr);
      return data['imageUrl'];
    }
    return null;
  }
}