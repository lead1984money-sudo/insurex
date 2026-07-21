import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'navigator_service.dart'; // adjust path

/// A singleton service that manages FCM and local notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  final NavigationService _navigationService = NavigationService();

  // Stream for handling notification taps (used internally)
  final StreamController<NotificationResponse> _onNotificationTapController =
  StreamController<NotificationResponse>.broadcast();

  /// Call this once in main() after Firebase.initializeApp()
  Future<void> init() async {
    await _requestPermissions();
    await _initLocalNotifications();
    await _registerFCMHandlers();
    await _storeFCMToken();
    await _handleInitialMessage();
    _listenToNotificationTaps();
  }

  // ---------------------------
  // Permission & Initialization
  // ---------------------------

  Future<void> _requestPermissions() async {
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('User declined or has not granted notification permissions.');
    }

    if (Platform.isAndroid) {
      final androidImplementation =
      _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _onNotificationTapController.add(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // ---------------------------
  // FCM Handlers
  // ---------------------------

  Future<void> _registerFCMHandlers() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened from notification (background state)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Background messages – use the PUBLIC handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.data}');
    final data = message.data;
    final title = data['title'] ?? 'Insurex';
    final body = data['body'] ?? '';
    _showLocalNotification(title, body, data);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.data}');
    _navigateBasedOnPayload(message.data);
  }

  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state: ${initialMessage.data}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateBasedOnPayload(initialMessage.data);
      });
    }
  }

  Future<void> _storeFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $token');
    _fcmToken = token;
  }

  Future<String?> getFCMToken() async {
    if (_fcmToken == null) {
      _fcmToken = await FirebaseMessaging.instance.getToken();
    }
    return _fcmToken;
  }

  // ---------------------------
  // Local Notification Display
  // ---------------------------

  Future<void> _showLocalNotification(
      String title, String body, Map<String, dynamic> data) async {
    final androidDetails = AndroidNotificationDetails(
      'insurex_channel',
      'Insurex Notifications',
      channelDescription: 'Notifications from Insurex',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      math.Random().nextInt(99999),
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  // ---------------------------
  // Navigation based on payload
  // ---------------------------

  void _navigateBasedOnPayload(Map<String, dynamic> data) {
    final type = data['reference_type']; // e.g., 'meeting', 'lead', 'notification', etc.
    print("LINE179");
    print(data);
    print(type);
    switch (type) {
      case 'plan_purchased':
        _navigationService.pushNamed('/plans-manager', arguments: data);
        break;
      case 'notification':
        _navigationService.pushNamed('/notification-list', arguments: data);
        break;
      case 'transaction':
        _navigationService.pushNamed('/transaction-list', arguments: data);
        break;
    // Add more cases
      default:
      // Default navigation, e.g., to home or lead detail
        _navigationService.pushNamed('/lead-detail', arguments: data);
    }
  }

  void _handleTapPayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateBasedOnPayload(data);
    } catch (e, stack) {
      debugPrint('Invalid payload: $payload');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // ---------------------------
  // Listen to tap events from local notifications
  // ---------------------------

  void _listenToNotificationTaps() {
    _onNotificationTapController.stream.listen((response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        _handleTapPayload(payload);
      }
    });
  }

  void dispose() {
    _onNotificationTapController.close();
  }
}

// ============================================================
// PUBLIC TOP-LEVEL BACKGROUND HANDLER (no underscore)
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final FlutterLocalNotificationsPlugin localPlugin =
  FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await localPlugin.initialize(initSettings);

  final data = message.data;
  final title = data['title'] ?? 'Insurex';
  final body = data['body'] ?? '';

  final androidDetails = AndroidNotificationDetails(
    'insurex_channel',
    'Insurex Notifications',
    channelDescription: 'Background notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );
  const iosDetails = DarwinNotificationDetails();
  final details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await localPlugin.show(
    math.Random().nextInt(99999),
    title,
    body,
    details,
    payload: jsonEncode(data),
  );
}

// ============================================================
// PUBLIC BACKGROUND TAP HANDLER (already public)
// ============================================================

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('Background notification tapped: ${response.payload}');
}