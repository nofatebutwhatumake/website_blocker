// lib/services/vpn_service.dart (updated)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/providers/blocker_provider.dart';
import 'package:website_blocker/services/notification_service.dart';
import 'package:website_blocker/services/vpn_connector.dart';
import 'package:permission_handler/permission_handler.dart';

class VpnService {
  static Future<void> startVpn(BuildContext context) async {
    final blockerProvider = Provider.of<BlockerProvider>(context, listen: false);
    
    // Request VPN permission
    var status = await Permission.notification.request();
    if (!status.isGranted) {
      return;
    }
    
    // Start the VPN service with blocked domains
    bool success = await VpnConnector.startVpnService(
      blockerProvider.blockedWebsites,
    );
    
    if (success) {
      blockerProvider.setVpnActive(true);
      NotificationService().showVpnServiceNotification();
    }
  }
  
  static Future<void> stopVpn(BuildContext context) async {
    final blockerProvider = Provider.of<BlockerProvider>(context, listen: false);
    
    bool success = await VpnConnector.stopVpnService();
    
    if (success) {
      blockerProvider.setVpnActive(false);
      NotificationService().cancelVpnServiceNotification();
    }
  }
  
  static Future<void> updateBlockedDomains(BuildContext context) async {
    final blockerProvider = Provider.of<BlockerProvider>(context, listen: false);
    
    if (blockerProvider.isVpnActive) {
      await VpnConnector.updateBlockedDomains(
        blockerProvider.blockedWebsites,
      );
    }
  }
  
  static bool shouldBlockUrl(String url, BlockerProvider provider) {
    return provider.isVpnActive && provider.isWebsiteBlocked(url);
  }
  
  static bool shouldBlockContent(String content, BlockerProvider provider) {
    return provider.isVpnActive && provider.containsBlockedKeyword(content);
  }
}