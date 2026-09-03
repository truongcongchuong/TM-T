// lib/features/order_management/pages/order_management_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/enum/status.dart';
import 'package:frontend/core/models/bill_manager_model.dart';
import '../services/manager_bill_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'widgets/bill_detail_dialog.dart';
import 'widgets/bill_edit_dialog.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final ManagerBillsServices _billService = ManagerBillsServices();

  late Future<List<BillManagerModel>> _billsFuture;
  List<BillManagerModel> _allBills = [];
  List<BillManagerModel> _displayBills = [];

  late String token;
  String selectedStatus = 'Tất cả';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    token = auth.token!;
    _loadBills();
  }

  // ================= LOAD DATA =================
  void _loadBills() {
    setState(() {
      _billsFuture = _billService.getBills(token);
    });
  }

  // ================= FILTER =================
  void _applyFilterWithoutSetState() {
    _displayBills = _allBills.where((bill) {
      final matchesStatus = selectedStatus == 'Tất cả' ||
          bill.statusBill.value == selectedStatus;

      final matchesSearch = searchQuery.isEmpty ||
          bill.id.toString().contains(searchQuery) ||
          bill.customer.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();
  }

  void _applyFilter() {
    setState(() {
      _applyFilterWithoutSetState();
    });
  }

  // ================= FORMAT DATE =================
  String formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  // ================= DIALOG =================
  void _showDetailDialog(BillManagerModel bill) {
    showDialog(
      context: context,
      builder: (_) => BillDetailDialog(
        bill: bill,
        formatDate: formatDate,
        token: token,
      ),
    );
  }

  void _showEditDialog(BillManagerModel bill) {
    showDialog(
      context: context,
      builder: (_) => BillEditDialog(
        bill: bill,
        token: token,
        onRefresh: () {
          _loadBills(); // reload API
        },
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchAndFilter(),
            const SizedBox(height: 24),
            _buildTableSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quản lý đơn hàng',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: _loadBills,
          icon: const Icon(Icons.refresh, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            searchQuery = value.trim();
            _applyFilter();
          },
          decoration: InputDecoration(
            hintText: 'Tìm theo mã đơn hoặc khách hàng...',
            prefixIcon: const Icon(Icons.search),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatusChip('Tất cả'),
              const SizedBox(width: 8),
              _buildStatusChip(OrderStatusEnum.pending.value),
              const SizedBox(width: 8),
              _buildStatusChip(OrderStatusEnum.confirmed.value),
              const SizedBox(width: 8),
              _buildStatusChip(OrderStatusEnum.delivering.value),
              const SizedBox(width: 8),
              _buildStatusChip(OrderStatusEnum.completed.value),
              const SizedBox(width: 8),
              _buildStatusChip(OrderStatusEnum.cancelled.value),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label) {
    final isSelected = selectedStatus == label;
    return GestureDetector(
      onTap: () {
        setState(() => selectedStatus = label);
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected
                  ? Colors.red
                  : Colors.red.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.red.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder<List<BillManagerModel>>(
      future: _billsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        // ===== FIX QUAN TRỌNG =====
        _allBills = snapshot.data ?? [];
        _applyFilterWithoutSetState(); // luôn sync data

        if (_displayBills.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('Không tìm thấy đơn hàng',
                  style: TextStyle(fontSize: 18)),
            ),
          );
        }

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 280,
                child: PaginatedDataTable(
                  rowsPerPage: 10,
                  columnSpacing: 32,
                  horizontalMargin: 24,
                  showCheckboxColumn: false,
                  headingRowColor:
                      WidgetStateProperty.all(Colors.grey.shade50),
                  columns: const [
                    DataColumn(label: Text('Mã đơn')),
                    DataColumn(label: Text('Khách hàng')),
                    DataColumn(label: Text('Trạng thái')),
                    DataColumn(label: Text('Địa chỉ')),
                    DataColumn(label: Text('Thanh toán')),
                    DataColumn(label: Text('TT thanh toán')),
                    DataColumn(label: Text('Ngày tạo')),
                    DataColumn(label: Text('Hành động')),
                  ],
                  source: BillDataSource(
                    _displayBills,
                    formatDate,
                    onView: _showDetailDialog,
                    onEdit: _showEditDialog,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================= DATA SOURCE =================
class BillDataSource extends DataTableSource {
  final List<BillManagerModel> bills;
  final String Function(DateTime) formatDate;
  final void Function(BillManagerModel) onView;
  final void Function(BillManagerModel) onEdit;

  BillDataSource(this.bills, this.formatDate,
      {required this.onView, required this.onEdit});

  @override
  DataRow getRow(int index) {
    final bill = bills[index];

    return DataRow(cells: [
      DataCell(Text('#${bill.id}')),
      DataCell(Text(bill.customer)),
      DataCell(_buildStatusBadge(bill.statusBill)),
      DataCell(Text(bill.address,
          maxLines: 2, overflow: TextOverflow.ellipsis)),
      DataCell(Text(bill.paymentMethod)),
      DataCell(_buildStatusBadge(bill.statusPayment, isPayment: true)),
      DataCell(Text(formatDate(bill.orderTime))),
      DataCell(Row(
        children: [
          IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => onView(bill)),
          IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => onEdit(bill)),
        ],
      )),
    ]);
  }

  Widget _buildStatusBadge(dynamic status, {bool isPayment = false}) {
    final (String text, Color color) = isPayment
        ? (status.value,
            status == PaymentStatusEnum.paid ? Colors.green : Colors.red)
        : (status.value, _getStatusColor(status as OrderStatusEnum));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.completed:
        return Colors.green;
      case OrderStatusEnum.pending:
        return Colors.orange;
      case OrderStatusEnum.delivering:
        return Colors.blue;
      case OrderStatusEnum.cancelled:
        return Colors.red;
      case OrderStatusEnum.confirmed:
        return Colors.purple;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => bills.length;

  @override
  int get selectedRowCount => 0;
}