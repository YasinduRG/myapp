import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';

// class AppTextField extends StatelessWidget {
//   final TextEditingController? controller;
//   final String labelText;
//   final TextInputType keyboardType;
//   final bool obscureText;
//   final bool isPin; // Use this to trigger all PIN-related behavior
//   final String? Function(String?)? validator;

//   const AppTextField({
//     super.key,
//     this.controller,
//     required this.labelText,
//     this.keyboardType = TextInputType.text,
//     this.obscureText = false,
//     this.isPin = false,
//     this.validator,
//   });

//   // This internal validator chains the built-in logic with the custom one.
//   String? _internalValidator(String? value) {
//     // --- Built-in PIN Validation ---
//     if (isPin) {
//       // Condition 1: Check if the field is empty.
//       if (value == null || value.isEmpty) {
//         return 'PIN cannot be empty';
//       }
//       // Condition 2: Check if the field contains only numbers.
//       final isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(value);
//       if (!isDigitsOnly) {
//         return 'PIN must contain only numbers';
//       }
//     }

//     if (validator != null) {
//       return validator!(value);
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // For a PIN field, we automatically set the keyboard and obscureText properties.
//     final bool shouldObscure = obscureText || isPin;
//     final TextInputType effectiveKeyboardType =
//         isPin ? TextInputType.number : keyboardType;

//     return TextFormField(
//       controller: controller,
//       keyboardType: effectiveKeyboardType, // Use the determined keyboard type
//       obscureText: shouldObscure, // Obscure if it's a password or PIN
//       // obscuringCharacter: isPin ? '*' : '•', // Use '*' for PINs
//       style: const TextStyle(color: Colors.black),

//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: const TextStyle(color: AppColors.border),
//         filled: true,
//         fillColor: AppColors.white,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.border),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.danger, width: 2.0),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.danger, width: 2.0),
//         ),
//         floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
//           // If the widget is in an error state, return the danger color.
//           if (states.contains(WidgetState.error)) {
//             return const TextStyle(color: AppColors.danger);
//           }
//           // For all other states (focused, normal), return the primary color.
//           return const TextStyle(color: AppColors.primary);
//         }),

//        // floatingLabelStyle: const TextStyle(color: AppColors.primary),
//         errorStyle: const TextStyle(color: AppColors.danger),
//       ),
//       // The validator now points to our internal method that handles all logic.
//       validator: _internalValidator,
//     );
//   }
// }

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isPin;
  final bool hideBorder;
  final EdgeInsetsGeometry? contentPadding;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted; // 1. ADD THIS LINE

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText, // NEW
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isPin = false,
    this.hideBorder =
        false, // NEW: Default to false to not break existing fields
    this.contentPadding, // NEW
    this.validator,
    this.onFieldSubmitted
  });

  String? _internalValidator(String? value) {
    if (isPin) {
      if (value == null || value.isEmpty) return 'PIN cannot be empty';
      final isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(value);
      if (!isDigitsOnly) return 'PIN must contain only numbers';
    }
    if (validator != null) return validator!(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldObscure = obscureText || isPin;
    final TextInputType effectiveKeyboardType =
        isPin ? TextInputType.number : keyboardType;

    return TextFormField(
      controller: controller,
      keyboardType: effectiveKeyboardType,
      obscureText: shouldObscure,
      onFieldSubmitted: onFieldSubmitted, // 3. PASS THE CALLBACK HERE
      textInputAction: TextInputAction.done, // 4. SET THE KEYBOARD ACTION
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: AppColors.borderDark),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: contentPadding,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              hideBorder
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              hideBorder
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              hideBorder
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.danger, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              hideBorder
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.danger, width: 2.0),
        ),

        // --- End of Conditional Border Logic ---
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(MaterialState.error)) {
            return const TextStyle(color: AppColors.danger);
          }
          // Use primary color when the field is focused.
          if (states.contains(MaterialState.focused)) {
            return const TextStyle(color: AppColors.primary);
          }
          // Use border color when unfocused (but has content, so it's floating).
          return const TextStyle(color: AppColors.borderDark);
        }),
        errorStyle: const TextStyle(color: AppColors.danger),
      ),
      validator: _internalValidator,
    );
  }
}
