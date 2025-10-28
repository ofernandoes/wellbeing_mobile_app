import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsChart extends StatelessWidget {
  final String title;
  final List<double> data; // List of 7 double values (scores)
  final String bottomLabel;

  const StatsChart({
    super.key,
    required this.title,
    required this.data,
    required this.bottomLabel,
  }) : assert(data.length == 7, 'The data list must contain exactly 7 values.');

  // Helper to determine the color based on the title
  Color _getChartColor() {
    if (title.contains('Mood')) {
      return Colors.pink.shade300;
    } else if (title.contains('Sleep')) {
      return Colors.indigo.shade300;
    } else if (title.contains('Exercise')) {
      return Colors.green.shade300;
    }
    return Colors.grey;
  }

  // Gets the maximum Y-axis value based on the chart type
  double _getMaxY() {
    if (title.contains('Mood')) {
      return 5.0; // Mood scale is 1 to 5
    } else if (title.contains('Sleep')) {
      return 4.0; // Sleep scale is 1 to 4
    } else if (title.contains('Exercise')) {
      return 5.0; // Mock exercise scale is 0 to 5
    }
    return 5.0; 
  }

  @override
  Widget build(BuildContext context) {
    final chartColor = _getChartColor();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16, bottom: 8, left: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Title
            Padding(
              padding: const EdgeInsets.only(left: 14.0, bottom: 8),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Line Chart Widget from fl_chart
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6, // 7 points (0 to 6)
                  minY: 0,
                  maxY: _getMaxY(),
                  
                  // Configure the chart appearance (borders, grid)
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                    
                    // Bottom Titles (X-axis labels)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          // Only show titles for the start (Day 1) and end (Day 7)
                          if (value == 0 || value == 6) {
                            return SideTitleWidget(
                              // ✅ FIX: Removed obsolete 'axisSide' parameter (Line 90 fix)
                              axisSide: meta.axisSide, 
                              space: 8.0,
                              child: Text('${value.toInt() + 1}', style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    // Left Titles (Y-axis labels)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Show labels for min, max, and mid-points (e.g., 0, 2, 4, 5)
                          if (value == 0 || value == 1 || value == _getMaxY() / 2 || value == _getMaxY()) {
                            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                        interval: 1,
                      ),
                    ),
                  ),
                  
                  // Chart Grid Lines
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withAlpha((255 * 0.1).round()),
                      strokeWidth: 1,
                    ),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withAlpha((255 * 0.1).round()),
                      strokeWidth: 1,
                    ),
                  ),
                  
                  // Line Definition
                  borderData: FlBorderData(show: false), // Hide default border
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        // entry.key is the index (0 to 6), entry.value is the score
                        // ✅ FIX: Added required 'meta' parameter (Line 89 fix)
                        return FlSpot(
                          entry.key.toDouble(), 
                          entry.value, 
                          meta: FlSpot.barEndMeta,
                        );
                      }).toList(),
                      isCurved: true,
                      color: chartColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: chartColor.darken(20), // Darker dot color
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: chartColor.withAlpha((255 * 0.2).round()), // Light fill below the line
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Label/Description
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 14.0),
              child: Text(
                bottomLabel,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to darken color for dots
extension ColorExtension on Color {
  // NOTE: The deprecation fixes in the original code for this extension are assumed to be correct.
  Color darken([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final f = 1 - percent / 100;
    return Color.fromARGB(
      (alpha * 255.0).round() & 0xff,
      (red * f * 255.0).round() & 0xff,
      (green * f * 255.0).round() & 0xff,
      (blue * f * 255.0).round() & 0xff,
    );
  }
}