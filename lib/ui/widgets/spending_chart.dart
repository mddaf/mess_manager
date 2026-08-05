import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/member_balance.dart';

enum SpendingChartType { pie, bar }

class SpendingChart extends StatelessWidget {
  final List<MemberBalance> memberBalances;
  final SpendingChartType chartType;

  const SpendingChart({
    super.key,
    required this.memberBalances,
    this.chartType = SpendingChartType.pie,
  });

  static const List<Color> _chartColors = [
    Color(0xFF2E7D32),
    Color(0xFF00897B),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFD81B60),
    Color(0xFFFB8C00),
    Color(0xFF7CB342),
    Color(0xFF00ACC1),
  ];

  @override
  Widget build(BuildContext context) {
    if (memberBalances.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No spending data available')),
      );
    }

    if (chartType == SpendingChartType.pie) {
      return SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: List.generate(memberBalances.length, (index) {
              final item = memberBalances[index];
              final color = _chartColors[index % _chartColors.length];
              return PieChartSectionData(
                color: color,
                value: item.totalCost > 0 ? item.totalCost : 1.0,
                title: '${item.memberName}\n${item.totalCost.toStringAsFixed(0)}',
                radius: 65,
                titleStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: List.generate(memberBalances.length, (index) {
              final item = memberBalances[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: item.totalCost,
                    color: _chartColors[index % _chartColors.length],
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < memberBalances.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          memberBalances[idx].memberName,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
