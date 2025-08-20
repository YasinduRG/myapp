import 'package:flutter/material.dart';
import 'package:myapp/models/column_model.dart';
import 'package:myapp/models/return_item_model.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/util/snack_bar.dart';
import 'package:myapp/widgets/action_button.dart';
//import 'package:myapp/widgets/action_button.dart';
import 'package:myapp/widgets/app_page.dart';
import 'package:myapp/widgets/app_table.dart';
import 'package:myapp/widgets/dealer_info_card.dart';
import 'package:myapp/widgets/option_picker_dialog.dart';
import 'package:myapp/widgets/option_picker_field.dart';
//import 'package:myapp/widgets/custom_selection_form_field.dart';
import 'package:myapp/widgets/select_dealer_view.dart';
import 'package:myapp/widgets/select_tin_view.dart';
//import 'package:myapp/widgets/selection_sheet.dart';
import 'package:myapp/models/tin_model.dart';
import 'package:myapp/models/dealer_model.dart';
import 'package:myapp/widgets/auth_dealer_view.dart';
import 'package:myapp/widgets/tin_info_card.dart';
import 'package:myapp/widgets/titled_radio_group.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  int _currentStep = 0;
  Dealer? _selectedDealer;
  TinData? _selectedTin;
  // Dummy Data
  final List<Dealer> _dealers = [
    Dealer(
      name: 'Containers Co.',
      surname: 'Containers',
      accountCode: 'AC2000123230',
      address: 'Test Address 1',
      city: 'City 1',
    ),
    Dealer(
      name: 'B Motors',
      surname: 'B Motors',
      accountCode: 'AC2000123231',
      address: 'Test Address 2',
      city: 'City 2',
    ),
    Dealer(
      name: 'General Supplies',
      surname: 'Supplies',
      accountCode: 'AC2000123456',
      address: 'Main Street 123',
      city: 'City 1',
    ),
    Dealer(
      name: 'Auto Parts',
      surname: 'Auto',
      accountCode: 'AC2000123789',
      address: 'Industrial Ave',
      city: 'City 3',
    ),
  ];

  // MODIFIED: Added dummy data for TINs
  final List<TinData> _tins = [
    const TinData(tinNumber: 'TIN987654321', totalValue: 1500.75),
    const TinData(tinNumber: 'TIN123456789', totalValue: 899.99),
    const TinData(tinNumber: 'TIN555555555', totalValue: 12500.00),
    const TinData(tinNumber: 'TIN314159265', totalValue: 432.50),
  ];

  void _onDealerSelected(Dealer dealer) {
    setState(() {
      _selectedDealer = dealer;
    });
  }

  void _submitDealer() {
    if (_selectedDealer != null) {
      setState(() {
        _currentStep = 1; // Move to Authenticate step
      });
    }
  }

  void _onAuthenticated() {
    setState(() {
      _currentStep = 2; // Move to Create Invoice step
    });
  }

  // MODIFIED: Added callbacks for TIN selection
  void _onTinSelected(TinData tin) {
    setState(() {
      _selectedTin = tin;
    });
  }

  void _submitTin() {
    if (_selectedTin != null) {
      setState(() {
        _currentStep = 3; // Move to Create Invoice step
      });
    }
  }

  void _saveReturn() {
    setState(() {
      _currentStep = 0; // Move to the initial page
    });
    showSnackBar(
      context: context,
      message: "Invoice Saved !",
      type: MessageType.success,
    );
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
      // In a real app, you might use Navigator.of(context).pop();
      //print("Already at the first step.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_currentStep) {
      case 0:
        currentView = SelectDealerView(
          dealers: _dealers,
          selectedDealer: _selectedDealer,
          onDealerSelected: _onDealerSelected,
          onSubmit: _submitDealer, // Pass submit callback
        );
        break;
      case 1:
        currentView = AuthenticateDealerView(
          dealer: _selectedDealer!,
          onAuthenticated: _onAuthenticated,
        );
        break;
      case 2:
        currentView = SelectTinNumberView(
          dealer: _selectedDealer!,
          tins: _tins,
          selectedTin: _selectedTin,
          onTinNumberSelected: _onTinSelected,
          onSubmit: _submitTin,
        );
        break;
      case 3:
        currentView = ReturnsView(
          dealer: _selectedDealer!,
          tinData: _selectedTin!,
          onSubmit: _saveReturn,
        );
        break;
      default:
        currentView = const Center(child: Text('Error'));
    }
    final String currentTitle;
    switch (_currentStep) {
      case 0:
        currentTitle = 'Select Dealer';
        break;
      case 1:
        currentTitle = 'Authenticate Dealer';
        break;
      case 2:
        currentTitle = 'Select TIN';
        break;
      case 3:
        currentTitle = 'Returns';
        break;
      default:
        currentTitle = 'Error';
    }

    return AppPage(
      title: currentTitle,
      onBack: _goBack,
      contentPadding: EdgeInsets.zero,
      child: currentView,
    );
  }
}

