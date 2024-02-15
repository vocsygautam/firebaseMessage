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

  await Noti.setupFlutterNotifications();

  /// Android Background Listener
  FirebaseMessaging.onBackgroundMessage(Noti.firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    print('Handling a foreground message ${event.data}');
    Noti.showFlutterNotification(event);
  });
  // if (Platform.isAndroid) {
  FirebaseMessaging.instance.getToken().then((value) {
    print('Hello FCM Token ::: $value');
    FirebaseFirestore.instance.collection('app').doc(Platform.operatingSystem).set({"token": value});
  });

  /// IOS Background Listener
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle notification click event
    print('----------Notification clicked!----------');
    if (message.data['type'] == 'Send') {
      Get.to(() => const IOSScreen());
    } else {
      Get.to(() => const OtherScreen());
    }
    // Navigate to the desired screen
    // Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
  });

  //} else {
  //   FirebaseMessaging.instance.getAPNSToken().then((value) {
  //     print('hello fcm token $value');
  //   });
  // }
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Noti.notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      Noti.selectedNotificationPayload = Noti.notificationAppLaunchDetails!.notificationResponse?.payload;
      FirebaseFirestore.instance.collection('app').doc('payload').set({"notificationAppLaunchDetails":Noti.notificationAppLaunchDetails.toString(),"data": Noti.selectedNotificationPayload, "platform": Platform.operatingSystem});

      final str = jsonDecode(Noti.selectedNotificationPayload!);
      print('str----${str}');
      print('operating-------${Platform.operatingSystem}');
      FirebaseFirestore.instance.collection('app').doc('other').set({"data": str, "platform": Platform.operatingSystem});

      if (str['type'] == 'Send') {
        Get.to(() => const IOSScreen());
      } else {
        Get.to(() => const OtherScreen());
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Push Notification',
            ),
            Text('$_counter'),
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
