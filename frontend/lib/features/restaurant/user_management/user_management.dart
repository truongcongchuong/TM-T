import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildToolbar(),
            const SizedBox(height: 16),
            Expanded(child: _buildUserTable()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return const Text(
      'Quản lý người dùng',
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }

  // ================= TOOLBAR =================
  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Search
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo tên / email',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Add user
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add),
          label: const Text('Thêm người dùng'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // ================= TABLE =================
  Widget _buildUserTable() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56,
          dataRowHeight: 60,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Tên')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Vai trò')),
            DataColumn(label: Text('Trạng thái')),
            DataColumn(label: Text('Hành động')),
          ],
          rows: [
            _buildUserRow(
              id: '1',
              name: 'Nguyễn Văn A',
              email: 'a@gmail.com',
              role: 'User',
              status: 'Hoạt động',
            ),
            _buildUserRow(
              id: '2',
              name: 'Trần Thị B',
              email: 'b@gmail.com',
              role: 'Admin',
              status: 'Hoạt động',
            ),
            _buildUserRow(
              id: '3',
              name: 'Lê Văn C',
              email: 'c@gmail.com',
              role: 'User',
              status: 'Bị khóa',
            ),
          ],
        ),
      ),
    );
  }

  // ================= ROW =================
  DataRow _buildUserRow({
    required String id,
    required String name,
    required String email,
    required String role,
    required String status,
  }) {
    final bool isActive = status == 'Hoạt động';

    return DataRow(cells: [
      DataCell(Text(id)),
      DataCell(
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.red.withOpacity(0.1),
              child: Text(
                name[0],
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(width: 8),
            Text(name),
          ],
        ),
      ),
      DataCell(Text(email)),
      DataCell(_buildRoleBadge(role)),
      DataCell(_buildStatusBadge(isActive)),
      DataCell(
        Row(
          children: [
            IconButton(
              tooltip: 'Xem chi tiết',
              icon: const Icon(Icons.visibility),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Chỉnh sửa',
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
            IconButton(
              tooltip: isActive ? 'Khóa' : 'Mở khóa',
              icon: Icon(
                isActive ? Icons.lock : Icons.lock_open,
                color: isActive ? Colors.red : Colors.green,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ]);
  }

  // ================= BADGES =================
  Widget _buildRoleBadge(String role) {
    final Color color = role == 'Admin' ? Colors.purple : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        active ? 'Hoạt động' : 'Bị khóa',
        style: TextStyle(
          color: active ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
