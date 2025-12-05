import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/weather_providers.dart';
import '../widgets/reusable_widgets.dart' as weather_widgets;

/// Weather Details Screen - Shows comprehensive weather information for a city
class WeatherDetailsScreen extends ConsumerStatefulWidget {
  final String cityName;

  const WeatherDetailsScreen({
    Key? key,
    required this.cityName,
  }) : super(key: key);

  @override
  ConsumerState<WeatherDetailsScreen> createState() =>
      _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends ConsumerState<WeatherDetailsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => _buildContent(context, ref),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(widget.cityName));
    final unit = ref.watch(temperatureUnitProvider);
    final isFavAsync = ref.watch(isFavoriteProvider(widget.cityName));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
        centerTitle: true,
        actions: [
          isFavAsync.when(
            data: (isFav) => IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? colorScheme.error : null,
              ),
              onPressed: () async {
                final storage = ref.read(storageServiceProvider);
                if (isFav) {
                  await storage.removeFavorite(widget.cityName);
                } else {
                  await storage.addFavorite(widget.cityName);
                }
                ref.invalidate(isFavoriteProvider(widget.cityName));
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: weatherAsync.when(
        data: (weather) {
          final tempUnit = unit == 'metric' ? '°C' : '°F';
          final speedUnit = unit == 'metric' ? 'm/s' : 'mph';
          final pressureUnit = 'hPa';
          final visibilityUnit = unit == 'metric' ? 'km' : 'mi';

          // Calculate local time
          final utcTime = DateTime.now().toUtc();
          final localTime = utcTime.add(Duration(seconds: weather.timezone));
          final timeFormatter = DateFormat('HH:mm:ss');
          final dateFormatter = DateFormat('EEEE, MMM d, yyyy');

          // Calculate sunrise and sunset time
          final sunriseTime = DateTime.fromMillisecondsSinceEpoch(
            weather.sunrise * 1000,
          ).add(Duration(seconds: weather.timezone));
          final sunsetTime = DateTime.fromMillisecondsSinceEpoch(
            weather.sunset * 1000,
          ).add(Duration(seconds: weather.timezone));

          final visibility = unit == 'metric'
              ? (weather.visibility / 1000).toStringAsFixed(1)
              : (weather.visibility / 1609).toStringAsFixed(1);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero section with weather icon and main temperature
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient:
                        _getWeatherGradient(weather.weatherMain, colorScheme),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: [
                      // Weather icon with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Image.network(
                                weather.iconUrl,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.cloud,
                                        size: 80, color: colorScheme.onPrimary),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Temperature with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: weather.temperature),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Text(
                            '${value.toStringAsFixed(0)}$tempUnit',
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      // Weather description
                      Text(
                        weather.description.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Feels like
                      Text(
                        'Feels like ${weather.feelsLike.toStringAsFixed(1)}$tempUnit',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Local time
                      Text(
                        dateFormatter.format(localTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        timeFormatter.format(localTime),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Country
                      Text(
                        weather.countryCode,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabs
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabButton('Current', 0, colorScheme),
                        const SizedBox(width: 8),
                        _buildTabButton('Atmosphere', 1, colorScheme),
                        const SizedBox(width: 8),
                        _buildTabButton('Wind', 2, colorScheme),
                      ],
                    ),
                  ),
                ),

                // Tab content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildTabContent(
                    _selectedTabIndex,
                    weather,
                    tempUnit,
                    speedUnit,
                    pressureUnit,
                    visibilityUnit,
                    timeFormatter,
                    sunriseTime,
                    sunsetTime,
                    visibility,
                    colorScheme,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 100),
          child:
              weather_widgets.LoadingWidget(message: 'Loading weather data...'),
        ),
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.only(top: 100),
          child: weather_widgets.ErrorMessageWidget(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(weatherProvider(widget.cityName));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, ColorScheme colorScheme) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected ? null : Border.all(color: colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    int tabIndex,
    dynamic weather,
    String tempUnit,
    String speedUnit,
    String pressureUnit,
    String visibilityUnit,
    DateFormat timeFormatter,
    DateTime sunriseTime,
    DateTime sunsetTime,
    String visibility,
    ColorScheme colorScheme,
  ) {
    switch (tabIndex) {
      case 0:
        return _buildCurrentWeatherTab(
          weather,
          tempUnit,
          timeFormatter,
          sunriseTime,
          sunsetTime,
          colorScheme,
        );
      case 1:
        return _buildAtmosphereTab(
          weather,
          pressureUnit,
          visibilityUnit,
          visibility,
          tempUnit,
          colorScheme,
        );
      case 2:
        return _buildWindTab(weather, speedUnit, colorScheme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildCurrentWeatherTab(
    dynamic weather,
    String tempUnit,
    DateFormat timeFormatter,
    DateTime sunriseTime,
    DateTime sunsetTime,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _buildWeatherInfoCard(
            'Temperature',
            '${weather.temperature.toStringAsFixed(1)}$tempUnit',
            Icons.device_thermostat,
            colorScheme),
        const SizedBox(height: 12),
        _buildWeatherInfoCard(
            'Feels Like',
            '${weather.feelsLike.toStringAsFixed(1)}$tempUnit',
            Icons.sentiment_satisfied_outlined,
            colorScheme),
        const SizedBox(height: 12),
        _buildWeatherInfoCard('Sunrise', timeFormatter.format(sunriseTime),
            Icons.wb_sunny, colorScheme),
        const SizedBox(height: 12),
        _buildWeatherInfoCard('Sunset', timeFormatter.format(sunsetTime),
            Icons.nights_stay, colorScheme),
        const SizedBox(height: 12),
        _buildWeatherInfoCard(
            'Condition', weather.weatherMain, Icons.cloud, colorScheme),
        if (weather.dewPoint != null) ...[
          const SizedBox(height: 12),
          _buildWeatherInfoCard(
              'Dew Point',
              '${weather.dewPoint?.toStringAsFixed(1)}°C',
              Icons.water_drop_outlined,
              colorScheme),
        ],
      ],
    );
  }

  Widget _buildAtmosphereTab(
    dynamic weather,
    String pressureUnit,
    String visibilityUnit,
    String visibility,
    String tempUnit,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _buildWeatherInfoCard(
            'Humidity', '${weather.humidity}%', Icons.opacity, colorScheme),
        const SizedBox(height: 12),
        _buildWeatherInfoCard('Pressure', '${weather.pressure} $pressureUnit',
            Icons.speed, colorScheme),
        const SizedBox(height: 12),
        _buildWeatherInfoCard('Visibility', '$visibility $visibilityUnit',
            Icons.visibility, colorScheme),
        const SizedBox(height: 12),
        _buildWeatherInfoCard('Cloud Coverage', '${weather.cloudiness}%',
            Icons.cloud, colorScheme),
      ],
    );
  }

  Widget _buildWindTab(
      dynamic weather, String speedUnit, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildWeatherInfoCard(
            'Wind Speed',
            '${weather.windSpeed.toStringAsFixed(1)} $speedUnit',
            Icons.air,
            colorScheme),
        if (weather.windGust != null) ...[
          const SizedBox(height: 12),
          _buildWeatherInfoCard(
              'Wind Gust',
              '${weather.windGust?.toStringAsFixed(1)} $speedUnit',
              Icons.storm,
              colorScheme),
        ],
        if (weather.windDegree != null) ...[
          const SizedBox(height: 12),
          _buildWeatherInfoCard('Wind Direction', '${weather.windDegree}°',
              Icons.compass_calibration, colorScheme),
        ],
      ],
    );
  }

  Widget _buildWeatherInfoCard(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get gradient based on weather condition
  LinearGradient _getWeatherGradient(
      String condition, ColorScheme colorScheme) {
    final conditionLower = condition.toLowerCase();

    if (conditionLower.contains('clear') || conditionLower.contains('sunny')) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFA726).withOpacity(0.9),
          const Color(0xFFFF7043).withOpacity(0.8),
        ],
      );
    } else if (conditionLower.contains('rain')) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF42A5F5).withOpacity(0.9),
          const Color(0xFF1E88E5).withOpacity(0.8),
        ],
      );
    } else if (conditionLower.contains('cloud')) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFB0BEC5).withOpacity(0.9),
          const Color(0xFF78909C).withOpacity(0.8),
        ],
      );
    } else if (conditionLower.contains('snow')) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFE0F7FA).withOpacity(0.9),
          const Color(0xFFB3E5FC).withOpacity(0.8),
        ],
      );
    } else if (conditionLower.contains('storm') ||
        conditionLower.contains('thunder')) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF455A64).withOpacity(0.9),
          const Color(0xFF263238).withOpacity(0.8),
        ],
      );
    }

    // Default gradient
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primary.withOpacity(0.8),
        colorScheme.primaryContainer.withOpacity(0.6),
      ],
    );
  }
}
