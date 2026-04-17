import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_card.dart';
import 'chart_theme.dart';

class PaymentMethodChart extends StatelessWidget {
  const PaymentMethodChart({super.key});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: "Revenue by Payment",
      child: SizedBox(
        height: 320,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 55,
            sections: [
              _section(45, ChartTheme.primary),
              _section(30, ChartTheme.success),
              _section(15, ChartTheme.purple),
              _section(10, ChartTheme.warning),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _section(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 45,
      title: "",
    );
  }
}