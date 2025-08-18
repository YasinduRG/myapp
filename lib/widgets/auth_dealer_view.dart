import 'package:flutter/material.dart';
//import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/models/dealer_model.dart';
import 'package:myapp/widgets/action_button.dart';



class AuthenticateDealerView extends StatefulWidget {
  final Dealer dealer;
  final VoidCallback onAuthenticated;

  const AuthenticateDealerView({
    super.key,
    required this.dealer,
    required this.onAuthenticated,
  });

  @override
  State<AuthenticateDealerView> createState() => _AuthenticateDealerViewState();
}

class _AuthenticateDealerViewState extends State<AuthenticateDealerView> {
  final _pinController = TextEditingController();
  bool _isButtonDisabled = true;
  @override
  void initState() {
    super.initState();
    _pinController.addListener(() {
      setState(() {
        _isButtonDisabled = _pinController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Authenticating: ${widget.dealer.name}', // Use 'widget.' to access properties
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _pinController, // 7. Assign the controller to the TextField
            decoration: InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
          ),
          const Spacer(),
          ActionButton(
            label: 'Agree',
            onPressed: widget.onAuthenticated, // Use 'widget.' to access properties
            disabled: _isButtonDisabled, // 8. Use the state variable to control the button
          ),
        ],
      ),
    );
  }
}

// class AuthenticateDealerView extends StatelessWidget {
//   final Dealer dealer;
//   final VoidCallback onAuthenticated;
//   const AuthenticateDealerView({
//     super.key,
//     required this.dealer,
//     required this.onAuthenticated,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Authenticating: ${dealer.name}',
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           TextField(
//             decoration: InputDecoration(
//               labelText: 'PIN',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             keyboardType: TextInputType.number,
//             obscureText: true,
//           ),
//           const Spacer(),
//           ActionButton(label: 'Agree', onPressed: onAuthenticated,disabled: false),
//         ],
//       ),
//     );
//   }
// }
