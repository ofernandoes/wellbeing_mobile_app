import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
// Assuming WeatherModel is in a models folder and accessible:
import '../models/weather_model.dart'; 

class WeatherCard extends StatelessWidget {
  final WeatherModel weatherData;

  const WeatherCard({super.key, required this.weatherData});

  // Helper function to map weather description to an icon
  IconData _getWeatherIcon(String description) {
    if (description.toLowerCase().contains('cloud')) {
      return FontAwesomeIcons.cloud;
    } else if (description.toLowerCase().contains('rain') || description.toLowerCase().contains('drizzle')) {
      return FontAwesomeIcons.cloudRain;
    } else if (description.toLowerCase().contains('sun') || description.toLowerCase().contains('clear')) {
      return FontAwesomeIcons.sun;
    } else if (description.toLowerCase().contains('snow')) {
      return FontAwesomeIcons.snowflake;
    } else if (description.toLowerCase().contains('thunder')) {
      return FontAwesomeIcons.cloudBolt;
    }
    return FontAwesomeIcons.smog; // Default
  }

  @override
  Widget build(BuildContext context) {
    // Check for the loading state (using the internal flag in the model)
    if (weatherData.isLoading) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.cloud_queue, size: 30, color: AppColors.textSubtle),
              SizedBox(width: 15),
              Text(
                'Fetching weather...',
                style: TextStyle(fontSize: 18, color: AppColors.textSubtle),
              ),
            ],
          ),
        ),
      );
    }
    
    // Determine the icon and text color
    final icon = _getWeatherIcon(weatherData.description);
    final isClear = weatherData.description.toLowerCase().contains('sun') || weatherData.description.toLowerCase().contains('clear');
    final iconColor = isClear ? AppColors.accent : AppColors.primaryColor;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local Weather',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Divider(height: 15),
            Row(
              children: <Widget>[
                // Weather Icon
                FaIcon(
                  icon,
                  size: 40,
                  color: iconColor,
                ),
                const SizedBox(width: 15),
                // Temperature and Location
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${weatherData.temperature.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${weatherData.city} (${weatherData.description})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
