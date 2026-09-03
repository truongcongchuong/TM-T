import 'package:flutter/material.dart';
import 'charts/revenue_chart.dart';
import 'charts/order_heatmap_chart.dart';
import 'charts/order_status_chart.dart';
import 'charts/top_selling_chart.dart';
import 'stat_card.dart';
import 'package:frontend/core/models/dashboard_overview_model.dart';
import 'package:frontend/features/restaurant/services/dashboard_overview_services.dart';
import 'package:frontend/features/restaurant/services/dashboard_chart_services.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/models/chart_model.dart';
import 'package:frontend/core/models/order_over_time_chart_model.dart';
import 'package:frontend/core/models/order_status_chart_model.dart';
import 'package:frontend/core/models/top_selling_chart_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardOverviewModel? overview;

  bool isLoading = true;
  String? errorMessage;

  bool isRevenueChartLoading = true;
  bool isOrderOverTimeChartLoading = true;
  bool isOrderStatusChartLoading = true;
  bool isTopSellingChartLoading = true;

  RevenueOverTimeChart? revenueChartData;
  OrderOverTimeChart? orderOverTimeChartData;
  OrderStatusChartModel? orderStatusChartData;
  TopSellingChartModel? topSellingChartData;

  final dashboardOverviewService = DashboardOverviewServices();
  final dashboardChartServices = DashboardChartServices();

  String selectedFilter = "month";

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().token!;
    _reloadAll(token, period: "month");
  }

  // ================= LOAD ALL =================
  Future<void> _reloadAll(
    String token, {
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    setState(() {
      isLoading = true;
      isRevenueChartLoading = true;
      isOrderOverTimeChartLoading = true;
      isOrderStatusChartLoading = true;
      isTopSellingChartLoading = true;
    });

    try {
      final results = await Future.wait([
        dashboardOverviewService.getOverview(
          token,
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        dashboardChartServices.getRevenueOverTime(
          token,
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        dashboardChartServices.getOrderOverTime(
          token,
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        dashboardChartServices.getOrderStatus(
          token,
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        dashboardChartServices.getTopSelling(
          token,
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      setState(() {
        overview = results[0] as DashboardOverviewModel;
        revenueChartData = results[1] as RevenueOverTimeChart;
        orderOverTimeChartData = results[2] as OrderOverTimeChart;
        orderStatusChartData = results[3] as OrderStatusChartModel;
        topSellingChartData = results[4] as TopSellingChartModel;

        isLoading = false;
        isRevenueChartLoading = false;
        isOrderOverTimeChartLoading = false;
        isOrderStatusChartLoading = false;
        isTopSellingChartLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Lỗi load dữ liệu";
      });
    }
  }

  // ================= CUSTOM DATE =================
  Future<void> _pickDateRange(String token) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (range == null) return;

    final start = range.start;
    final end = range.end.add(const Duration(days: 1)); // FIX BUG ngày cuối

    await _reloadAll(
      token,
      period: "custom",
      startDate: start.toIso8601String(),
      endDate: end.toIso8601String(),
    );
  }

  // ================= APPLY FILTER =================
  void _applyFilter(String filter) {
    final token = context.read<AuthProvider>().token!;

    setState(() {
      selectedFilter = filter;
    });

    if (filter == "custom") {
      _pickDateRange(token);
      return;
    }

    _reloadAll(token, period: filter);
  }

  String formatCurrency(num amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ListView(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStatCards(overview!),
              const SizedBox(height: 32),

              isRevenueChartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RevenueChart(
                      fullWidth: true,
                      chartModel: revenueChartData!,
                    ),

              const SizedBox(height: 24),

              _responsiveRow(
                isOrderOverTimeChartLoading
                    ? const Center(child: CircularProgressIndicator())
                    : OrdersHeatmapChart(
                        dataOrderOverTime: orderOverTimeChartData!,
                      ),
                isOrderStatusChartLoading
                    ? const Center(child: CircularProgressIndicator())
                    : OrderStatusChart(
                        chartModel: orderStatusChartData!,
                      ),
              ),

              const SizedBox(height: 24),

              isTopSellingChartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TopSellingChart(
                      chartModel: topSellingChartData!,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dashboard Overview",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            _dateFilter(),
            const SizedBox(width: 16),
            const CircleAvatar(radius: 20),
          ],
        )
      ],
    );
  }

  Widget _dateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: selectedFilter,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: "week", child: Text("Tuần này")),
          DropdownMenuItem(value: "month", child: Text("Tháng này")),
          DropdownMenuItem(value: "year", child: Text("Năm nay")),
          DropdownMenuItem(value: "custom", child: Text("Tùy chọn")),
        ],
        onChanged: (value) {
          if (value != null) {
            _applyFilter(value);
          }
        },
      ),
    );
  }

  Widget _buildStatCards(DashboardOverviewModel overview) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        StatCardModern(
          title: "Tổng số lượng bán ra",
          value: overview.totalSold.toString(),
          icon: Icons.receipt_long,
          color: const Color(0xFF2563EB),
        ),
        StatCardModern(
          title: "Doanh thu",
          value: formatCurrency(overview.totalRevenue),
          icon: Icons.attach_money,
          color: const Color(0xFF16A34A),
        ),
        StatCardModern(
          title: "Đơn đã hoàn thành",
          value: overview.completedOrders.toString(),
          icon: Icons.check_circle,
          color: const Color(0xFF10B981),
        ),
        StatCardModern(
          title: "Khách hàng",
          value: overview.customers.toString(),
          icon: Icons.people,
          color: const Color(0xFF7C3AED),
        ),
        StatCardModern(
          title: "Số món ăn",
          value: overview.totalFood.toString(),
          icon: Icons.fastfood,
          color: const Color(0xFFDB2777),
        ),
        StatCardModern(
          title: "Đơn đang xử lý",
          value: overview.pendingOrders.toString(),
          icon: Icons.hourglass_bottom,
          color: const Color(0xFFF59E0B),
        ),
        StatCardModern(
          title: "Đơn đã hủy",
          value: overview.cancelledOrders.toString(),
          icon: Icons.cancel,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }

  Widget _responsiveRow(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;

        return isWide
            ? Row(
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 24),
                  Expanded(child: right),
                ],
              )
            : Column(
                children: [
                  left,
                  const SizedBox(height: 24),
                  right,
                ],
              );
      },
    );
  }
}    