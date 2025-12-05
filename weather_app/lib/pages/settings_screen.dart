import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_providers.dart';

/// Settings Screen - App configuration and preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(temperatureUnitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Temperature Unit Section
            const Text(
              'Temperature Unit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  // NOTE: `groupValue` / `onChanged` are deprecated in newer
                  // Flutter SDKs. Keep behavior for now and migrate to the
                  // recommended `RadioGroup` ancestor when upgrading the SDK.
                  // ignore: deprecated_member_use
                  RadioListTile<String>(
                    title: const Text('Celsius (°C)'),
                    subtitle: const Text('Metric system'),
                    value: 'metric',
                    groupValue: unit,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(temperatureUnitProvider.notifier).state =
                            value;
                        _saveTemperatureUnit(ref, value);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  // ignore: deprecated_member_use
                  RadioListTile<String>(
                    title: const Text('Fahrenheit (°F)'),
                    subtitle: const Text('Imperial system'),
                    value: 'imperial',
                    groupValue: unit,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(temperatureUnitProvider.notifier).state =
                            value;
                        _saveTemperatureUnit(ref, value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // About Section
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weather App v1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A multi-page Flutter application that retrieves and displays real-time weather data using the OpenWeatherMap API.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Features:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Search weather by city name'),
                    _buildFeatureItem('View detailed weather information'),
                    _buildFeatureItem('Save favorite cities'),
                    _buildFeatureItem('Customize temperature units'),
                    _buildFeatureItem('View search history'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // API Information Section
            const Text(
              'API Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Source: OpenWeatherMap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weather data is provided by OpenWeatherMap API. For more information, visit: openweathermap.org',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build feature item
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(feature, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  /// Save temperature unit to storage
  void _saveTemperatureUnit(WidgetRef ref, String unit) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setTemperatureUnit(unit);
  }
}
