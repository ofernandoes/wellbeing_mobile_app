// lib/models/weather_model.dart
class WeatherModel {
  final bool isLoading;
  final String city;
  final double temperature;
  final String description;
  final bool isError;

  WeatherModel({
    required this.isLoading,
    required this.city,
    required this.temperature,
    required this.description,
    this.isError = false,
  });

  // Constructor for the loading state (used by the widget)
  static WeatherModel loading() {
    return WeatherModel(
      isLoading: true,
      city: '...',
      temperature: 0.0,
      description: 'Fetching data',
    );
  }

  // Factory constructor to parse data from a JSON map (typical API response)
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      isLoading: false,
      city: json['name'] ?? 'Unknown City', // Assuming 'name' is the city field in the API
      temperature: (json['main']['temp'] as num).toDouble(), // Assuming structure has main.temp
      description: json['weather'][0]['description'] ?? 'n/a', // Assuming structure has weather[0].description
      isError: false,
    );
  }
  
  // Constructor for the error state
  static WeatherModel error(String message) {
    return WeatherModel(
      isLoading: false,
      city: 'Error',
      temperature: 0.0,
      description: message,
      isError: true,
    );
  }
}