// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
// Note: You may need to import QuoteModel if you have one, 
// but based on your implementation, it returns a String, so no extra import needed.

class ApiService {
  // 💡 ACTION: Replace the placeholder with your actual OpenWeatherMap API Key.
  static const String openWeatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY'; 
  
  // Note: For a real app, API keys should be secured (e.g., using environment variables).

  // Fetch Weather Data - RENAMED TO MATCH home_screen.dart
  Future<WeatherModel> fetchWeatherData(String city) async {
    final weatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$openWeatherApiKey');

    final response = await http.get(weatherUrl);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Fetch Inspirational Quote - RENAMED TO MATCH home_screen.dart
  Future<String> fetchQuoteData() async {
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