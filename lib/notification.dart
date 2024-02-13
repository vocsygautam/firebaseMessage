import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Noti {
  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message ${message.data}');
    showFlutterNotification(message);
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  static Future<void> setupFlutterNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (details) {
        selectNotificationStream.add(details.payload);
      },
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    configureSelectNotificationSubject();
  }

  static void configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      final json = jsonDecode(payload!);
      print('hello click event $json');
      print('hello click event type ${json['type']}');
    });
  }

  static Future<void> showFlutterNotification(RemoteMessage message) async {
    final msg = message.data;
    if (msg.isNotEmpty) {
      await flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        msg['Title'],
        msg['body'],
        payload: jsonEncode(msg),
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,icon: "@mipmap/launcher_icon"),
        ),
      );
    }
  }
}
