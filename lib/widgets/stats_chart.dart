// lib/widgets/stats_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';

// Import the model if the chart uses it directly (e.g., to display points)
// import 'package:wellbeing_mobile_app/models/daily_checkin_model.dart'; 


class StatsChart extends StatelessWidget {
  final List<double> moodData; // Data points for the chart
  // Example moodData: [3.0, 4.0, 5.0, 3.5, 4.5, 4.0, 3.0]

  const StatsChart({super.key, required this.moodData});

  // Calculate the highest y-value for chart scaling
  double get maxMoodValue => moodData.isEmpty
      ? 5.0
      : moodData.reduce((a, b) => a > b ? a : b).ceilToDouble();

  // Calculate the lowest y-value for chart scaling
  double get minMoodValue => moodData.isEmpty
      ? 1.0
      : moodData.reduce((a, b) => a < b ? a : b).floorToDouble();


  @override
  Widget build(BuildContext context) {
    // If no data is present, show a placeholder
    if (moodData.isEmpty) {
      return const Center(
        child: Text("Not enough data for chart.", style: TextStyle(color: AppColors.textSubtle)),
      );
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
        child: LineChart(
          _mainData(),
        ),
      ),
    );
  }

  // The main data configuration for the LineChart
  LineChartData _mainData() {
    return LineChartData(
      // --- GRID & BORDERS ---
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            // FIX: Replaced deprecated withOpacity usage
            color: AppColors.primaryColor.withAlpha(50), 
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(side: SideTitles.rightSide(showTitles: false)), // FIX: Use AxisTitles
        topTitles: const AxisTitles(side: SideTitles.topSide(showTitles: false)), // FIX: Use AxisTitles
        
        // --- BOTTOM AXIS (X-Axis) ---
        bottomTitles: AxisTitles( // FIX: Use AxisTitles
          // CRITICAL FIX: The axisSide parameter is now inside SideTitles
          sideTitles: SideTitles( 
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),

        // --- LEFT AXIS (Y-Axis) ---
        leftTitles: AxisTitles( // FIX: Use AxisTitles
          // CRITICAL FIX: The axisSide parameter is now inside SideTitles
          sideTitles: SideTitles( 
            showTitles: true,
            interval: 1,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          // FIX: Replaced deprecated withOpacity usage
          color: AppColors.primaryColor.withAlpha(100), 
          width: 1,
        ),
      ),
      // Set the scale based on data
      minX: 0,
      maxX: (moodData.length - 1).toDouble(),
      minY: minMoodValue - 0.5,
      maxY: maxMoodValue + 0.5,
      
      // --- LINE BAR DATA ---
      lineBarsData: [
        LineChartBarData(
          spots: moodData.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value);
          }).toList(),
          isCurved: true,
          color: AppColors.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            // Customizing dot display on the chart
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.accent,
                // FIX: Replaced deprecated withOpacity usage
                strokeColor: AppColors.primaryColor.withAlpha(200), 
                strokeWidth: 2,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                // FIX: Replaced deprecated withOpacity usage
                AppColors.primaryColor.withAlpha(150), 
                AppColors.primaryColor.withAlpha(50),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  // Widget for the Y-Axis titles (Mood Scores)
  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: AppColors.textSubtle,
    );
    String text;
    // Map the numerical value back to a descriptive label (1-5 scale)
    switch (value.toInt()) {
      case 1: text = 'Terrible'; break;
      case 2: text = 'Bad'; break;
      case 3: text = 'Okay'; break;
      case 4: text = 'Good'; break;
      case 5: text = 'Great'; break;
      default: return Container();
    }

    // CRITICAL FIX: Use the meta to correctly position the widget
    return SideTitleWidget(
      axisSide: meta.axisSide, // CRITICAL FIX: Required parameter 'axisSide' is now defined via meta
      space: 4,
      child: Text(text, style: style),
    );
  }

  // Widget for the X-Axis titles (Days/Points)
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: AppColors.textSubtle,
    );
    Widget text;
    
    // Display only the first, middle, and last points
    if (value.toInt() == 0) {
      text = const Text('Start', style: style);
    } else if (value.toInt() == moodData.length - 1) {
      text = const Text('End', style: style);
    } else if (moodData.length > 3 && value.toInt() == moodData.length ~/ 2) {
      text = const Text('Mid', style: style);
    } else {
      return Container(); // Hide other labels
    }

    // CRITICAL FIX: Use the meta to correctly position the widget
    return SideTitleWidget(
      axisSide: meta.axisSide, // CRITICAL FIX: Required parameter 'axisSide' is now defined via meta
      space: 8.0,
      child: text,
    );
  }
}
