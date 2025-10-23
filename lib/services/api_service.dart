// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class ApiService {
  // 💡 ACTION: Replace the placeholder with your actual OpenWeatherMap API Key.
  static const String openWeatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY'; 
  
  // Note: For a real app, API keys should be secured (e.g., using environment variables).

  // Fetch Weather Data
  Future<WeatherModel> fetchWeather(String city) async {
    final weatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$openWeatherApiKey');

    final response = await http.get(weatherUrl);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Fetch Inspirational Quote (using a public, simple API)
  Future<String> fetchQuote() async {
    // Using a public API for simple quote fetching
    final quoteUrl = Uri.parse('https://api.quotable.io/random');

    final response = await http.get(quoteUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return '"${data['content']}" - ${data['author']}';
    } else {
      return '"The secret of getting ahead is getting started." - Mark Twain (Placeholder)';
    }
  }
}
