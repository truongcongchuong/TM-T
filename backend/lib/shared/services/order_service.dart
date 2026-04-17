import 'package:backend/shared/models/bill_model.dart';
import 'bill_service.dart';
import 'package:backend/shared/models/food_model.dart';
import 'package:backend/shared/models/notification_model.dart';
import 'package:backend/shared/services/food_service.dart';
import 'notification_service.dart';
import 'package:backend/shared/enum/notification_type_enum.dart';
import 'package:backend/shared/models/payment_model.dart';


class OrderService {

  BillService billService = BillService();
  FoodService foodService = FoodService();
  NotificationService notificationService = NotificationService();


  Future<bool> createOrder(BillModel bill, PaymentModel payment) async {

    try {
      final result = await billService.createBill(bill, payment);
      final Map<int, List<FoodModel>> groupedByRestaurant = {};

      if (result == -1) {
        print('Failed to create order');
        return false;
      }

      final List<FoodModel?> foods = await Future.wait(
        bill.items.map((items) async {
          final food = await foodService.getFoodById(items.foodId);
          return food;
        }),
      );

      for (final food in foods) {
        if (food == null) continue;

        groupedByRestaurant.putIfAbsent(
          food.restaurantId,
          () => [],
        ).add(food);
      }

      for (final entry in groupedByRestaurant.entries) {

        final restaurantId = entry.key;
        final foodsForRestaurant = entry.value;

        Map<String, dynamic> data = bill.toMap();
        data['id'] = result;
        data.remove('items');
        data['foods'] = foodsForRestaurant.map((food) => food.toMap()).toList();

        final end = notificationService.createNotification(
          NotificationModel(
            userId: restaurantId,
            type: NotificationTypeEnum.newOrder,
            title: "Đơn hàng mới",
            body: "Bạn có một đơn hàng mới cần xác nhận.",
            payload: data
          )
        );

        if (!await end) {
          print("lỗi: không gửi được thông báo đến nhà hàng có id là $restaurantId");
        }
      }

    return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }
}