import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/providers/blocker_provider.dart';
import 'package:website_blocker/screens/web_browser_screen.dart';

void main() {
  late BlockerProvider provider;

  setUp(() {
    provider = BlockerProvider();
  });

  group('WebBrowserScreen Widget Tests', () {
    testWidgets('Initial state displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const WebBrowserScreen(
              initialUrl: 'https://example.com',
            ),
          ),
        ),
      );

      expect(find.text('Safe Browser'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Refresh button is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const WebBrowserScreen(
              initialUrl: 'https://example.com',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Loading indicator shows during page load',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const WebBrowserScreen(
              initialUrl: 'https://example.com',
            ),
          ),
        ),
      );

      // The loading indicator should be visible initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('WebView is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const WebBrowserScreen(
              initialUrl: 'https://example.com',
            ),
          ),
        ),
      );

      expect(find.byType(WebViewWidget), findsOneWidget);
    });

    testWidgets('Blocked website shows block message', (WidgetTester tester) async {
      provider.setVpnActive(true);
      provider.addBlockedWebsite('example.com');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const WebBrowserScreen(
              initialUrl: 'https://example.com',
            ),
          ),
        ),
      );

      // The WebView should be blocked
      expect(find.text('This content has been blocked'), findsOneWidget);
    });

    testWidgets('Custom block message is displayed', (WidgetTester tester) async {
      provider.setVpnActive(true);
      provider.addBlockedWebsite('example.com');
      provider.setCustomBlockMessage('Custom block message');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const WebBrowserScreen(
              initialUrl: 'https://example.com',
            ),
          ),
        ),
      );

      expect(find.text('Custom block message'), findsOneWidget);
    });
  });
} 