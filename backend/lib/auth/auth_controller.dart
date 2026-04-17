import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../shared/services/user_service.dart';
import '../auth/jwt_service.dart';
import '../core/utils/response.dart';

class AuthController {
  final UserService _userService = UserService();

  Future<Response> login(Request req) async {
    final data = jsonDecode(await req.readAsString());
    final user = await _userService.checkLogin(
      data['account'],
    );

    if (user == null) {
      return ResponseUtil.success(  
        {'access_token': null, 'user': null},
        message: 'Không tìm thấy tài khoản này',
      );
    }
    
    if (user.passwordHash != data['password']) {
      return ResponseUtil.success(  
        {'access_token': null, 'user': null},
        message: 'Mật khẩu không đúng',
      );
    }

    final token = JwtService.generateToken(
      userId: user.id!,
      role: user.role,
    );

    return ResponseUtil.success(
      {'access_token': token,'user': user.toMap()},
      message: 'Đăng nhập thành công',
    );
  }
}