// NOTE: Make sure to import your 'Dealer', 'TinData', and 'ReturnItem' models here.

class ReturnsView extends StatefulWidget {
  final Dealer dealer;
  final TinData tinData;
  final VoidCallback onSubmit;

  const ReturnsView({
    super.key,
    required this.dealer,
    required this.tinData,
    required this.onSubmit,
  });

  @override
  State<ReturnsView> createState() => _ReturnsViewState();
}

class _ReturnsViewState extends State<ReturnsView> {
  final List<ReturnItem> _items = [
    ReturnItem(partNo: 'AC2000123230', requestQty: 5),
    ReturnItem(partNo: 'AC2000123266', requestQty: 8),
    ReturnItem(partNo: 'AC2000123266', requestQty: 7),
  ];

  String _selectedReturnType = 'Discrepancy Returns';
  String? _selectedReason;
  final List<String> _reasonOptions = [
    'LEAKAGES (PETROL/OIL)',
    'LOYALTY DISCOUNT',
    'MANUFACTURING DEFECT',
    'REFUND',
    'OTHERS',
    'Bead Failure - BF',
  ];

  void _togglePartSelection(String partNo) {
    setState(() {
      final part = _items.firstWhere((p) => p.partNo == partNo);
      part.isSelected = !part.isSelected;
    });
  }

