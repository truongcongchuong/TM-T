import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_card.dart';
import 'package:frontend/core/models/top_selling_chart_model.dart';

class TopSellingChart extends StatelessWidget {
  final TopSellingChartModel chartModel;

  const TopSellingChart({super.key, required this.chartModel});

  String _formatMoney(double value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(0)}K";
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final items = chartModel.dataPoints;
    if (items.isEmpty) {
      return ChartCard(
        title: chartModel.title,
        child: const SizedBox(height: 300, child: Center(child: Text("Chưa có dữ liệu"))),
      );
    }

    final maxY = items.map((e) => e.revenue).reduce((a, b) => a > b ? a : b) * 1.15;

    return ChartCard(
      title: chartModel.title,
      child: SizedBox(
        height: 420,           // Chiều cao cố định hợp lý
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = items[group.x.toInt()];
                    return BarTooltipItem(
                      "${item.name}\n",
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: _formatMoney(rod.toY),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 70,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index < 0 || index >= items.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            items[index].name,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) => Text(
                      _formatMoney(value),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(items.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: items[index].revenue,
                      width: 28,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}