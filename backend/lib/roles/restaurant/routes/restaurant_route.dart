import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/middleware/middleware.dart';
import '../controllers/manager_food_controller.dart';
import '../controllers/upload_file_controller.dart';
import '../controllers/manager_bill_controller.dart';
import '../controllers/manager_info_restaurant_controller.dart';

Router restaurantRoutes() {


  final router = Router();

  final DashboardController dashboardController = DashboardController();
  final ManagerFoodController managerFoodController = ManagerFoodController();
  final UploadFileController uploadFileController = UploadFileController();
  final ManagerBillController managerBillController = ManagerBillController();
  final ManagerInfoRestaurantController managerInfoRestaurantController = ManagerInfoRestaurantController();

  // ===== PUBLIC =====
  
  // ===== Protected Route =====
  final protectedRoute = Router();

  // Dashboard
protectedRoute.get('/dashboard/overview', dashboardController.getoverView);
protectedRoute.get('/dashboard/chartRevenueOverTime', dashboardController.getDataRevenueOverTimeChart);
protectedRoute.get('/dashboard/chartOrderOverTime', dashboardController.getDataOrderOverTimeChart);
protectedRoute.get('/dashboard/chartOrderStatus', dashboardController.getDataOrderStatusChart);
protectedRoute.get('/dashboard/chartTopSelling', dashboardController.getDataTopSellingChart);

  // Manager Foods
  protectedRoute.get('/manager/foods', managerFoodController.getFoodsForManager);
  protectedRoute.put('/manager/foods', managerFoodController.editFood);
  protectedRoute.delete('/manager/foods/<idFood>', managerFoodController.deleteFood);
  protectedRoute.post('/manager/foods', managerFoodController.addFood);
  protectedRoute.get('/manager/foods/search',managerFoodController.searchFood);

  // Upload file
  protectedRoute.post('/upload/imageFood', uploadFileController.uploadFileImageFood);

  // manager bill
  protectedRoute.get('/manager/bills', managerBillController.getBill);
  protectedRoute.get('/manager/bills/<billId>/items',managerBillController.getFoodItems);
  protectedRoute.put('/manager/bills/<billId>',managerBillController.updateBill);

  // manager infomation restaurant
  protectedRoute.get('/manager/info', managerInfoRestaurantController.getInfoRestaurant);
  protectedRoute.put('/manager/info', managerInfoRestaurantController.updateInfoRestaurant);

  router.mount(
    '/',
    Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(protectedRoute.call),
  );

  return router;
}
