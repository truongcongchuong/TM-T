import 'package:shelf_router/shelf_router.dart';
import 'auth_controller.dart';

Router authRoutes() {
  final router = Router();
  final auth = AuthController();

  router.post('/login', auth.login);

  return router;
}
