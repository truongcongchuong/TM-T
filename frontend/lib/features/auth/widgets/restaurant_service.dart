import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/restaurant.dart';
import 'package:frontend/core/config/config.dart';
import 'package:frontend/features/user/services/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // dùng reverse geocoding

class RestaurantService {

  static Future<bool> createRestaurant({
    required int ownerId,
    required String name,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String finalAddress = address;
      double? lat = latitude;
      double? lng = longitude;

      // ===============================
      // CASE 1: KHÔNG NHẬP ĐỊA CHỈ
      // ===============================
      if (address.trim().isEmpty) {
        final position = await getCurrentLocation();

        lat = position.latitude;
        lng = position.longitude;

        // 👉 lấy địa chỉ từ lat/lng
        List<Placemark> placemarks =
            await placemarkFromCoordinates(lat, lng);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          finalAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
        }
      }

      // ===============================
      // CASE 2: CÓ ĐỊA CHỈ
      // ===============================
      else {
        final result = await getLatLngOSM(address);

        if (result == null) {
          throw Exception("Không tìm được tọa độ từ địa chỉ");
        }

        lat = result["lat"];
        lng = result["lng"];
      }

      // ===============================
      // TẠO OBJECT
      // ===============================
      final restaurant = RestaurantModel(
        id: 0,
        owner: ownerId,
        name: name,
        address: finalAddress,
        latitude: lat,
        longitude: lng,
        isOpen: true,
        ratingAvg: 0.0,
        createdAt: DateTime.now(),
      );

      // ===============================
      // CALL API
      // ===============================
      final response = await http.post(
        Uri.parse('$baseUrl/auth/restaurant'),
        headers: headers,
        body: jsonEncode(restaurant.toMap()),
      );

      return response.statusCode == 200;

    } catch (e) {
      print('Lỗi tạo nhà hàng: $e');
      return false;
    }
  }
}