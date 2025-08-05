// lib/test_page.dart

import 'package:flutter/material.dart';
import 'package:myapp/services/notification_services.dart';
import 'package:myapp/util/dialog_box.dart';
import 'package:myapp/util/snack_bar.dart'; // Adjust path if needed

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications & Alerts')),
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
            const SizedBox(height: 10), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                // Call the new scheduled notification method
                NotificationService.showScheduledNotification(
                  title: 'Scheduled Notification',
                  body: 'This notification was scheduled 5s ago!',
                );

                // 2. Use the common showSnackBar function for user feedback
                showSnackBar(
                  context: context,
                  message: 'Notification scheduled for 5s from now!',
                  type:
                      MessageType
                          .success, // Using 'success' for positive feedback
                );
                // Give user feedback that something happened
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(
                //     content: Text('Notification scheduled for 5s from now!'),
                //   ),
                // );
              },
              child: const Text('Schedule Notification (5 s)'),
            ),
            const SizedBox(height: 10), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                // Call the new scheduled notification method
                // 2. Use the common showSnackBar function for user feedback
                showSnackBar(
                                    context: context,

                  message: 'Test Error message',
                  type:
                      MessageType
                          .error, // Using 'success' for positive feedback
                );
              },
              child: const Text('Test Snack Error message'),
            ),
            const SizedBox(height: 10), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                // Call the new scheduled notification method
                // 2. Use the common showSnackBar function for user feedback
                showSnackBar(
                                    context: context,

                  message: 'Test Success message',
                  type:
                      MessageType
                          .success, // Using 'success' for positive feedback
                );
              },
              child: const Text('Test Snack Success message'),
            ),
            const SizedBox(height: 10), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                showSnackBar(
                                    context: context,

                  message: 'Test Warning message',
                  type:
                      MessageType
                          .warning, // Using 'success' for positive feedback
                );
              },
              child: const Text('Test Snack Warning message'),
            ),

            const SizedBox(height: 10), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                showInfoDialog(
                  context: context,
                  title: 'Payment Successful',
                  content:
                      'Your invoice has been paid and a receipt has been sent to your email.',
                );
              },
              child: const Text('Test Payment Success message'),
            ),

            const SizedBox(height: 10), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                // Call the new scheduled notification method
                // 2. Use the common showSnackBar function for user feedback
                showInfoDialog(
                  context: context,
                  title: 'Connection Failed',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.',
                  isError: true,
                );
              },
              child: const Text('Test Connection Failed message'),
            ),
            const SizedBox(height: 10),
            // --- Example for Confirmation Dialog ---
            ElevatedButton(
              onPressed: () async {
                final confirmed = await showConfirmationDialog(
                  context: context,
                  title: 'Payment Confirmation',
                  content: 'Are you sure you want toproceed this payment',
                  confirmButtonText: 'Proceed',
                );

                // Act based on the user's choice
                if (confirmed) {
                  showSnackBar(
                    context: context,
                    message: 'Payment has been confirmed.',
                    type: MessageType.success,
                  );
                } else {
                  showSnackBar(
                    context: context,
                    message: 'Payment was cancelled.',
                    type: MessageType.warning,
                  );
                }
              },
              child: const Text('Payment Confirmation'),
            ),
          ],
        ),
      ),
    );
  }
}
