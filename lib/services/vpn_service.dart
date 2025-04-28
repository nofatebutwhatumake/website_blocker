// lib/services/vpn_service.dart (updated)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/providers/blocker_provider.dart';
import 'package:website_blocker/services/notification_service.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class VpnService {
  static const platform = MethodChannel('com.example.website_blocker/vpn');
  static final _notificationService = NotificationService();

  static Future<void> startVpn(BuildContext context) async {
    final blockerProvider = Provider.of<BlockerProvider>(context, listen: false);
    
    try {
      developer.log('Starting VPN service...');
      final result = await platform.invokeMethod('startVpn', {
        'blockedDomains': blockerProvider.blockedWebsites,
      });

      if (result == true) {
        developer.log('VPN service started successfully');
        blockerProvider.setVpnActive(true);
        await _notificationService.showVpnServiceNotification();
      } else {
        throw Exception('Failed to start VPN service');
      }
    } on PlatformException catch (e) {
      developer.log('Error starting VPN: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      developer.log('Unexpected error starting VPN: $e', error: e);
      rethrow;
    }
  }
  
  static Future<void> stopVpn(BuildContext context) async {
    final blockerProvider = Provider.of<BlockerProvider>(context, listen: false);
    
    try {
      developer.log('Stopping VPN service...');
      final result = await platform.invokeMethod('stopVpn');
      
      if (result == true) {
        developer.log('VPN service stopped successfully');
        blockerProvider.setVpnActive(false);
        await _notificationService.cancelVpnServiceNotification();
      } else {
        throw Exception('Failed to stop VPN service');
      }
    } on PlatformException catch (e) {
      developer.log('Error stopping VPN: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      developer.log('Unexpected error stopping VPN: $e', error: e);
      rethrow;
    }
  }
  
  static Future<void> updateBlockedDomains(BuildContext context) async {
    final blockerProvider = Provider.of<BlockerProvider>(context, listen: false);
    
    try {
      if (blockerProvider.isVpnActive) {
        developer.log('Updating blocked domains...');
        await platform.invokeMethod('updateBlockedDomains', {
          'blockedDomains': blockerProvider.blockedWebsites,
        });
        developer.log('Blocked domains updated successfully');
      }
    } on PlatformException catch (e) {
      developer.log('Error updating blocked domains: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      developer.log('Unexpected error updating blocked domains: $e', error: e);
      rethrow;
    }
  }
  
  static bool shouldBlockUrl(String url, BlockerProvider provider) {
    return provider.isVpnActive && provider.isWebsiteBlocked(url);
  }
  
  static bool shouldBlockContent(String content, BlockerProvider provider) {
    return provider.isVpnActive && provider.containsBlockedKeyword(content);
  }
}