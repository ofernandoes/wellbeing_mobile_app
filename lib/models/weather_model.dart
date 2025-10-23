// lib/models/weather_model.dart

class WeatherModel {
  final double currentTemp;
  final String currentCondition;
  final String currentIcon; // OpenWeatherMap icon code (e.g., '01d' for sun)
  final String adviceMessage;
  final List<ForecastItem> forecast;
  final bool isError;

  WeatherModel({
    required this.currentTemp,
    required this.currentCondition,
    required this.currentIcon,
    required this.adviceMessage,
    required this.forecast,
    this.isError = false,
  });

  // Factory constructor to handle the complex JSON response from OpenWeatherMap
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Extract current data from the first item in the 'list' (it's a 5-day/3-hour forecast)
    final current = json['list'][0];
    
    // Build the daily forecast list by sampling every 8th item (8 * 3 hours = 24 hours)
    final List<ForecastItem> weeklyForecast = [];
    for (int i = 0; i < json['list'].length && weeklyForecast.length < 7; i += 8) {
      final dayData = json['list'][i];
      weeklyForecast.add(ForecastItem(
        timestamp: dayData['dt'] * 1000,
        temp: dayData['main']['temp'].toDouble(),
        conditionIcon: dayData['weather'][0]['icon'],
      ));
    }

    return WeatherModel(
      currentTemp: current['main']['temp'].toDouble(),
      currentCondition: current['weather'][0]['description'],
      currentIcon: current['weather'][0]['icon'],
      adviceMessage: 'Weather looks good for an outdoor activity today!', // Placeholder advice
      forecast: weeklyForecast,
    );
  }
  
  // Model for the loading/error state
  static WeatherModel loading() {
    return WeatherModel(
      currentTemp: 0.0,
      currentCondition: 'Fetching forecast...',
      currentIcon: '50d', // Default cloudy icon
      adviceMessage: 'Loading wellbeing advice...',
      forecast: [],
      isError: false,
    );
  }
}

class ForecastItem {
  final int timestamp;
  final double temp;
  final String conditionIcon;

  ForecastItem({
    required this.timestamp,
    required this.temp,
    required this.conditionIcon,
  });
}
