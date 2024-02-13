import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_message_demo/firebase_options.dart';
import 'package:firebase_message_demo/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Noti.setupFlutterNotifications();

  FirebaseMessaging.onBackgroundMessage(Noti.firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    print('Handling a foreground message ${event.data}');
    Noti.showFlutterNotification(event);
  });
  FirebaseMessaging.instance.getToken().then((value) {
    print('hello fcm token $value');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
