import 'package:flutter_test/flutter_test.dart';
import 'package:website_blocker/providers/blocker_provider.dart';

void main() {
  late BlockerProvider provider;

  setUp(() {
    provider = BlockerProvider();
  });

  group('BlockerProvider Tests', () {
    test('Initial state is correct', () {
      expect(provider.blockedWebsites, isEmpty);
      expect(provider.blockedKeywords, isEmpty);
      expect(provider.isVpnActive, isFalse);
      expect(provider.customBlockMessage, equals('This content has been blocked'));
    });

    test('Add and remove blocked website', () {
      provider.addBlockedWebsite('example.com');
      expect(provider.blockedWebsites, contains('example.com'));
      
      provider.removeBlockedWebsite('example.com');
      expect(provider.blockedWebsites, isNot(contains('example.com')));
    });

    test('Add and remove blocked keyword', () {
      provider.addBlockedKeyword('test');
      expect(provider.blockedKeywords, contains('test'));
      
      provider.removeBlockedKeyword('test');
      expect(provider.blockedKeywords, isNot(contains('test')));
    });

    test('Set VPN active state', () {
      provider.setVpnActive(true);
      expect(provider.isVpnActive, isTrue);
      
      provider.setVpnActive(false);
      expect(provider.isVpnActive, isFalse);
    });

    test('Set custom block message', () {
      const message = 'Custom block message';
      provider.setCustomBlockMessage(message);
      expect(provider.customBlockMessage, equals(message));
    });

    test('Check website blocking', () {
      provider.addBlockedWebsite('example.com');
      expect(provider.isWebsiteBlocked('https://example.com/page'), isTrue);
      expect(provider.isWebsiteBlocked('https://other.com'), isFalse);
    });

    test('Check keyword blocking', () {
      provider.addBlockedKeyword('test');
      expect(provider.containsBlockedKeyword('This is a test message'), isTrue);
      expect(provider.containsBlockedKeyword('No blocked words here'), isFalse);
    });

    test('Prevent duplicate websites', () {
      provider.addBlockedWebsite('example.com');
      provider.addBlockedWebsite('example.com');
      expect(provider.blockedWebsites.length, equals(1));
    });

    test('Prevent duplicate keywords', () {
      provider.addBlockedKeyword('test');
      provider.addBlockedKeyword('test');
      expect(provider.blockedKeywords.length, equals(1));
    });

    test('Prevent empty website', () {
      provider.addBlockedWebsite('');
      expect(provider.blockedWebsites, isEmpty);
    });

    test('Prevent empty keyword', () {
      provider.addBlockedKeyword('');
      expect(provider.blockedKeywords, isEmpty);
    });
  });
} 