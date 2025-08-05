// lib/test_page.dart

import 'package:flutter/material.dart';
import 'package:myapp/services/notification_services.dart'; // Adjust path if needed

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notifications'),
      ),
      body: Center(
        // Use a Column to hold multiple buttons
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NotificationService.showNotification(
                  title: 'Instant Notification',
                  body: 'This is a test local notification!',
                );
              },
              child: const Text('Show Instant Notification'),
            ),
            const SizedBox(height: 20), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                // Call the new scheduled notification method
                NotificationService.showScheduledNotification(
                  title: 'Scheduled Notification',
                  body: 'This notification was scheduled 1 minute ago!',
                );
                // Give user feedback that something happened
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification scheduled for 5s from now!'),
                  ),
                );
              },
              child: const Text('Schedule Notification (1 Min)'),
            ),
          ],
        ),
      ),
    );
  }
}