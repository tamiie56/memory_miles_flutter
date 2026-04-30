// lib/services/token_storage_web.dart

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

const String _tokenKey = 'auth_token';

Future<void> saveToken(String token) async {
  html.window.localStorage[_tokenKey] = token;
}

Future<String?> getToken() async {
  return html.window.localStorage[_tokenKey];
}

Future<void> clearToken() async {
  html.window.localStorage.remove(_tokenKey);
}