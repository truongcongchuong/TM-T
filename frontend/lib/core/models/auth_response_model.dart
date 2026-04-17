import 'package:frontend/core/models/user.dart';

class AuthResponse {
  final User user;
  final String accessToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      accessToken: json['access_token'],
    );
  }
}
