// lib/services/vpn_connector.dart
import 'dart:async';
import 'package:flutter/services.dart';

class VpnConnector {
  static const MethodChannel _channel = MethodChannel('com.example.website_blocker/vpn');
  
  static Future<bool> startVpnService(List<String> blockedDomains) async {
    try {
      final bool success = await _channel.invokeMethod('startVpn', {
        'blockedDomains': blockedDomains,
      });
      return success;
    } on PlatformException catch (e) {
      print('Failed to start VPN service: ${e.message}');
      return false;
    }
  }
  
  static Future<bool> stopVpnService() async {
    try {
      final bool success = await _channel.invokeMethod('stopVpn');
      return success;
    } on PlatformException catch (e) {
      print('Failed to stop VPN service: ${e.message}');
      return false;
    }
  }
  
  static Future<bool> updateBlockedDomains(List<String> blockedDomains) async {
    try {
      final bool success = await _channel.invokeMethod('updateBlockedDomains', {
        'blockedDomains': blockedDomains,
      });
      return success;
    } on PlatformException catch (e) {
      print('Failed to update blocked domains: ${e.message}');
      return false;
    }
  }
}