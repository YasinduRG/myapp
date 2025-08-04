import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:myapp/providers/auth_provider_old.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:myapp/providers/auth_provider.dart'; // 2. Import the new Riverpod provider

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final User? currentUser = authState.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      // 1. AppBar has been removed.
      // appBar: AppBar(...)
      body: SafeArea(
        // Use SafeArea to avoid system UI (like the notch)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 2. New custom header
              Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Centered Title
                  const Expanded(
                    child: Text(
                      'User Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  // Spacer to perfectly center the title, matching the IconButton's width
                  const SizedBox(width: 48.0),
                ],
              ),
              const SizedBox(height: 30), // Spacing after the header
              // Profile Avatar
              const CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Welcome Text
              Text(
                'Hello, ${currentUser?.username ?? 'Guest'}!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 40),

              // User Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.account_circle,
                        label: 'Username',
                        value: currentUser?.username ?? 'N/A',
                      ),
                      const Divider(),
                      _buildInfoTile(
                        icon: Icons.email,
                        label: 'Email Address',
                        value: currentUser?.email ?? 'N/A',
                      ),
                      const Divider(),
                      _buildInfoTile(
                        icon: Icons.badge,
                        label: 'User ID',
                        value: currentUser?.id ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to create styled info rows (no changes needed).
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textFaded,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
