import 'package:kickpro/shared/models/user_role.dart';

class AuthResponse {
  final String token;
  final int userId;
  final String email;
  final UserRole role;

  const AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      role: UserRole.fromApi(json['role'] as String),
    );
  }
}
