import 'dart:async';
import 'dart:convert';
import 'package:firebase_message_demo/android.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class Noti {
  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();
  static final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();

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

   static NotificationAppLaunchDetails? notificationAppLaunchDetails;
  static String? selectedNotificationPayload;
  static Future<void> setupFlutterNotifications() async {


    notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse?.payload;
    }
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        defaultPresentSound: true,
        requestSoundPermission: true,
        defaultPresentAlert: false,
        defaultPresentBadge: false,
        defaultPresentBanner: false,
        defaultPresentList: false,
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestCriticalPermission: false,
        requestProvisionalPermission: false);
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin),
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

    /// Create an IOS Notification Channel.
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    configureSelectNotificationSubject();
  }

  /// IOS Receive Notification
  static void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    print('print--------');
    didReceiveLocalNotificationStream.add(
      ReceivedNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }

  static void configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      final json = jsonDecode(payload!);
      print('hello click event $json');
      print('hello click event type ${json['type']}');
      if (json['type'] == 'Send') {
        Get.to(() => AndroidScreen());
      } else {
        Get.to(() => OtherScreen());
      }
    });
    didReceiveLocalNotificationStream.stream.listen((ReceivedNotification value) async {
      print('hello click event 000${value.toString()}');
      final json = jsonDecode(value.payload!);
      print('hello click event $json');
      print('hello click event type ${json['type']}');
    });
  }

  static Future<void> showFlutterNotification(RemoteMessage message) async {
    if (message.notification != null) {
      final msg = message.notification!.toMap();
      await flutterLocalNotificationsPlugin.show(
        message.messageId.hashCode,
        msg['title'],
        msg['body'],
        payload: jsonEncode(message.data),
        NotificationDetails(
          iOS: const DarwinNotificationDetails(),
          android: AndroidNotificationDetails(channel.id, channel.name, icon: "@mipmap/launcher_icon"),
        ),
      );
    }
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
