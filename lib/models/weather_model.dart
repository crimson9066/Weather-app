/// Represents comprehensive weather data for a city from OpenWeatherMap API.
///
/// This model captures 20 different weather metrics including temperature,
/// atmospheric conditions, wind data, and location information. All fields
/// are populated from the API response and used throughout the app for
/// display and analysis.
class WeatherModel {
  /// City name from the API response
  final String cityName;

  /// Current temperature in the specified unit (Celsius or Fahrenheit)
  final double temperature;

  /// Human-readable weather description (e.g., "light rain", "clear sky")
  final String description;

  /// Main weather category (e.g., "Rain", "Clear", "Clouds", "Snow", "Thunderstorm")
  final String weatherMain;

  /// What the temperature feels like due to wind chill or humidity
  final double feelsLike;

  /// Percentage of atmospheric humidity (0-100)
  final int humidity;

  /// Wind speed in the specified unit (m/s for metric, mph for imperial)
  final double windSpeed;

  /// Wind gust speed (sudden wind speed increase) - optional
  final double? windGust;

  /// Wind direction in degrees (0-360) - optional
  final int? windDegree;

  /// Cloud coverage percentage (0-100)
  final int cloudiness;

  /// Atmospheric pressure in hPa
  final int pressure;

  /// Maximum visibility distance in meters
  final int visibility;

  /// Dew point temperature - optional
  final double? dewPoint;

  /// Unix timestamp of sunrise time
  final int sunrise;

  /// Unix timestamp of sunset time
  final int sunset;

  /// URL to the weather icon from OpenWeatherMap
  final String iconUrl;

  /// Geographic latitude of the city
  final double latitude;

  /// Geographic longitude of the city
  final double longitude;

  /// Timezone offset in seconds from UTC
  final int timezone;

  /// Time when this weather data was retrieved
  final DateTime dateTime;

  /// ISO 3166 country code (e.g., "US", "GB", "JP")
  final String countryCode;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.weatherMain,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    this.windGust,
    this.windDegree,
    required this.cloudiness,
    required this.pressure,
    required this.visibility,
    this.dewPoint,
    required this.sunrise,
    required this.sunset,
    required this.iconUrl,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.dateTime,
    required this.countryCode,
  });

  /// Creates a WeatherModel from the OpenWeatherMap API JSON response.
  ///
  /// This factory method parses the nested JSON structure from the API and
  /// extracts weather data into a strongly-typed Dart model. It uses null
  /// coalescing operators to provide sensible defaults for missing fields.
  ///
  /// The API response includes nested objects for weather conditions, wind data,
  /// system info (sunrise/sunset), and geographic coordinates. This method
  /// flattens that structure into individual fields for easier access throughout
  /// the app.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      description: json['weather'][0]['description'] ?? 'No description',
      weatherMain: json['weather'][0]['main'] ?? 'Unknown',
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      windGust: json['wind']['gust'] != null
          ? (json['wind']['gust']).toDouble()
          : null,
      windDegree: json['wind']['deg'],
      cloudiness: json['clouds']['all'] ?? 0,
      pressure: json['main']['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      dewPoint: json['main']['dew_point'] != null
          ? (json['main']['dew_point']).toDouble()
          : null,
      sunrise: json['sys']['sunrise'] ?? 0,
      sunset: json['sys']['sunset'] ?? 0,
      iconUrl:
          'https://openweathermap.org/img/wn/${json['weather'][0]['icon']}@4x.png',
      latitude: (json['coord']['lat'] ?? 0).toDouble(),
      longitude: (json['coord']['lon'] ?? 0).toDouble(),
      timezone: json['timezone'] ?? 0,
      dateTime: DateTime.now(),
      countryCode: json['sys']['country'] ?? 'N/A',
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'description': description,
      'weatherMain': weatherMain,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windGust': windGust,
      'windDegree': windDegree,
      'cloudiness': cloudiness,
      'pressure': pressure,
      'visibility': visibility,
      'dewPoint': dewPoint,
      'sunrise': sunrise,
      'sunset': sunset,
      'iconUrl': iconUrl,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'dateTime': dateTime.toIso8601String(),
      'countryCode': countryCode,
    };
  }

  /// Factory constructor to create WeatherModel from stored JSON
  factory WeatherModel.fromStoredJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'],
      temperature: json['temperature'],
      description: json['description'],
      weatherMain: json['weatherMain'],
      feelsLike: json['feelsLike'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'],
      windGust: json['windGust'],
      windDegree: json['windDegree'],
      cloudiness: json['cloudiness'] ?? 0,
      pressure: json['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      dewPoint: json['dewPoint'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
      iconUrl: json['iconUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
      dateTime: DateTime.parse(json['dateTime']),
      countryCode: json['countryCode'] ?? 'N/A',
    );
  }
}
