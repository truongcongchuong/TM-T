  import 'package:flutter/material.dart';
  import 'package:fl_chart/fl_chart.dart';
  import 'chart_card.dart';
  import 'package:frontend/core/models/chart_model.dart';

  class RevenueChart extends StatelessWidget {
    final bool fullWidth;
    final RevenueOverTimeChart chartModel;

    const RevenueChart({
      this.fullWidth = false,
      required this.chartModel,
      super.key
    });
    

    @override
    Widget build(BuildContext context) {
      final spots = chartModel.dataPoints.map((point) {
        return FlSpot(
          point.time.millisecondsSinceEpoch.toDouble(),
          point.revenue,
        );
      }).toList();

      String formatCurrency(double value) {
        if (value >= 1000000) {
          return "${(value / 1000000).toStringAsFixed(1)}M";
        } else if (value >= 1000) {
          return "${(value / 1000).toStringAsFixed(0)}K";
        } else {
          return value.toStringAsFixed(0);
        }
      }
      return ChartCard(
        title: chartModel.title,
        child: SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), 
                ),

                // giữ lại nếu muốn
                leftTitles: AxisTitles(
                  axisNameWidget: const Text(
                    "Doanh thu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        formatCurrency(value),
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

                    String formatted;

                    // tuỳ level group từ backend (day/hour/month)
                    formatted = "${date.day}/${date.month}";

                    return Text(
                      formatted,
                      style: const TextStyle(fontSize: 11),
                    );
                  },
                ),
              ),
              ),
              
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  barWidth: 2,
                  color: const Color(0xFF2563EB),
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF2563EB).withOpacity(0.15),
                  ),
                  spots: spots,
                ) 
              ],
            ),
          ),
        ),
      );
    }
  }