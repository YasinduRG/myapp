import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/models/dealer_model.dart';


class AuthenticateDealerView extends StatelessWidget {
  final Dealer dealer;
  final VoidCallback onAuthenticated;
  const AuthenticateDealerView({super.key, required this.dealer, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Text('Authenticating: ${dealer.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
          ),
            const Spacer(),
          ElevatedButton(
            onPressed: onAuthenticated,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Authenticate', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}