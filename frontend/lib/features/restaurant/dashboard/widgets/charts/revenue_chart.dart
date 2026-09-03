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
    super.key,
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
      }
      return value.toStringAsFixed(0);
    }

    String formatDate(DateTime date) {
      return "${date.day}/${date.month}";
    }

    final int labelInterval = chartModel.dataPoints.length > 15 ? 2 : 1;

    return ChartCard(
      title: chartModel.title,
      child: SizedBox(
        height: 450, // tăng chiều cao để có thêm không gian
        child: Padding(
          padding: const EdgeInsets.only(right: 32, left: 20, top: 20, bottom: 10),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10e6,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                leftTitles: AxisTitles(
                  axisNameSize: 80,   // Tăng kích thước cho nhãn dọc
                  axisNameWidget: const RotatedBox(
                    quarterTurns: 1,  // Xoay 90 độ
                    child: Text(
                      'Doanh thu (VND)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 75,
                    interval: 10e6,
                    getTitlesWidget: (value, meta) => Text(
                      formatCurrency(value),
                      style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                    ),
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      final index = spots.indexWhere((spot) => (spot.x - value).abs() < 1);
                      if (index == -1 || index % labelInterval != 0) {
                        return const SizedBox();
                      }
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          formatDate(date),
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.4,
                  barWidth: 3.2,
                  color: const Color(0xFF2563EB),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 2.8,
                      color: Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: const Color(0xFF2563EB),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2563EB).withOpacity(0.3),
                        const Color(0xFF2563EB).withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
              ],

              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 10,
                  tooltipPadding: const EdgeInsets.all(12),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                      return LineTooltipItem(
                        "${formatDate(date)}\n",
                        const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        children: [
                          TextSpan(
                            text: formatCurrency(spot.y),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}