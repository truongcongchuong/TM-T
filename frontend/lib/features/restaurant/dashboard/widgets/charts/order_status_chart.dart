import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_card.dart';
import 'chart_theme.dart';
import 'package:frontend/core/models/order_status_chart_model.dart';
import 'package:frontend/core/enum/status.dart';

class OrderStatusChart extends StatelessWidget {
  final OrderStatusChartModel chartModel;

  const OrderStatusChart({super.key, required this.chartModel});

  Color getColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.completed:
        return ChartTheme.success;
      case OrderStatusEnum.pending:
        return ChartTheme.primary;
      case OrderStatusEnum.confirmed:
        return ChartTheme.warning;
      case OrderStatusEnum.delivering:
        return Colors.lime;
      case OrderStatusEnum.cancelled:
        return ChartTheme.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: chartModel.title,
      child: SizedBox(
        height: 320,
        child: Row(
          children: [
            Expanded(
              child:PieChart(
                PieChartData(
                  centerSpaceRadius: 0,
                  sectionsSpace: 4,
                  sections: chartModel.dataPoints.map((item) {
                    return PieChartSectionData(
                      value: item.percentage,
                      color: getColor(item.status),
                      radius: 120,
                      title: "",
                      badgeWidget: _buildBadge(item),
                      badgePositionPercentageOffset: 1.3,
                    );
                  }).toList(),
                ),
              )
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: chartModel.dataPoints.map((item) {
                return _Legend(
                  color: getColor(item.status),
                  text: item.status.value,
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildBadge(OrderStatusDataPoint item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${item.percentage.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 13,
              color: getColor(item.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}