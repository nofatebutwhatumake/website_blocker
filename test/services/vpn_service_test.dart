import 'package:flutter_test/flutter_test.dart';
import 'package:website_blocker/providers/blocker_provider.dart';
import 'package:website_blocker/services/vpn_service.dart';

void main() {
  late BlockerProvider provider;

  setUp(() {
    provider = BlockerProvider();
  });

  group('VpnService Tests', () {
    test('Should block URL when VPN is active and website is blocked', () {
      provider.setVpnActive(true);
      provider.addBlockedWebsite('example.com');
      
      expect(
        VpnService.shouldBlockUrl('https://example.com/page', provider),
        isTrue,
      );
    });

    test('Should not block URL when VPN is inactive', () {
      provider.setVpnActive(false);
      provider.addBlockedWebsite('example.com');
      
      expect(
        VpnService.shouldBlockUrl('https://example.com/page', provider),
        isFalse,
      );
    });

    test('Should not block URL when website is not blocked', () {
      provider.setVpnActive(true);
      provider.addBlockedWebsite('example.com');
      
      expect(
        VpnService.shouldBlockUrl('https://other.com/page', provider),
        isFalse,
      );
    });

    test('Should block content when VPN is active and contains blocked keyword', () {
      provider.setVpnActive(true);
      provider.addBlockedKeyword('test');
      
      expect(
        VpnService.shouldBlockContent('This is a test message', provider),
        isTrue,
      );
    });

    test('Should not block content when VPN is inactive', () {
      provider.setVpnActive(false);
      provider.addBlockedKeyword('test');
      
      expect(
        VpnService.shouldBlockContent('This is a test message', provider),
        isFalse,
      );
    });

    test('Should not block content when no blocked keywords match', () {
      provider.setVpnActive(true);
      provider.addBlockedKeyword('test');
      
      expect(
        VpnService.shouldBlockContent('No blocked words here', provider),
        isFalse,
      );
    });

    test('Case insensitive keyword matching', () {
      provider.setVpnActive(true);
      provider.addBlockedKeyword('TEST');
      
      expect(
        VpnService.shouldBlockContent('This is a test message', provider),
        isTrue,
      );
    });

    test('Multiple blocked websites', () {
      provider.setVpnActive(true);
      provider.addBlockedWebsite('example.com');
      provider.addBlockedWebsite('test.com');
      
      expect(
        VpnService.shouldBlockUrl('https://example.com/page', provider),
        isTrue,
      );
      expect(
        VpnService.shouldBlockUrl('https://test.com/page', provider),
        isTrue,
      );
      expect(
        VpnService.shouldBlockUrl('https://other.com/page', provider),
        isFalse,
      );
    });

    test('Multiple blocked keywords', () {
      provider.setVpnActive(true);
      provider.addBlockedKeyword('test');
      provider.addBlockedKeyword('block');
      
      expect(
        VpnService.shouldBlockContent('This is a test message', provider),
        isTrue,
      );
      expect(
        VpnService.shouldBlockContent('This should be blocked', provider),
        isTrue,
      );
      expect(
        VpnService.shouldBlockContent('No blocked words here', provider),
        isFalse,
      );
    });
  });
} 