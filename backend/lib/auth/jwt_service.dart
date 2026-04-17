import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:backend/core/config/config.dart';

class JwtService {
  static const _secretKey = secretKey;

  static String generateToken({
    required int userId,
    required String role,
  }) {
    final jwt = JWT(
      {
        'userId': userId,
        'role': role,
      },
      issuer: 'your-backend',
    );

    return jwt.sign(
      SecretKey(_secretKey),
      expiresIn: const Duration(hours: 1),
    );
  }

  static JWT verifyToken(String token) {
    return JWT.verify(token, SecretKey(_secretKey));
  }
}
