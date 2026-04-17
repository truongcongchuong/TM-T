import 'package:shelf_router/shelf_router.dart';
import '../roles/admin/routes/admin_routes.dart';
import '../roles/user/routes/user_routers.dart';
import"../auth/router.dart";
import '../roles/restaurant/routes/restaurant_route.dart';
import 'package:backend/roles/public/routes/public_routers.dart';

Router buildRouter() {
  final router = Router();

  router.mount('/admin', adminRoutes().call);
  router.mount('/auth', authRoutes().call);
  router.mount('/user', userRoutes().call);
  router.mount('/restaurant', restaurantRoutes().call);
  router.mount('/public', publicRoutes().call);

  return router;
}