  Future<void> _showReasonPicker() async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => SelectionModal(
            title: 'Reason',
            options: _reasonOptions,
            initialValue: _selectedReason,
          ),
    );

    if (result != null) {
      setState(() {
        _selectedReason = result;
      });
    }
  }

  bool get isAnyItemSelected {
    return _items.any((item) => item.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    // 1. The root widget is now a Column, which allows us to stack a
    //    scrolling area on top of a fixed area.
    return Column(
      children: [
        // 2. The main content area is wrapped in Expanded. This tells it to
        //    take up all available vertical space, pushing the button to the bottom.
        Expanded(
          // 3. The ListView now handles the scrolling for the form content.
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              DealerInfoCard(dealer: widget.dealer),
              const SizedBox(height: 12),
              TinInfoDisplay(tinData: widget.tinData),
              const SizedBox(height: 16),

              // The SizedBox with a fixed height for the table is still a good approach
              // to contain the inner list and prevent nested scrolling issues.
              SizedBox(
                height: 250.0,
                child: FilterableListView<ReturnItem>(
                  items: _items,
                  searchHintText: 'Search by Part No',
                  onFilterPressed: () {},
                  filterLogic: (parts, query) {
                    if (query.isEmpty) return parts;
                    return parts.where((part) {
                      return part.partNo.toLowerCase().contains(
                        query.toLowerCase(),
                      );
                    }).toList();
                  },
                  columns: [
                    DynamicColumn<ReturnItem>(
                      label: 'Part No',
                      flex: 3,
                      cellBuilder:
                          (context, part) => Text(
                            part.partNo,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    DynamicColumn<ReturnItem>(
                      label: 'Request Qty',
                      flex: 2,
                      cellBuilder:
                          (context, part) =>
                              Center(child: Text(part.requestQty.toString())),
                    ),
                    DynamicColumn<ReturnItem>(
                      label: 'Select',
                      flex: 2,
                      cellBuilder:
                          (context, part) => Center(
                            child: Checkbox(
                              value: part.isSelected,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              onChanged:
                                  (value) => _togglePartSelection(part.partNo),
                            ),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              TitledRadioGroup(
                title: 'Return Type',
                options: const ['Field Returns', 'Discrepancy Returns'],
                selectedValue: _selectedReturnType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedReturnType = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              PickerFormField(
                labelText: 'Reason',
                displayValue: _selectedReason ?? 'Select a reason',
                onTap: _showReasonPicker,
              ),
            ],
          ),
        ),

        // 4. The ActionButton is now the LAST child of the Column, outside the Expanded
        //    widget. This fixes it to the bottom of the screen.
        //    We wrap it in padding to give it some space.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24,
          ), // Adjust padding as needed
          child: ActionButton(
            icon: Icons.check_circle_outline,
            label: 'Save',
            disabled: !isAnyItemSelected || _selectedReason == null,
            onPressed: widget.onSubmit,
          ),
        ),
      ],
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     // MODIFIED: Adjusted bottom padding to give space now that footer is removed.
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           DealerInfoCard(dealer: widget.dealer),
//           const SizedBox(height: 12),
//           TinInfoDisplay(tinData: widget.tinData),
//           const SizedBox(height: 16),
//           Expanded(
//             child: FilterableListView<ReturnItem>(
//               items: _items,
//               searchHintText: 'Search by Part No',
//               onFilterPressed: () {},
//               filterLogic: (parts, query) {
//                 if (query.isEmpty) {
//                   return parts; // Return all parts if the search is empty.
//                 }
//                 // Return a new list where the part number contains the query (case-insensitive).
//                 return parts.where((part) {
//                   return part.partNo.toLowerCase().contains(
//                     query.toLowerCase(),
//                   );
//                 }).toList();
//               },

//               // This is where you define the entire table structure.
//               columns: [
//                 DynamicColumn<ReturnItem>(
//                   label: 'Part No',
//                   flex: 3,
//                   cellBuilder:
//                       (context, part) => Text(
//                         part.partNo,
//                         style: const TextStyle(fontSize: 12),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                 ),

//                 // Column 2: Request Quantity (Centered Text)
//                 DynamicColumn<ReturnItem>(
//                   label: 'Request Qty',
//                   flex: 2,
//                   cellBuilder:
//                       (context, part) =>
//                           Center(child: Text(part.requestQty.toString())),
//                 ),

//                 DynamicColumn<ReturnItem>(
//                   label: 'Select',
//                   flex: 2,
//                   cellBuilder:
//                       (context, part) => Center(
//                         child: Checkbox(
//                           value: part.isSelected,
//                           activeColor: AppColors.primary,
//                           checkColor: AppColors.white,
//                           onChanged:
//                               (value) => _togglePartSelection(part.partNo),
//                         ),
//                       ),
//                 ),
//               ],
//             ),
//           ),
//           TitledRadioGroup(
//             title: 'Return Type',
//             options: const ['Field Returns', 'Discrepancy Returns'],
//             selectedValue: _selectedReturnType,
//             onChanged: (value) {
//               if (value != null) {
//                 setState(() => _selectedReturnType = value);
//               }
//             },
//           ),
//           const SizedBox(height: 16),
//           PickerFormField(
//             labelText: 'Reason',
//             displayValue: _selectedReason ?? 'Select a reason',
//             onTap: _showReasonPicker,
//           ),
//           const SizedBox(height: 16),
//           ActionButton(
//             icon: Icons.check_circle_outline,
//             label: 'Save',
//             disabled: !isAnyItemSelected,
//             onPressed: widget.onSubmit,
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
