import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_providers.dart';
import '../widgets/reusable_widgets.dart' as weather_widgets;
import 'weather_details_screen.dart';

/// Favorites Screen - Display list of saved favorite cities
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

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
            padding: const EdgeInsets.all(8),
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
                onRemove: () async {
                  final storage = ref.read(storageServiceProvider);
                  await storage.removeFavorite(cityName);
                  ref.invalidate(favoriteCitiesProvider);
                },
              );
            },
          );
        },
        loading: () => const weather_widgets.LoadingWidget(message: 'Loading favorites...'),
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

/// Card widget for displaying favorite cities
class FavoriteCard extends ConsumerWidget {
  final String cityName;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteCard({
    Key? key,
    required this.cityName,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(cityName));
    final unit = ref.watch(temperatureUnitProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: weatherAsync.when(
          data: (weather) => Image.network(
            weather.iconUrl,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.cloud),
          ),
          loading: () => const SizedBox(
            width: 40,
            height: 40,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => const Icon(Icons.cloud_off),
        ),
        title: Text(cityName),
        subtitle: weatherAsync.when(
          data: (weather) {
            final tempUnit = unit == 'metric' ? '°C' : '°F';
            return Text(
              '${weather.temperature.toStringAsFixed(1)}$tempUnit - ${weather.description}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
          loading: () => const Text('Loading...'),
          error: (error, _) => Text('Error: $error'),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
