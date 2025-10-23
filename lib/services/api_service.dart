// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wellbeing_mobile_app/models/weather_model.dart'; 
import 'package:wellbeing_mobile_app/models/quote_model.dart'; 

// CRITICAL: Replace this with your actual OpenWeatherMap key at the end of Phase 2
const String kWeatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
const String kWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
const String kQuoteApiUrl = 'https://api.quotable.io/random';

class ApiService {
  // --- 1. Weather API Fetcher ---
  Future<WeatherModel> fetchWeatherData({
    double lat = 51.5074, 
    double lon = 0.1278,
  }) async {
    final url = Uri.parse(
      '$kWeatherBaseUrl/forecast?lat=$lat&lon=$lon&appid=$kWeatherApiKey&units=metric'
    );
    
    if (kWeatherApiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
       print('ERROR: Placeholder key detected. Using loading state.');
       return WeatherModel.loading();
    }

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Network/Parsing Error in fetchWeatherData: $e');
      return WeatherModel.loading();
    }
  }

  // --- 2. Quote API Fetcher ---
  Future<QuoteModel> fetchQuoteData() async {
    final url = Uri.parse(kQuoteApiUrl);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuoteModel.fromJson(data);
      } else {
        throw Exception('Failed to load quote: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Network/Parsing Error in fetchQuoteData: $e');
      return QuoteModel.loading();
    }
  }
}
