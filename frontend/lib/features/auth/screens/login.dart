import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/login_services.dart';
import 'register.dart';
import 'package:frontend/features/user/home/home.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/user/providers/cart_provider.dart';
import 'package:frontend/features/restaurant/dashboard/restaurant_dashboard.dart';
import 'package:frontend/websocket/socket.dart';
import 'package:frontend/features/user/nontification/widgets/global_notification_listener.dart';
import 'package:frontend/core/enum/user_role.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginPage createState() => LoginPage();
}

class LoginPage extends State<LoginScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final loginService = LoginServices();
  bool showPassword = false;
  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  void _login() async {
    final account = _accountController.text.trim();
    final password = _passwordController.text;

    final response = await loginService.login(account, password);

    if (!mounted) return;

    if (!response.success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );
    
    if (response.success && response.data != null) {
      final token = response.data!.accessToken;
      final user = response.data!.user;

      context.read<AuthProvider>().saveSession(user, token);
      await context.read<SocketManager>().connectSocket(user.id!);

      final auth = context.read<AuthProvider>();
      context.read<CartProvider>().initCart(token);
      GlobalNotificationListener.init(user.id!);

      switch (auth.user!.role) {
        case UserRole.restaurantOwner:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RestaurantDashboardScreen()),
          );
          break;

        case UserRole.user:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => UserHomeScreen()),
          );
          break;

        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role không hợp lệ')),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 980 : 520,
              ),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color.fromARGB(255, 247, 74, 74),
                                    const Color.fromARGB(255, 246, 68, 91)
                                        .withOpacity(0.92),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(
                                    Icons.fastfood,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                  SizedBox(height: 14),
                                  Text(
                                    'Chào mừng bạn trở lại',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Đăng nhập để tiếp tục đặt món và quản lý đơn hàng.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: _LoginForm(
                              accountController: _accountController,
                              passwordController: _passwordController,
                              showPassword: showPassword,
                              onTogglePassword: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              onLogin: _login,
                            ),
                          ),
                        ],
                      )
                    : _LoginForm(
                        accountController: _accountController,
                        passwordController: _passwordController,
                        showPassword: showPassword,
                        onTogglePassword: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        onLogin: _login,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController accountController;
  final TextEditingController passwordController;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const _LoginForm({
    required this.accountController,
    required this.passwordController,
    required this.showPassword,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Đăng nhập',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhập thông tin để tiếp tục',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: accountController,
            decoration: InputDecoration(
              labelText: 'Số điện thoại hoặc email',
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: !showPassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: onTogglePassword,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // TODO: forgot password
                },
                child: const Text('Quên mật khẩu?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Tạo tài khoản'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 247, 74, 74),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}