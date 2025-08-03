import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart'; // Import the AuthProvider
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/app_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _usernameController = TextEditingController(text: 'yasindu');
  final _passwordController = TextEditingController(text: '12345');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles the login logic by calling the AuthProvider.
  void _handleLogin() {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    final username = _usernameController.text;
    final password = _passwordController.text;

    // Use Provider.of with listen: false to call a method.
    Provider.of<AuthProvider>(context, listen: false).login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to rebuild the UI based on AuthProvider changes.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            // Disable user interaction while loading.
            child: AbsorbPointer(
              absorbing: authProvider.isLoading,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                // 2. Header
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        'assets/images/dpmc.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.business, size: 50, color: AppColors.danger), // Use theme color
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Invoice System',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary, // Use theme color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                  'Welcome back.',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text, // Use theme color
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Log in to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textFaded, // Use theme color
                  ),
                ),
                const SizedBox(height: 30),
                      // Display an error message if one exists.
                      if (authProvider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Center(
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(color: AppColors.danger, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      _buildTextField(controller: _usernameController, hintText: 'Username'),
                      const SizedBox(height: 20),
                      _buildTextField(controller: _passwordController, hintText: 'Password', obscureText: true),
                      const SizedBox(height: 20),
                      // 5. Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                      onPressed: () {},
                      child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: AppColors.primary, fontSize: 14), // Use theme color
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                      const SizedBox(height: 30),
                      // 6. Action Buttons - Now dynamic
                      // Show a loading indicator if loading, otherwise show the button.
                      authProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildActionButton(
                              icon: Icons.check_circle_outline,
                              label: 'Login',
                              color: AppColors.primary,
                              onPressed: _handleLogin, // Updated onPressed handler
                            ),
                      const SizedBox(height: 16),
                      
                      _buildActionButton(
                        icon: Icons.refresh,
                        label: 'Refresh',
                        color: AppColors.success,
                        onPressed: () {
                          _usernameController.clear();
                          _passwordController.clear();
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildActionButton(
                        icon: Icons.cancel_outlined,
                        label: 'Cancel',
                        color: AppColors.danger,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 50),

                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method for text fields (no changes needed)
  Widget _buildTextField({required TextEditingController controller, required String hintText, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  // Helper method for action buttons (no changes needed)
  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}