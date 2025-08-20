// // decapriated

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// // import 'package:intl/intl.dart';
// import 'package:myapp/theme/app_theme.dart'; // Adjust path if needed

// class DatePickerField extends StatelessWidget {
//   final String labelText;
//   final DateTime? selectedDate;
//   final ValueChanged<DateTime> onDateSelected;

//   const DatePickerField({
//     super.key,
//     required this.labelText,
//     required this.selectedDate,
//     required this.onDateSelected,
//   });

//   // Future<void> _selectDate(BuildContext context) async {
//   //   final DateTime? picked = await showDatePicker(
//   //     context: context,
//   //     initialDate: selectedDate ?? DateTime.now(),
//   //     firstDate: DateTime(2000),
//   //     lastDate: DateTime(2101),
//   //   );
//   //   if (picked != null && picked != selectedDate) {
//   //     onDateSelected(picked);
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           labelText,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: AppColors.primary, // Or your preferred label color
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () => _selectDate(context),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.border),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   selectedDate == null
//                       ? 'Select Date'
//                       : DateFormat('dd MMM yyyy').format(selectedDate!),
//                   style: TextStyle(
//                     color:
//                         selectedDate == null
//                             ? AppColors.border
//                             : Colors.black,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const Icon(Icons.calendar_today, color: AppColors.primary),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
