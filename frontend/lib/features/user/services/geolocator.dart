import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    throw Exception('Location permissions are denied.');
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

Future<Map<String, double>?> getLatLngOSM(String address) async {
  try {

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?q=${Uri.encodeComponent(address)}"
      "&format=json&limit=1",
    );

    final res = await http.get(url, headers: {
      "User-Agent": "food-app",
      "Accept": "application/json"
    });

    print("OSM URL: $url");
    print("OSM RESPONSE: ${res.body}");

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    if (data.isEmpty) return null;

    return {
      "lat": double.parse(data[0]["lat"]),
      "lng": double.parse(data[0]["lon"]),
    };
  } catch (e) {
    print("Geocoding error: $e");
    return null;
  }
}