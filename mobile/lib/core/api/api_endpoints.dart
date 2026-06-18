import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static const register = '/api/v1/auth/register';
  static const login = '/api/v1/auth/login';
  static const playerProfile = '/api/v1/players/profile';
  static const playerProfileMe = '/api/v1/players/profile/me';
  static const playerProfilePhoto = '/api/v1/players/profile/photo';
  static const playerSkills = '/api/v1/players/skills';
  static const playerSkillsMe = '/api/v1/players/skills/me';
}
