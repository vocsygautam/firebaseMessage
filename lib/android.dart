import 'package:flutter/material.dart';

class AndroidScreen extends StatelessWidget {
  const AndroidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Android'),
      ),
    );
  }
}

class IOSScreen extends StatelessWidget {
  const IOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: const Text('IOS'),
      ),
    );
  }
}
class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text('Other'),
      ),
    );
  }
}
