import 'package:flutter/material.dart';
import 'package:frontend/core/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  final _formKey = GlobalKey<FormState>();
  ///////////
    Widget _field({required double width, required Widget child}) {
    return SizedBox(width: width, child: child);
  }

  Widget _buildUsername() => TextFormField(
    controller: _usernameController,
    decoration: const InputDecoration(
      labelText: 'Tên người dùng',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.person),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng nhập tên người dùng';
      }
      if (value.length < 3) {
        return 'Tên người dùng phải có ít nhất 3 ký tự';
      }
      return null;
    },
  );

  Widget _buildEmail() => TextFormField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: const InputDecoration(
      labelText: 'Email',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.email),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng nhập email';
      }
      if (!value.contains('@')) {
        return 'Email không hợp lệ';
      }
      return null;
    },
  );

  Widget _buildPhone() => TextFormField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    decoration: const InputDecoration(
      labelText: 'Số điện thoại',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.phone),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng nhập số điện thoại';
      }
      return null;
    },
  );

  Widget _buildAddress() => TextFormField(
    controller: _addressController,
    maxLines: 3,
    decoration: const InputDecoration(
      labelText: 'Địa chỉ mặc định',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.location_on),
      alignLabelWithHint: true,
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng nhập địa chỉ';
      }
      return null;
    },
  );

  ///
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.defaultAddress);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'defaultAddress': _addressController.text.trim(),
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 900 : double.infinity,
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin cá nhân',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _field(
                                width: isDesktop
                                    ? (constraints.maxWidth - 64) / 2
                                    : double.infinity,
                                child: _buildUsername(),
                              ),
                              _field(
                                width: isDesktop
                                    ? (constraints.maxWidth - 64) / 2
                                    : double.infinity,
                                child: _buildEmail(),
                              ),
                              _field(
                                width: isDesktop
                                    ? (constraints.maxWidth - 64) / 2
                                    : double.infinity,
                                child: _buildPhone(),
                              ),
                              _field(
                                width: isDesktop
                                    ? (constraints.maxWidth - 64) / 2
                                    : double.infinity,
                                child: _buildAddress(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: isDesktop ? 200 : double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Lưu thay đổi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

