import 'dart:convert';
import 'package:backend/shared/models/user_model.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import '../shared/services/user_service.dart';
import '../auth/jwt_service.dart';
import '../core/utils/response.dart';
import 'package:backend/shared/models/restaurant_model.dart';
import 'package:backend/shared/services/restaurant_service.dart';

class AuthController {
  final UserService _userService = UserService();
  final RestaurantService restaurantService = RestaurantService();

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

 Future<Response> register(Request req) async {
    final data = jsonDecode(await req.readAsString());
    try {
      User newUser = User.fromMap(data);

      final id = await _userService.createUser(newUser);

      return ResponseUtil.success(
        {"id": id},
        message: 'Đăng Ký thành công',
      );
    } catch (e) {
      print(e);
      return ResponseUtil.serverError();
    }
  }

 Future<Response> registerRestaurant(Request req) async {
    final data = jsonDecode(await req.readAsString());
    try {
      RestaurantModel newRestaurant = RestaurantModel.fromMap(data);

      final result = await restaurantService.createRestaurant(newRestaurant);

      if (result == null) {
        return ResponseUtil.badRequest("tạo tài khoản thất bại");
      }
      return ResponseUtil.success(
        {"id": result},
        message: 'Đăng Ký thành công',
      );
    } catch (e) {
      print(e);
      return ResponseUtil.serverError();
    }
  }
}
