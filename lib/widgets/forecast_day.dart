import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';

class ForecastDay extends StatelessWidget {
  final String day;
  final String date;
  final IconData icon; // Use IconData for Flutter icons
  final Color color;
  final String temp;

  // FIX: Using required named parameters for Flutter standard practice
  const ForecastDay({
    super.key,
    required this.day,
    required this.date,
    required this.icon, 
    required this.color,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      // Uses AppColors.secondary (Very Pale Aqua) as the background
      decoration: BoxDecoration(
        color: AppColors.secondary, 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary, width: 2), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              day,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
            Text(
              date,
              style: const TextStyle(fontSize: 10, color: AppColors.textSubtle),
            ),
            const SizedBox(height: 8),
            // Icon color is passed dynamically based on weather condition
            Icon(icon, size: 24, color: color), 
            const SizedBox(height: 8),
            Text(
              temp,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
