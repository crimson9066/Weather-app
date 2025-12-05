import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_providers.dart';
import '../services/geocoding_service.dart';
import 'weather_details_screen.dart';

/// Home/Search Screen - Main screen for searching weather by city
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController _searchController;
  List<CitySuggestion> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isLoading = false;
      });
      return;
    }

    // Show loading state and fetch suggestions immediately
    setState(() => _isLoading = true);
    _fetchSuggestions(query);
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final suggestions = await GeocodingService.getCitySuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => _buildContent(context, ref),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Search'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section with autocomplete
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Weather',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by city name...',
                          prefixIcon: Icon(Icons.location_on_outlined,
                              color: colorScheme.primary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close,
                                      color: colorScheme.primary),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _suggestions = [];
                                      _showSuggestions = false;
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        onSubmitted: (cityName) {
                          if (cityName.isNotEmpty) {
                            _selectCity(cityName, ref);
                          }
                        },
                      ),
                      // Autocomplete dropdown
                      if (_showSuggestions && _suggestions.isNotEmpty)
                        Positioned(
                          top: 56,
                          left: 0,
                          right: 0,
                          child: Material(
                            elevation: 8,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              constraints: const BoxConstraints(
                                maxHeight: 300,
                              ),
                              child: _isLoading
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: SizedBox(
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _suggestions.length,
                                      itemBuilder: (context, index) {
                                        final suggestion = _suggestions[index];
                                        return ListTile(
                                          leading: Icon(Icons.location_city,
                                              size: 18,
                                              color: colorScheme.primary),
                                          title: Text(suggestion.name),
                                          subtitle: Text(suggestion.country),
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                          onTap: () {
                                            _searchController.text =
                                                suggestion.name;
                                            setState(() {
                                              _showSuggestions = false;
                                              _suggestions = [];
                                            });
                                            _selectCity(suggestion.name, ref);
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      // Loading indicator or error message
                      if (_isLoading && _suggestions.isEmpty)
                        Positioned(
                          top: 56,
                          left: 0,
                          right: 0,
                          child: Material(
                            elevation: 8,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: SizedBox(
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search History section
            if (searchHistory.hasValue && searchHistory.value!.isNotEmpty) ...[
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searchHistory.value!.take(8).map((city) {
                  return InputChip(
                    label: Text(city),
                    onPressed: () => _selectCity(city, ref),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () async {
                      // Remove from search history
                      final storage = ref.read(storageServiceProvider);
                      await storage.removeFromSearchHistory(city);
                      ref.invalidate(searchHistoryProvider);
                    },
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  );
                }).toList(),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 72,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start searching for weather',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type a city name to get started',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outlineVariant,
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

  /// Select a city and navigate to details
  void _selectCity(String cityName, WidgetRef ref) async {
    final storage = ref.read(storageServiceProvider);

    // Extract just the city name if it's a full displayName (e.g., "New York, US" -> "New York")
    final actualCityName =
        cityName.contains(',') ? cityName.split(',').first.trim() : cityName;

    await storage.addToSearchHistory(actualCityName);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WeatherDetailsScreen(cityName: actualCityName),
        ),
      );
    }
  }
}
