import 'package:flutter/material.dart';

// Enum to define the type of message
enum MessageType { success, error }

// Global key to access the ScaffoldMessengerState
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showSnackBar({
  required String message,
  required MessageType type,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  // Determine the background color based on the message type
  final Color backgroundColor = type == MessageType.success ? Colors.green : Colors.red;

  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: backgroundColor,
    duration: duration,
    action: action,
  );

  // Use the global key to show the SnackBar
  scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
}