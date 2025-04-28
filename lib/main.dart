// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/screens/home_screen.dart';
import 'package:website_blocker/providers/blocker_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BlockerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Website Blocker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// lib/providers/blocker_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockerProvider with ChangeNotifier {
  List<String> _blockedWebsites = [];
  List<String> _blockedKeywords = [];
  bool _isVpnActive = false;
  String _customBlockMessage = "This content has been blocked";
  
  List<String> get blockedWebsites => _blockedWebsites;
  List<String> get blockedKeywords => _blockedKeywords;
  bool get isVpnActive => _isVpnActive;
  String get customBlockMessage => _customBlockMessage;

  BlockerProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _blockedWebsites = prefs.getStringList('blockedWebsites') ?? [];
    _blockedKeywords = prefs.getStringList('blockedKeywords') ?? [];
    _isVpnActive = prefs.getBool('isVpnActive') ?? false;
    _customBlockMessage = prefs.getString('customBlockMessage') ?? "This content has been blocked";
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blockedWebsites', _blockedWebsites);
    await prefs.setStringList('blockedKeywords', _blockedKeywords);
    await prefs.setBool('isVpnActive', _isVpnActive);
    await prefs.setString('customBlockMessage', _customBlockMessage);
  }

  void addBlockedWebsite(String website) {
    if (!_blockedWebsites.contains(website) && website.isNotEmpty) {
      _blockedWebsites.add(website);
      _saveSettings();
      notifyListeners();
    }
  }

  void removeBlockedWebsite(String website) {
    _blockedWebsites.remove(website);
    _saveSettings();
    notifyListeners();
  }

  void addBlockedKeyword(String keyword) {
    if (!_blockedKeywords.contains(keyword) && keyword.isNotEmpty) {
      _blockedKeywords.add(keyword);
      _saveSettings();
      notifyListeners();
    }
  }

  void removeBlockedKeyword(String keyword) {
    _blockedKeywords.remove(keyword);
    _saveSettings();
    notifyListeners();
  }

  void setVpnActive(bool isActive) {
    _isVpnActive = isActive;
    _saveSettings();
    notifyListeners();
  }

  void setCustomBlockMessage(String message) {
    if (message.isNotEmpty) {
      _customBlockMessage = message;
      _saveSettings();
      notifyListeners();
    }
  }

  bool isWebsiteBlocked(String url) {
    return _blockedWebsites.any((website) => url.contains(website));
  }

  bool containsBlockedKeyword(String content) {
    return _blockedKeywords.any((keyword) => 
      content.toLowerCase().contains(keyword.toLowerCase()));
  }
}

// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  NotificationService._internal();
  
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
    const InitializationSettings initializationSettings = 
      InitializationSettings(android: initializationSettingsAndroid);
      
    await _notificationsPlugin.initialize(initializationSettings);
  }
  
  Future<void> showVpnServiceNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'website_blocker_vpn_service',
      'Website Blocker VPN Service',
      channelDescription: 'Notification for the VPN service',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
    );
    
    const NotificationDetails notificationDetails = 
      NotificationDetails(android: androidDetails);
      
    await _notificationsPlugin.show(
      1,
      'Website Blocker is Active',
      'Monitoring and blocking unwanted content',
      notificationDetails,
    );
  }
  
  Future<void> cancelVpnServiceNotification() async {
    await _notificationsPlugin.cancel(1);
  }
}