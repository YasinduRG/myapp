import 'package:flutter/material.dart';
import 'package:myapp/services/notification_services.dart';


class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notifications'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            NotificationService.showNotification(
              title: 'Test Notification',
              body: 'This is a test local notification!',
            );
          },
          child: const Text('Show Notification'),
        ),
      ),
    );
  }
}