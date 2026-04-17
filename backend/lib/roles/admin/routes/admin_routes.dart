import 'package:shelf_router/shelf_router.dart';
import '../controllers/admin_bill_controller.dart';
import '../controllers/admin_food_controller.dart';

Router adminRoutes() {
  final router = Router();
  final bill = AdminBillController();
  final food = AdminFoodController();

  router.get('/bills/<id>', bill.getBillById);
  router.delete('/bills/<id>', bill.deleteBill);
  router.post('/foods', food.createFood);

  return router;
}
