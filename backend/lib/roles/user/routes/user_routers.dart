import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/user_bill_controller.dart';
import '../controllers/user_cart_controller.dart';
import '../controllers/user_food_controller.dart';
import '../controllers/user_notification_controller.dart';
import '../../../core/middleware/middleware.dart';
import 'package:backend/roles/user/controllers/user_order_controller.dart';
import '../controllers/user_review_controller.dart';

Router userRoutes() {
  final router = Router();

  final bill = UserBillController();
  final cart = UserCartController();
  final food = UserFoodController();
  final order = UserOrderController();
  final notification = UserNotificationController();
  final review = UserReviewController();

  // ===== PUBLIC =====
  router.get('/foods', food.getFoods);
  router.get('/foods/categories', food.getCategorysFood);
  router.get('/foods/category/<categoryId>', food.getFoodsByCategory);
  router.get('/foods/<foodId>', food.getFoodById);


  // ===== Protected Route =====
  final protectedRoute = Router();

  // ========= routes bill ==========
  protectedRoute.get('/bills', bill.getBills);
  

  // ========= routes cart ==========
  protectedRoute.get('/carts', cart.getCart);
  protectedRoute.post('/carts', cart.addToCart);
  protectedRoute.delete('/carts/<foodId>', cart.removeItemFromCart);

  // ========= routes order ==========
  protectedRoute.post('/orders', order.order);

  
  // ============ routers notification =========================

  protectedRoute.get('/notification', notification.loadNotification);

  // ============ routers review =========================
  protectedRoute.post('/reviews', review.createReview);

  router.mount(
    '/',
    Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(protectedRoute.call),
  );

  return router;
}
