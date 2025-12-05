import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../models/weather_model.dart';

/// Exception for weather service errors
class WeatherServiceException implements Exception {
  final String message;

  WeatherServiceException(this.message);

  @override
  String toString() => message;
}

/// Service for fetching weather data from OpenWeatherMap API
class WeatherService {
  /// Fetch weather data by city name
  /// 
  /// Returns: WeatherModel containing weather data
  /// Throws: WeatherServiceException on error
  static Future<WeatherModel> getWeatherByCity({
    required String cityName,
    String units = 'metric',
  }) async {
    try {
      // Validate API key
      if (ApiConfig.apiKey == 'YOUR_API_KEY_HERE') {
        throw WeatherServiceException(
          'API key not configured. Please add your OpenWeatherMap API key to lib/constants/api_config.dart',
        );
      }

      final String url =
          '${ApiConfig.currentWeatherEndpoint}?q=$cityName&appid=${ApiConfig.apiKey}&units=$units';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw WeatherServiceException(
            'Request timeout. Please check your internet connection.',
          );
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherModel.fromJson(json);
      } else if (response.statusCode == 404) {
        throw WeatherServiceException('City not found. Please try another city.');
      } else if (response.statusCode == 401) {
        throw WeatherServiceException('Invalid API key. Please check your configuration.');
      } else {
        throw WeatherServiceException(
          'Failed to fetch weather data. Error: ${response.statusCode}',
        );
      }
    } on WeatherServiceException {
      rethrow;
    } catch (e) {
      throw WeatherServiceException(
        'An unexpected error occurred: $e',
      );
    }
  }

  /// Fetch weather data by coordinates (latitude and longitude)
  /// 
  /// Returns: WeatherModel containing weather data
  /// Throws: WeatherServiceException on error
  static Future<WeatherModel> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
    String units = 'metric',
  }) async {
    try {
      if (ApiConfig.apiKey == 'YOUR_API_KEY_HERE') {
        throw WeatherServiceException(
          'API key not configured. Please add your OpenWeatherMap API key to lib/constants/api_config.dart',
        );
      }

      final String url =
          '${ApiConfig.currentWeatherEndpoint}?lat=$latitude&lon=$longitude&appid=${ApiConfig.apiKey}&units=$units';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw WeatherServiceException(
            'Request timeout. Please check your internet connection.',
          );
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherModel.fromJson(json);
      } else if (response.statusCode == 401) {
        throw WeatherServiceException('Invalid API key. Please check your configuration.');
      } else {
        throw WeatherServiceException(
          'Failed to fetch weather data. Error: ${response.statusCode}',
        );
      }
    } on WeatherServiceException {
      rethrow;
    } catch (e) {
      throw WeatherServiceException(
        'An unexpected error occurred: $e',
      );
    }
  }
}
