import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';

class BarChartSample7 extends StatefulWidget {
  const BarChartSample7({
    super.key,
    required this.dataList,
    this.title = 'Horizontal Bar Chart',
    this.maxY = 20,
    this.shadowColor = const Color(0xFFCCCCCC),
  });

  final List<BarData> dataList;
  final String title;
  final double maxY;
  final Color shadowColor;

  @override
  State<BarChartSample7> createState() => _BarChartSample7State();
}

class _BarChartSample7State extends State<BarChartSample7> {
  int touchedGroupIndex = -1;
  int rotationTurns = 1;

  BarChartGroupData generateBarGroup(
    int x,
    Color color,
    double value,
    double shadowValue,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: value, color: color, width: 6),
        BarChartRodData(toY: shadowValue, color: widget.shadowColor, width: 6),
      ],
      showingTooltipIndicators: touchedGroupIndex == x ? [0] : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final double pad = isMobile ? 12 : 24;
    final double titleFont = isMobile ? 16 : 20;
    final double iconSize = isMobile ? 22 : 28;
    final double reservedSize = isMobile ? 24 : 36;

    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                widget.title,
                style: TextStyle(
                  color: AppColors.mainTextColor1,
                  fontSize: titleFont,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Tooltip(
                    message: 'Rotate the chart 90 degrees (cw)',
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          rotationTurns += 1;
                        });
                      },
                      icon: RotatedBox(
                        quarterTurns: rotationTurns - 1,
                        child: const Icon(Icons.rotate_90_degrees_cw),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 18),
          // CAMBIO CLAVE: Usa Expanded en vez de AspectRatio
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                rotationQuarterTurns: rotationTurns,
                borderData: FlBorderData(
                  show: true,
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: AppColors.borderColor.withOpacity(0.2),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    drawBelowEverything: true,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: reservedSize,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: reservedSize,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= widget.dataList.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: _IconWidget(
                            color: widget.dataList[index].color,
                            isSelected: touchedGroupIndex == index,
                            size: iconSize,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: AppColors.borderColor.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                ),
                barGroups:
                    widget.dataList.asMap().entries.map((e) {
                      final index = e.key;
                      final data = e.value;
                      return generateBarGroup(
                        index,
                        data.color,
                        data.value,
                        data.shadowValue,
                      );
                    }).toList(),
                maxY: widget.maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.transparent,
                    tooltipMargin: 0,
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      return BarTooltipItem(
                        rod.toY.toString(),
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rod.color,
                          fontSize: isMobile ? 14 : 18,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 12),
                          ],
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions &&
                        response != null &&
                        response.spot != null) {
                      setState(() {
                        touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                      });
                    } else {
                      setState(() {
                        touchedGroupIndex = -1;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarData {
  const BarData(this.color, this.value, this.shadowValue);

  final Color color;
  final double value;
  final double shadowValue;
}

class _IconWidget extends ImplicitlyAnimatedWidget {
  const _IconWidget({
    required this.color,
    required this.isSelected,
    this.size = 28,
  }) : super(duration: const Duration(milliseconds: 300));
  final Color color;
  final bool isSelected;
  final double size;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _IconWidgetState();
}

class _IconWidgetState extends AnimatedWidgetBaseState<_IconWidget> {
  Tween<double>? _rotationTween;

  @override
  Widget build(BuildContext context) {
    final rotation = math.pi * 4 * _rotationTween!.evaluate(animation);
    final scale = 1 + _rotationTween!.evaluate(animation) * 0.5;
    return Transform(
      transform: Matrix4.rotationZ(rotation).scaled(scale, scale),
      origin: Offset(widget.size / 2, widget.size / 2),
      child: Icon(
        widget.isSelected ? Icons.face_retouching_natural : Icons.face,
        color: widget.color,
        size: widget.size,
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _rotationTween =
        visitor(
              _rotationTween,
              widget.isSelected ? 1.0 : 0.0,
              (dynamic value) => Tween<double>(
                begin: value as double,
                end: widget.isSelected ? 1.0 : 0.0,
              ),
            )
            as Tween<double>?;
  }
}
