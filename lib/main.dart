import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_message_demo/android.dart';
import 'package:firebase_message_demo/firebase_options.dart';
import 'package:firebase_message_demo/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// ANDROID BACKGROUND LISTENER
  FirebaseMessaging.onBackgroundMessage(Noti.firebaseMessagingBackgroundHandler);

  /// INITIALIZE
  await Noti.setupFlutterNotifications();

  /// HANDLING A FOREGROUND MESSAGE CLICK EVENT
  FirebaseMessaging.onMessage.listen(Noti.showFlutterNotification);
  FirebaseMessaging.instance.getToken().then((value) {
    print('HELLO FCM TOKEN ::: $value');
    FirebaseFirestore.instance.collection('app').doc(Platform.operatingSystem).set({"token": value});
  });

  /// BACKGROUND CLICK LISTENER
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle notification click event
    FirebaseFirestore.instance.collection('app').doc('other').set({"data": 'ios app killed', "platform": Platform.operatingSystem});
    if (message.data['type'] == 'Send') {
      if (message.data['platform'] == 'ios') {
        Get.to(() => const IOSScreen());
      } else {
        Get.to(() => const AndroidScreen());
      }
    } else {
      Get.to(() => const OtherScreen());
    }
  });

  runApp(const MyApp());
}

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {}

  @override
  Widget build(BuildContext context) {
    if (Noti.notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      Noti.selectedNotificationPayload = Noti.notificationAppLaunchDetails!.notificationResponse?.payload;
      FirebaseFirestore.instance
          .collection('app')
          .doc('payload')
          .set({"notificationAppLaunchDetails": Noti.notificationAppLaunchDetails.toString(), "data": Noti.selectedNotificationPayload, "platform": Platform.operatingSystem});
      final str = jsonDecode(Noti.selectedNotificationPayload!);
      FirebaseFirestore.instance.collection('app').doc('other').set({"data": str, "platform": Platform.operatingSystem});

      if (str['type'] == 'Send') {
        Get.to(() => const AndroidScreen());
      } else {
        Get.to(() => const OtherScreen());
      }
    } else {
      FirebaseMessaging.instance.getInitialMessage().then((value) {
        if (value != null) {
          if (value.data['type'] == 'Send') {
            Get.to(() => const IOSScreen());
          } else {
            Get.to(() => const OtherScreen());
          }
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Push Notification',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.notifications),
      ),
    );
  }
}
