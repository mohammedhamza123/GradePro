import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  late GlobalKey<NavigatorState> navigatorKey;

  static String? fcmToken;

  bool _isFlutterLocalNotificationsInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    this.navigatorKey = navigatorKey;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _setupFlutterLocalNotifications();
    await _setupMessageHandlers();

    fcmToken = await _messaging.getToken();
    _initCompleter.complete();
  }

  /// Request user notification permissions
  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Background message handler (DO NOT use FlutterLocalNotifications here)
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();

    // TODO: Only log or store messages; don't show notifications directly.
    print("Received background message: ${message.messageId}");
  }

  /// Initializes local notification plugin and Android channel
  Future<void> _setupFlutterLocalNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'shefa_notification_channel', // Channel ID
      'Shefa Notifications', // Channel name
      description: "Channel for app notifications",
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        //handle user tapping on notification when app is in foreground
        final payload = details.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload);
            final message =
                RemoteMessage(data: Map<String, dynamic>.from(data));
            _handleMessageNavigation(message);
          } catch (e) {
            print("Invalid payload format: $e");
          }
        }
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  /// Handle foreground, background, and terminated message events
  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) async {
      print("Foreground message: ${message.messageId}");
      await showNotification(message);
      // final chatProvider = Provider.of<ChatProvider>(
      //   navigatorKey.currentState!.context,
      //   listen: false,
      // );

      // try {
      //   // Parse and add the message to the provider
      //   // chatProvider.addMessageForeground(message.data);

      //   // Optionally show a notification if the user is not on ChatPage
      //   final currentRoute = ModalRoute.of(navigatorKey.currentState!.context);
      //   if (currentRoute?.settings.name != '/ChatPage') {
      //     await showNotification(message);
      //   }
      // } catch (e) {
      //   print("Error handling foreground message: $e");
      // }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("App opened via notification: ${message.messageId}");
      _handleMessageNavigation(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print("App launched via notification: ${initialMessage.messageId}");
      _handleMessageNavigation(initialMessage);
    }
  }

  /// Displays a local notification while app is in foreground
  Future<void> showNotification(RemoteMessage message) async {
    await _initCompleter.future;

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'shefa_notification_channel',
          'Shefa Notifications',
          channelDescription: 'Channel for app notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(message.data), // optional
      );
    }
  }

  /// Handle user navigation based on message data
  void _handleMessageNavigation(RemoteMessage message) {
    final type = message.data['type'];

    if (type == 'chat') {
      // _navigateToPage(
      //     ChatPage(conversation: message.data["conversation_id"]), null);
    } else if (type == 'order') {
      // _navigateToPage(
      //   null,
      //   '/Order',
      // );
    } else {
      print("Unhandled message type: $type");
    }
  }

  /// Push a page to the current navigator
  void _navigateToPage(Widget? page, String? route) {
    if (page != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => page),
      );
    }
    if (route != null) {
      navigatorKey.currentState?.pushNamed(route);
    }
  }
}
