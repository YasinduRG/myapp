import 'package:flutter/material.dart';
import 'package:myapp/screens/login/login_screen.dart';
import 'package:myapp/screens/main_menu/main_menu_screen.dart';
import 'package:myapp/screens/profile/profile_screen.dart';
import 'package:myapp/screens/setup_print/setup_print_screen.dart';
import 'package:myapp/app_routes.dart';
import 'package:myapp/screens/invoice/invoice_screen.dart';
import 'package:myapp/screens/print_invoice/print_invoice_screen.dart';
//import 'package:myapp/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart'; 

// Import our new notification service
//import 'package:myapp/services/notification_service.dart'; ENABLE THIS LATER FIBASE CLOUD NOTIFICATION

Future<void> main() async {
  // Ensure that Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize our notification service.
  // This will handle Firebase setup and topic subscription.
 // await NotificationService().initialize(); ENABLE THIS LATER FIBASE CLOUD NOTIFICATION

   // Initialize our notification service once when the app starts
  //await NotificationService().init(); 

  // Now, run the app.
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}









// void main() {
//    runApp(
//     ChangeNotifierProvider(

//       create: (context) => AuthProvider(), // <-- Use the new AuthProvider
//       child: const MyApp(),
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // The Consumer will rebuild this part whenever AuthProvider changes.
          // Based on the login state, it returns the correct screen.
          if (authProvider.isLoggedIn) {
            return const MainMenuScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      // 4. Define all possible navigation paths in your app
      routes: {
        //AppRoutes.authWrapper: (context) => const AuthWrapper(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.mainMenu: (context) => const MainMenuScreen(),
        AppRoutes.setupPrint: (context) => const SetupPrintScreen(), 
        AppRoutes.invoice: (context) => const InvoiceScreen(),
        AppRoutes.printInvoice: (context) => const PrintInvoiceScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        // Example for a future screen:
        // AppRoutes.invoice: (context) => const InvoiceScreen(),
      },
    );
  }
}

