/// Weather data model for storing comprehensive weather information
class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String weatherMain;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double? windGust;
  final int? windDegree;
  final int cloudiness;
  final int pressure;
  final int visibility;
  final double? dewPoint;
  final int sunrise;
  final int sunset;
  final String iconUrl;
  final double latitude;
  final double longitude;
  final int timezone;
  final DateTime dateTime;
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

  /// Factory constructor to create WeatherModel from API JSON response
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
