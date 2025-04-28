import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/providers/blocker_provider.dart';
import 'package:website_blocker/screens/home_screen.dart';

void main() {
  late BlockerProvider provider;

  setUp(() {
    provider = BlockerProvider();
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('Initial state displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Content Blocker'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
      expect(find.byIcon(Icons.text_fields), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Navigation between tabs works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.block));
      await tester.pumpAndSettle();
      expect(find.text('Add Website to Block'), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('Add Website to Block'), findsOneWidget);
    });

    testWidgets('Safe Browser button opens WebBrowserScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.public));
      await tester.pumpAndSettle();
      expect(find.text('Safe Browser'), findsOneWidget);
    });

    testWidgets('VPN toggle updates provider state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(provider.isVpnActive, isTrue);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(provider.isVpnActive, isFalse);
    });

    testWidgets('Stats display correctly', (WidgetTester tester) async {
      provider.addBlockedWebsite('example.com');
      provider.addBlockedKeyword('test');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('1 websites blocked'), findsOneWidget);
      expect(find.text('1 keywords blocked'), findsOneWidget);
    });
  });
} 