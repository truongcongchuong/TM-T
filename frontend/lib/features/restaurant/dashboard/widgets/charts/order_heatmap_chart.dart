import 'package:flutter/material.dart';
import 'chart_card.dart';
import 'package:frontend/core/models/order_over_time_chart_model.dart';

class OrdersHeatmapChart extends StatelessWidget {
  final OrderOverTimeChart dataOrderOverTime;
  const OrdersHeatmapChart({super.key, required this.dataOrderOverTime});

  Color _getColor(int value) {
    if (value >= 20) return const Color(0xFF1E3A8A); // 🔥 rất cao điểm
    if (value >= 15) return const Color(0xFF3B82F6); // ⚡ cao điểm
    if (value >= 10) return const Color(0xFF60A5FA); // 📈 trung bình
    if (value >= 5)  return const Color(0xFF93C5FD); // 🙂 thấp
    return const Color(0xFFDBEAFE); // 💤 rất thấp
  }

  @override
  Widget build(BuildContext context) {
    final data = dataOrderOverTime.dataPoints;

    final days = dataOrderOverTime.dataPoints.map((e) => e.dayOfWeek).toSet().toList(); // Lấy danh sách ngày duy nhất
    final hours = dataOrderOverTime.dataPoints.map((e) => e.hour).toSet().toList(); // Giờ từ 0 đến 23
    return ChartCard(
      title: dataOrderOverTime.title,
      child: SizedBox(
        height: 450,
        child: Column(
          children: [
            // 👇 Header ngày
            Row(
              children: [
                const SizedBox(width: 40),
                ...days.map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )),
              ],
            ),

            const SizedBox(height: 8),

            // 👇 Grid heatmap
            Expanded(
              child: Column(
                children: List.generate(hours.length, (hour) {
                  return Expanded( // 👈 mỗi row tự co lại
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            "${hour}h",
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),

                        ...List.generate(7, (day) {
                          final value = data.firstWhere(
                            (d) => d.dayOfWeek == days[day] && d.hour == hour,
                            orElse: () => OrderOverTimeDataPoint(
                              dayOfWeek: days[day],
                              hour: hour,
                              totalOrders: 0,
                            ),
                          ).totalOrders;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                // ❌ bỏ height cố định
                                decoration: BoxDecoration(
                                  color: _getColor(value),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            _buildLegend(),
          ],
        ),
      ),
    );
  }
}

Widget _buildLegend() {
  final legendItems = [
    {
      "color": const Color(0xFFDBEAFE),
      "label": "Rất thấp",
      "icon": "💤"
    },
    {
      "color": const Color(0xFF93C5FD),
      "label": "Thấp",
      "icon": "🙂"
    },
    {
      "color": const Color(0xFF60A5FA),
      "label": "Trung bình",
      "icon": "📈"
    },
    {
      "color": const Color(0xFF3B82F6),
      "label": "Cao điểm",
      "icon": "⚡"
    },
    {
      "color": const Color(0xFF1E3A8A),
      "label": "Rất cao điểm",
      "icon": "🔥"
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Chú thích",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 10,
        runSpacing: 6,
        children: legendItems.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item["color"] as Color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "${item["icon"]} ${item["label"]}",
                style: const TextStyle(fontSize: 10),
              ),
            ],
          );
        }).toList(),
      ),
    ],
  );
}