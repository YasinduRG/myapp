import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider_old.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Provider.of to get the AuthProvider instance.
    // 'listen: false' is fine here if you don't expect the user data to change while on this screen.
    final User? currentUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // Helper widget to create styled info rows.
  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textFaded)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: AppColors.text, fontWeight: FontWeight.w500),
      ),
    );
  }
}