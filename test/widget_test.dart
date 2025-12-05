// This is a basic Flutter widget test for the Weather App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('Weather App loads and displays navigation bar',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: WeatherApp(),
      ),
    );

    // Verify that the navigation bar exists
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify that all three navigation destinations are present
    expect(find.byType(NavigationDestination), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify that the home screen is initially displayed
    expect(find.text('Weather Search'), findsOneWidget);
  });

  testWidgets('Navigation works correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: WeatherApp(),
      ),
    );

    // Tap on Favorites tab
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    // Verify Favorites screen is displayed
    expect(find.text('Favorite Cities'), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify Settings screen is displayed
    expect(find.text('Temperature Unit'), findsOneWidget);

    // Tap back to Home
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Verify Home screen is displayed
    expect(find.text('Weather Search'), findsOneWidget);
  });
}
