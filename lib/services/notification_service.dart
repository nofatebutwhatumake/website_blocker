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