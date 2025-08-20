import 'package:flutter/material.dart';
import 'package:myapp/models/column_model.dart';
import 'package:myapp/models/part_model.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/util/snack_bar.dart';
import 'package:myapp/widgets/action_button.dart';
import 'package:myapp/widgets/app_page.dart';
import 'package:myapp/widgets/app_table.dart';
import 'package:myapp/widgets/dealer_info_card.dart';
import 'package:myapp/widgets/quantity_selector.dart';
//import 'package:myapp/widgets/custom_selection_form_field.dart';
import 'package:myapp/widgets/select_dealer_view.dart';
import 'package:myapp/widgets/select_tin_view.dart';
//import 'package:myapp/widgets/selection_sheet.dart';
import 'package:myapp/models/tin_model.dart';
import 'package:myapp/models/dealer_model.dart';
import 'package:myapp/widgets/auth_dealer_view.dart';
import 'package:myapp/widgets/tin_info_card.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
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

  void _saveinvoice() {
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
        currentView = CreateInvoiceView(
          dealer: _selectedDealer!,
          tindata: _selectedTin!,
          onSubmit: _saveinvoice,
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
        currentTitle = 'Invoice';
        break;
      default:
        currentTitle = 'Error';
    }

    return AppPage(
      title: currentTitle,
      onBack: _goBack, // Pass our custom back logic for the multi-step flow.
      // Since the child views likely manage their own padding,
      // we set the AppPage's contentPadding to zero to avoid double padding.
      contentPadding: EdgeInsets.zero,
      child: currentView,
    );
  }
}

class CreateInvoiceView extends StatefulWidget {
  final Dealer dealer;
  final TinData tindata;
  final VoidCallback onSubmit;

  const CreateInvoiceView({
    super.key,
    required this.dealer,
    required this.tindata,
    required this.onSubmit,
  });

  @override
  State<CreateInvoiceView> createState() => _CreateInvoiceViewState();
}

// 2. Create the State class. This is where all state and logic will live.
class _CreateInvoiceViewState extends State<CreateInvoiceView> {
  // --- STATE VARIABLES ---
  List<Part> _parts = [];

  // --- ADD THIS STATE FOR FILTERING ---
  // final TextEditingController _searchController = TextEditingController();
  // String _searchQuery = '';
  // ------------------------------------

  // A getter is a clean way to calculate derived state on the fly.
  double get totalAmount {
    double total = 0.0;
    for (var part in _parts) {
      if (part.isSelected) {
        total += part.price * part.receivedQty;
      }
    }
    return total;
  }
  // -----------------------

  @override
  void initState() {
    super.initState();
    _loadParts(); // Load initial data when the widget is first created.
    // _searchController.addListener(() {
    //   setState(() {
    //     _searchQuery = _searchController.text;
    //   });
    // });
  }

  // --- LOGIC METHODS ---

  // Simulates loading parts data.
  void _loadParts() {
    _parts = [
      Part(id: 'p1', partNo: 'AC2000123230', requestQty: 2, price: 12000.00),
      Part(id: 'p2', partNo: 'AC2000123231', requestQty: 5, price: 5500.50),
      Part(id: 'p3', partNo: 'AC2000123232', requestQty: 1, price: 8000.00),
      Part(id: 'p4', partNo: 'AC2000123342', requestQty: 1, price: 1000.00),
      Part(id: 'p5', partNo: 'AC2000123932', requestQty: 1, price: 3000.00),
    ];
  }

  // Toggles the selection of a part.
  void _togglePartSelection(String partId) {
    setState(() {
      final part = _parts.firstWhere((p) => p.id == partId);
      part.isSelected = !part.isSelected;
      if (!part.isSelected) {
        part.receivedQty = 0;
      }
    });
  }

  // Updates the received quantity for a specific part.
  void _updateReceivedQuantity(String partId, int quantity) {
    setState(() {
      final part = _parts.firstWhere((p) => p.id == partId);
      part.receivedQty = quantity;
    });
  }

