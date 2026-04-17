import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_card.dart';
import 'chart_theme.dart';
import 'package:frontend/core/models/top_selling_chart_model.dart';

class TopSellingChart extends StatelessWidget {
  final TopSellingChartModel chartModel;

  const TopSellingChart({super.key, required this.chartModel});

  List<String> get _items => chartModel.dataPoints.map((e) => e.name).toList();
  List<double> get _values => chartModel.dataPoints.map((e) => e.revenue).toList();

  String _shortMoney(double value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(0)}K";
    }
    return value.toStringAsFixed(0);
  }

  double _getInterval() {
    if (_values.isEmpty) return 1000;
    double maxValue = _values.reduce((a, b) => a > b ? a : b);
    return maxValue / 4;
  }

  // Tính chiều cao động
  double get _dynamicHeight {
    const double minHeight = 320;
    const double heightPerItem = 68; // Khoảng cách đẹp cho mỗi cột + label
    const double extraSpace = 120;   // Header + margin

    final calculatedHeight = (_items.length * heightPerItem) + extraSpace;
    return calculatedHeight > minHeight ? calculatedHeight : minHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return ChartCard(
        title: chartModel.title,
        child: const SizedBox(
          height: 200,
          child: Center(child: Text("Chưa có dữ liệu")),
        ),
      );
    }

    return ChartCard(
      title: chartModel.title,
      child: SizedBox(
        height: _dynamicHeight,        // ← Chiều cao tự động
        child: RotatedBox(
          quarterTurns: 1,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 40,
            ),
            child: BarChart(
              BarChartData(
                barGroups: _createBarGroups(),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  horizontalInterval: _getInterval(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),

                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black12, width: 2),
                    bottom: BorderSide(color: Colors.black12, width: 2),
                  ),
                ),

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 90,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx < 0 || idx >= _items.length) {
                          return const SizedBox.shrink();
                        }
                        return RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            _items[idx],
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: _getInterval(),
                      getTitlesWidget: (value, meta) {
                        return RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            _shortMoney(value),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        _formatMoney(rod.toY),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return List.generate(_values.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: _values[i],
            width: 32,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            color: ChartTheme.primary.withOpacity(0.9),
          ),
        ],
      );
    });
  }

  String _formatMoney(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }
}