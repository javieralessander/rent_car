import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Modelo propio para los items apilados
class CustomRodStackItem {
  final double fromY;
  final double toY;
  final Color color;

  CustomRodStackItem(this.fromY, this.toY, this.color);

  BarChartRodStackItem toFlChart() => BarChartRodStackItem(fromY, toY, color);
}

// Modelo propio para los datos de cada barra
class CustomBarChartData {
  final List<List<CustomRodStackItem>> stackedRods;

  CustomBarChartData({required this.stackedRods});
}

class CustomBarChart extends StatelessWidget {
  final List<CustomBarChartData> data;
  final List<String> bottomLabels;
  final Color gridColor;
  final double maxY;

  const CustomBarChart({
    super.key,
    required this.data,
    required this.bottomLabels,
    required this.gridColor,
    required this.maxY,
  });

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text = '';
    if (value.toInt() >= 0 && value.toInt() < bottomLabels.length) {
      text = bottomLabels[value.toInt()];
    }
    return SideTitleWidget(meta: meta, child: Text(text, style: style));
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) return Container();
    const style = TextStyle(fontSize: 10);
    return SideTitleWidget(
      meta: meta,
      child: Text(meta.formattedValue, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.66,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barsWidth = constraints.maxWidth * 0.04;
            final barsSpace = barsWidth * 4;
            return BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.center,
                barTouchData: const BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: _bottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: _leftTitles,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 10 == 0,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: gridColor.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                groupsSpace: barsSpace,
                barGroups: List.generate(data.length, (groupIdx) {
                  return BarChartGroupData(
                    x: groupIdx,
                    barsSpace: barsSpace,
                    barRods: List.generate(
                      data[groupIdx].stackedRods.length,
                      (rodIdx) => BarChartRodData(
                        toY: data[groupIdx].stackedRods[rodIdx].last.toY,
                        rodStackItems:
                            data[groupIdx].stackedRods[rodIdx]
                                .map((w) => w.toFlChart())
                                .toList(),
                        borderRadius: BorderRadius.zero,
                        width: barsWidth,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
