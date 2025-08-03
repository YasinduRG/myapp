import 'package:flutter/material.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/theme/app_theme.dart'; // Import theme
import 'package:myapp/widgets/app_footer.dart'; // Import footer
import 'package:myapp/app_routes.dart';
import 'package:provider/provider.dart';   

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // 1. Main Menu Title
              const Text(
                'Main Menu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 30),

              // 2. Menu Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3, // 3 items per row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // Use a custom widget for each menu item
                    _MenuCard(
                        icon: Icons.receipt_long,
                        label: 'Invoice',
                        onTap: () {
                        // Navigate using the named route
                        Navigator.pushNamed(context, AppRoutes.invoice);
                        },
                      ),
                    _MenuCard(icon: Icons.print,
                     label: 'Print Invoice',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.printInvoice);
                      }),
                    _MenuCard(icon: Icons.article, label: 'Receipt', onTap: () {}),
                    _MenuCard(icon: Icons.route, label: 'Route Selection', onTap: () {}),
                    _MenuCard(icon: Icons.replay_circle_filled, label: 'Re-Print', onTap: () {}),
                    _MenuCard(
                        icon: Icons.settings,
                        label: 'Setup Print',
                        onTap: () {
                              Navigator.pushNamed(context, AppRoutes.setupPrint);
                          },
                          ),
                    _MenuCard(icon: Icons.lock_reset, label: 'Change Password', onTap: () {}),
                    _MenuCard(icon: Icons.info, label: 'About', onTap: () {}),
                    _MenuCard(
                      icon: Icons.person,
                      label: 'Profile',
                      onTap: () {
                        // Navigate to the new profile route
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                    ),
                    _MenuCard(
                      icon: Icons.logout,
                      label: 'Logout',
                      onTap: () {
                        _showLogoutConfirmationDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // 3. Footer
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}


  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Are You Sure You Want to Leave?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Make the column content-sized
            children: [
              // "Yes, Log out" button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger, // Red color for leaving
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Dismiss the dialog first
                    Navigator.of(dialogContext).pop();
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    // Then navigate to the login screen
                    //Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  },
                  child: const Text(
                    'Yes, Log out',
                    style: TextStyle(color: AppColors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // "No, I'm Staying" button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Blue color for staying
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Just dismiss the dialog
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'No, I\'m Staying',
                    style: TextStyle(color: AppColors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
// Helper widget for creating each card in the menu grid
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}