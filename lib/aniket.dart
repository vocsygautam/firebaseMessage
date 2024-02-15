
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'main.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // description
    importance: Importance.max);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);



  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  firebaseMessaging.getToken().then((token) {
    print("Token ----- $token");
  });

  /// app foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: android.smallIcon,
            ),
          ));
    }
  });

  // FirebaseMessaging.onBackgroundMessage(onbackground);

  /// app background
//   FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
//     print('onBackgroundMessage call-----------');
// AndroidNotification? android = message.notification?.android;
//     if (message.notification != null && android != null) {
//       print('onBackgroundMessage call if ********-----------');
//       final msg = message.notification!.toMap();
//       await flutterLocalNotificationsPlugin.show(
//         message.messageId.hashCode,
//         msg['title'],
//         msg['body'],
//         payload: jsonEncode(message.data),
//         NotificationDetails(
//           iOS: const DarwinNotificationDetails(),
//           android: AndroidNotificationDetails(channel.id, channel.name, icon: "@mipmap/launcher_icon"),
//         ),
//       );
//     }
//   });
  runApp(const MyApp());
}


// @pragma('vm:entry-point')
// Future<void> onbackground (RemoteMessage message) async {
//   print('onBackgroundMessage call-----------');
//   AndroidNotification? android = message.notification?.android;
//   if (message.notification != null && android != null) {
//     print('onBackgroundMessage call if ********-----------');
//     final msg = message.notification!.toMap();
//     await flutterLocalNotificationsPlugin.show(
//       message.messageId.hashCode,
//       msg['title'],
//       msg['body'],
//       payload: jsonEncode(message.data),
//       NotificationDetails(
//         iOS: const DarwinNotificationDetails(),
//         android: AndroidNotificationDetails(channel.id, channel.name, icon: "@mipmap/launcher_icon"),
//       ),
//     );
//   }
// }

void onDidReceiveLocalNotification(id, title, body, payload) {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      title: 'Flutter',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}
