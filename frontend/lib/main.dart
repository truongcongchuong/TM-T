import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/login.dart';
import 'package:frontend/features/user/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/user/home/home.dart';
import 'package:frontend/features/restaurant/dashboard/restaurant_dashboard.dart';
import 'package:frontend/websocket/socket.dart';
import 'package:frontend/core/enum/user_role.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.loadSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        Provider(create: (_) => SocketManager()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return MaterialApp(
      title: 'Ứng dụng đặt đồ ăn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      navigatorKey: navigatorKey,
      home: auth.isLoggedIn
        ?  _buildHomeByRole(auth.user!.role)
        : const LoginScreen(),
    );
  }
}

Widget _buildHomeByRole(UserRole? role) {
  switch (role) {
    case UserRole.restaurantOwner:
      return const RestaurantDashboardScreen();

    case UserRole.user:
      return const UserHomeScreen();

    default:
      return const Scaffold(
        body: Center(
          child: Text("Role không hợp lệ"),
        ),
      );
  }
}