import 'package:intl/intl.dart';

const Map<String, String> headers =  {'Content-Type': 'application/json'};
const String pathImage = "/image_foods/";
const String host = "localhost";
const int port = 8080;
const String baseUrl = "http://$host:$port";

String formatCurrency(num amount) {
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VNĐ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}