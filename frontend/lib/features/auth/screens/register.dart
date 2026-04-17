import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/login_services.dart';
import 'package:frontend/core/models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterPage createState() => RegisterPage();
}

class RegisterPage extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final loginService = LoginServices();
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  void _register() async{
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }
    final newUser = User(
      username: username,
      email: email,
      phoneNumber: phone,
      passwordHash: password,
      defaultAddress: address,
    );
    // Thực hiện đăng ký với các thông tin đã thu thập
    final (success, response) = await loginService.register(newUser);

    if (!mounted) return;
    if (success && response != null) {
      final id = response["userId"];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thành công với id là $id')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại')),
      );  
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
                maxWidth: isDesktop ? 1040 : 560,
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
                                    Icons.person_add_alt_1,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                  SizedBox(height: 14),
                                  Text(
                                    'Tạo tài khoản mới',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tạo tài khoản để đặt món nhanh hơn và theo dõi đơn hàng.',
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
                            child: _RegisterForm(
                              usernameController: _usernameController,
                              emailController: _emailController,
                              phoneController: _phoneController,
                              addressController: _addressController,
                              passwordController: _passwordController,
                              confirmPasswordController:
                                  _confirmPasswordController,
                              showPassword: showPassword,
                              showConfirmPassword: showConfirmPassword,
                              onTogglePassword: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              onToggleConfirmPassword: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                              onRegister: _register,
                              onGoToLogin: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      )
                    : _RegisterForm(
                        usernameController: _usernameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        addressController: _addressController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        showPassword: showPassword,
                        showConfirmPassword: showConfirmPassword,
                        onTogglePassword: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        onToggleConfirmPassword: () {
                          setState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
                        onRegister: _register,
                        onGoToLogin: () => Navigator.pop(context),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool showPassword;
  final bool showConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onRegister;
  final VoidCallback onGoToLogin;

  const _RegisterForm({
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onRegister,
    required this.onGoToLogin,
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
            'Đăng ký',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Điền đầy đủ thông tin bên dưới',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _twoCol(
            context,
            left: TextField(
              controller: usernameController,
              decoration: _decoration(
                'Tên đăng nhập',
                Icons.person_outline,
              ),
            ),
            right: TextField(
              controller: emailController,
              decoration: _decoration(
                'Email',
                Icons.email_outlined,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _twoCol(
            context,
            left: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _decoration(
                'Số điện thoại',
                Icons.phone_outlined,
              ),
            ),
            right: TextField(
              controller: addressController,
              decoration: _decoration(
                'Địa chỉ',
                Icons.location_on_outlined,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _twoCol(
            context,
            left: TextField(
              controller: passwordController,
              obscureText: !showPassword,
              decoration: _decoration(
                'Mật khẩu',
                Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
            ),
            right: TextField(
              controller: confirmPasswordController,
              obscureText: !showConfirmPassword,
              decoration: _decoration(
                'Xác nhận mật khẩu',
                Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: onToggleConfirmPassword,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 247, 74, 74),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tạo tài khoản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onGoToLogin,
            child: const Text('Đã có tài khoản? Đăng nhập'),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _twoCol(
    BuildContext context, {
    required Widget left,
    required Widget right,
  }) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    if (!isWide) {
      return Column(
        children: [
          left,
          const SizedBox(height: 12),
          right,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}