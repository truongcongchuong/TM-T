import 'package:postgres/postgres.dart';
import 'package:backend/core/config/config.dart';

class DatabaseConfig {
  static Connection? _connection;

  static Future<Connection> init() async {
    _connection = await Connection.open(
      Endpoint(
        host: dbHost,
        port: dbPort,
        database: dbName,
        username: dbUsername,
        password: dbPassword,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );

    return _connection!;
  }

  static Future<Connection> connection() async {
    if (_connection == null || _connection!.isOpen == false) {
      _connection = await init();
    }
    return _connection!;
  }
}