  // Shows the dialog and then updates the state with the result.
  Future<void> _showQuantityDialog(Part part) async {
    final int? newQuantity = await showDialog<int>(
      context: context,
      builder: (context) => _QuantityDialog(initialQuantity: part.receivedQty),
    );

    if (newQuantity != null) {
      // Call our state-updating method.
      _updateReceivedQuantity(part.id, newQuantity);
    }
  }

  // ---------------------

  // 3. The build method uses the state variables and methods defined above.
  @override
  Widget build(BuildContext context) {
    // --- FILTERING LOGIC ---
    // This is the core of the new functionality. It creates the filtered list.
    // final List<Part> filteredParts;
    // if (_searchQuery.isEmpty) {
    //   // If the search bar is empty, show all parts.
    //   filteredParts = _parts;
    // } else {
    //   // Otherwise, filter the list.
    //   filteredParts =
    //       _parts.where((part) {
    //         // Check if the part number (in lowercase) contains the search query (in lowercase).
    //         return part.partNo.toLowerCase().contains(
    //           _searchQuery.toLowerCase(),
    //         );
    //       }).toList();
    // }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          DealerInfoCard(dealer: widget.dealer),
          const SizedBox(height: 12),
          TinInfoDisplay(tinData: widget.tindata),
          const SizedBox(height: 12),
          Expanded(
            child: FilterableListView<Part>(
              items: _parts,
              searchHintText: 'Search by Part No',
              onFilterPressed: () {},
              filterLogic: (parts, query) {
                if (query.isEmpty) {
                  return parts; // Return all parts if the search is empty.
                }
                // Return a new list where the part number contains the query (case-insensitive).
                return parts.where((part) {
                  return part.partNo.toLowerCase().contains(
                    query.toLowerCase(),
                  );
                }).toList();
              },

              // This is where you define the entire table structure.
              columns: [
                DynamicColumn<Part>(
                  label: 'Part No',
                  flex: 3,
                  cellBuilder:
                      (context, part) => Text(
                        part.partNo,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                ),

                // Column 2: Request Quantity (Centered Text)
                DynamicColumn<Part>(
                  label: 'Request Qty',
                  flex: 2,
                  cellBuilder:
                      (context, part) =>
                          Center(child: Text(part.requestQty.toString())),
                ),

                DynamicColumn<Part>(
                  label: 'Select',
                  flex: 2,
                  cellBuilder:
                      (context, part) => Center(
                        child: Checkbox(
                          value: part.isSelected,
                          onChanged: (value) => _togglePartSelection(part.id),
                        ),
                      ),
                ),

                DynamicColumn<Part>(
                  label: 'Receive Qty',
                  flex: 3,
                  cellBuilder: (context, part) {
                    return QuantitySelector(
                      value: part.receivedQty,
                      enabled: part.isSelected,
                      dialogTitle: 'Update Quantity',
                      onChanged: (newValue) {
                        setState(() {
                          part.receivedQty = newValue;
                        });
                      },
                    );
                  },
                ),
                // DynamicColumn<Part>(
                //   label: 'Receive Qty',
                //   flex: 3,

                //   cellBuilder:
                //       (context, part) => _QuantityStepper(
                //         quantity: part.receivedQty,
                //         enabled: part.isSelected,
                //         onTap: () => _showQuantityDialog(part),
                //       ),
                // ),
              ],
            ),
          ), // const SizedBox(height: 16),
          // _buildFilterAndSearch(),
          // const SizedBox(height: 1),
          // _buildPartsTableHeader(),
          // Expanded(child: _buildPartsList(filteredParts)),
          // const SizedBox(height: 16),
          // Use the getter for the total amount.
          _buildTotalAmountSection(totalAmount),
          const SizedBox(height: 16),
          ActionButton(
            icon: Icons.check_circle_outline,
            label: 'Save',
            disabled: totalAmount == 0,
            onPressed: widget.onSubmit,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- MODIFIED HELPER WIDGET ---
  // The search widget now uses the controller from our state.
  // Widget _buildFilterAndSearch() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       children: [
  //         TextButton.icon(
  //           onPressed: () {},
  //           icon: const Icon(Icons.filter_alt_outlined),
  //           label: const Text('Filter'),
  //         ),
  //         const VerticalDivider(
  //           width: 1,
  //           indent: 8,
  //           endIndent: 8,
  //         ), // A thin visible divider
  //         Expanded(
  //           child: TextField(
  //             controller: _searchController, // Connect the controller here
  //             decoration: InputDecoration(
  //               hintText: 'Search by Part No',
  //               border: InputBorder.none,
  //               icon: const Icon(Icons.search),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // This helper now receives the filtered list to build.
  // Widget _buildPartsList(List<Part> parts) {
  //   return ListView.builder(
  //     itemCount: parts.length,
  //     itemBuilder: (context, index) {
  //       final part = parts[index];
  //       return _PartListItem(
  //         part: part,
  //         onToggleSelection: () => _togglePartSelection(part.id),
  //         onEditQuantity: () => _showQuantityDialog(part),
  //       );
  //     },
  //   );
  // }
  // --- UI HELPER METHODS ---
  // These are moved inside the State class.

  // Widget _buildInfoSection(Dealer dealer, TinData tindata) {
  //   return Column(
  //     children: [
  //       Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.all(12),
  //         decoration: BoxDecoration(
  //           color: AppColors.white,
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Text(
  //           '${dealer.name} - ${dealer.accountCode}',
  //           style: const TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 12.0),
  //               decoration: BoxDecoration(
  //                 color: AppColors.white,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: DropdownButtonHideUnderline(
  //                 child: DropdownButton<String>(
  //                   value: tindata.tinNumber,
  //                   icon: const Icon(Icons.keyboard_arrow_down),
  //                   items:
  //                       [tindata.tinNumber].map((String value) {
  //                         return DropdownMenuItem<String>(
  //                           value: value,
  //                           child: Text(value),
  //                         );
  //                       }).toList(),
  //                   onChanged: (_) {},
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Container(
  //             decoration: const BoxDecoration(
  //               color: AppColors.primary,
  //               shape: BoxShape.circle,
  //             ),
  //             child: IconButton(
  //               icon: const Icon(Icons.question_mark, color: AppColors.white),
  //               onPressed: () {},
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPartsTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: AppColors.white,
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Part No',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Request Qty',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Select',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Receive Qty',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountSection(double totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Amount',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          totalAmount.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _PartListItem extends StatelessWidget {
  final Part part;
  // It now requires functions to be passed to it.
  final VoidCallback onToggleSelection;
  final VoidCallback onEditQuantity;

  const _PartListItem({
    required this.part,
    required this.onToggleSelection,
    required this.onEditQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ... same styling as before
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              part.partNo,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: Text(part.requestQty.toString())),
          ),
          Expanded(
            flex: 2,
            child: Checkbox(
              value: part.isSelected,
              onChanged: (value) => onToggleSelection(),
            ),
          ),
          Expanded(
            flex: 3,
            child: _QuantityStepper(
              quantity: part.receivedQty,
              enabled: part.isSelected,
              onTap: onEditQuantity,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for the simple +/- stepper display.
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityStepper({
    required this.quantity,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color = enabled ? AppColors.text : Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.remove, color: color, size: 16),
            Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Icon(Icons.add, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

// The stateful dialog for editing quantity.
class _QuantityDialog extends StatefulWidget {
  final int initialQuantity;
  const _QuantityDialog({required this.initialQuantity});

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  late int _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delivered Quantity'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              Icons.remove_circle,
              color: AppColors.danger,
              size: 30,
            ),
            onPressed: () {
              if (_currentQuantity > 0) {
                setState(() => _currentQuantity--);
              }
            },
          ),
          Text(
            _currentQuantity.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.primary,
              size: 30,
            ),
            onPressed: () => setState(() => _currentQuantity++),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_currentQuantity),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Ok', style: TextStyle(color: AppColors.white)),
        ),
      ],
    );
  }
}
