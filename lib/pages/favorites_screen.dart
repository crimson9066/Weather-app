import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_providers.dart';
import '../widgets/reusable_widgets.dart' as weather_widgets;
import 'weather_details_screen.dart';

/// Favorites Screen - Display list of saved favorite cities
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteCitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cities'),
        centerTitle: true,
        elevation: 0,
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite cities yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add cities to your favorites to see them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final cityName = favorites[index];
              return FavoriteCard(
                cityName: cityName,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          WeatherDetailsScreen(cityName: cityName),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const weather_widgets.LoadingWidget(
            message: 'Loading favorites...'),
        error: (error, stackTrace) => weather_widgets.ErrorMessageWidget(
          message: 'Error loading favorites: $error',
          onRetry: () {
            ref.invalidate(favoriteCitiesProvider);
          },
        ),
      ),
    );
  }
}

/// Card widget for displaying favorite cities with animations
class FavoriteCard extends ConsumerWidget {
  final String cityName;
  final VoidCallback onTap;

  const FavoriteCard({
    super.key,
    required this.cityName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(cityName));
    final unit = ref.watch(temperatureUnitProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _getWeatherGradient(weatherAsync, colorScheme),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Weather Icon with animation
                  weatherAsync.when(
                    data: (weather) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.network(
                              weather.iconUrl,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.cloud, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                    loading: () => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                    error: (_, __) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.cloud_off, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // City info
                  Expanded(
                    child: weatherAsync.when(
                      data: (weather) {
                        final tempUnit = unit == 'metric' ? '°C' : '°F';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cityName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${weather.temperature.toStringAsFixed(1)}$tempUnit',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weather.description.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                      loading: () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cityName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      error: (error, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cityName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading weather',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Remove button
                  Consumer(
                    builder: (context, ref2, _) {
                      return IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () async {
                          final storage = ref2.read(storageServiceProvider);
                          await storage.removeFavorite(cityName);
                          ref2.invalidate(favoriteCitiesProvider);
                          ref2.invalidate(isFavoriteProvider(cityName));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get gradient based on weather condition
  LinearGradient _getWeatherGradient(
      AsyncValue<dynamic> weatherAsync, ColorScheme colorScheme) {
    if (weatherAsync.hasValue) {
      final weather = weatherAsync.value;
      final condition = weather.weatherMain.toLowerCase();

      if (condition.contains('clear') || condition.contains('sunny')) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFA726).withOpacity(0.8),
            const Color(0xFFFF7043).withOpacity(0.8),
          ],
        );
      } else if (condition.contains('rain')) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF42A5F5).withOpacity(0.8),
            const Color(0xFF1E88E5).withOpacity(0.8),
          ],
        );
      } else if (condition.contains('cloud')) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFB0BEC5).withOpacity(0.8),
            const Color(0xFF78909C).withOpacity(0.8),
          ],
        );
      } else if (condition.contains('snow')) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE0F7FA).withOpacity(0.8),
            const Color(0xFFB3E5FC).withOpacity(0.8),
          ],
        );
      } else if (condition.contains('storm') || condition.contains('thunder')) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF455A64).withOpacity(0.8),
            const Color(0xFF263238).withOpacity(0.8),
          ],
        );
      }
    }

    // Default gradient
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primary.withOpacity(0.7),
        colorScheme.primaryContainer.withOpacity(0.7),
      ],
    );
  }
}
