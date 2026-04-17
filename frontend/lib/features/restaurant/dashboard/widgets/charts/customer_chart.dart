import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_card.dart';
import 'chart_theme.dart';

class CustomerChart extends StatelessWidget {
  const CustomerChart({super.key});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: "New vs Returning Customers",
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _sections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _legend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _sections() {
    return [
      PieChartSectionData(
        value: 80,
        color: ChartTheme.primary,
        title: 'New',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: 120,
        color: ChartTheme.success,
        title: 'Returning',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(ChartTheme.primary, 'New'),
        const SizedBox(width: 16),
        _legendItem(ChartTheme.success, 'Returning'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
