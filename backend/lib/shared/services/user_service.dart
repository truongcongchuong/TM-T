import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import '../models/user_model.dart';

class UserService {

  Future<User?> checkLogin(String? account) async {
    try {
      final Connection conn = await DatabaseConfig.connection();

      final result = await conn.execute(
        Sql.named('''
          SELECT 
          u.id,
          u.username,
          u.email,
          u.phoneNumber,
          u.password_hash,
          r.name AS role,
          u.default_address,
          u.created_at,
          s.name AS status
          FROM users u
          INNER JOIN role r ON r.id = u.role
          INNER JOIN status s ON s.id = u.status_id
          WHERE (email = @a OR phoneNumber = @a)
        '''),
        parameters: {"a": account},
      );


      if (result.isEmpty) {
        return null;
      }
      print('User found: ${result.first.toColumnMap()}');
      return User.fromRow(result.first);
    } catch (e) {
      print('DB error in checkLogin: $e');
      rethrow; // để controller xử lý 500
    }
  }



  Future<List<User>> getAllUsers() async {
    final Connection conn = await DatabaseConfig.connection();
    final result = await conn.execute('SELECT * FROM users ORDER BY id');
    return result.map((row) => User.fromRow(row)).toList();
  }

  Future<User?> getUserById(int id) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('SELECT * FROM users WHERE id = @id'),
      parameters: {"id": id}
    );

    if (result.isEmpty) return null;

    return User.fromRow(result.first);
  }

  Future<int> createUser(User user) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
      INSERT INTO users (username, email, phoneNumber, password_hash, role, default_address)
      VALUES (@u, @e, @pn, @ph, @r, @da)
      RETURNING id;
      '''),
      parameters: {
        "u": user.username,
        "e": user.email,
        "pn": user.phoneNumber,
        "ph": user.passwordHash,
        "r": user.role,
        "da": user.defaultAddress,
      },
    );

    return result.first[0] as int;
  }


  Future<bool> deleteUser(int id) async {
    final Connection conn = await DatabaseConfig.connection();
    try {
        await conn.execute(
        Sql.named('DELETE FROM users WHERE id = @id'),
        parameters: {"id": id},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserEmail(int id, String newEmail) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      await conn.execute(
        Sql.named('UPDATE users SET email = @e WHERE id = @id'),
        parameters: {"e": newEmail, "id": id},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserPassword(int id, String newPasswordHash) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      await conn.execute(
        Sql.named('UPDATE users SET password_hash = @p WHERE id = @id'),
        parameters: {"p": newPasswordHash, "id": id},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // update profile
  Future<bool> updateUserProfile(User user) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      await conn.execute(
        Sql.named('''
          UPDATE users 
          SET username = @u,
          email = @e,
          phonenumber = @pn,
          default_address = @da 
          WHERE id = @id
        '''),
        parameters: {
          "u": user.username,
          "e": user.email,
          "pn": user.phoneNumber,
          "da": user.defaultAddress,
          "id": user.id
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
