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
import 'package:myapp/widgets/select_dealer_view.dart';
import 'package:myapp/widgets/select_tin_view.dart';
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
    _loadParts(); // API integration later
  }

  // --- LOGIC METHODS ---

  // Simulates loading parts data.
  void _loadParts() {
    _parts = [
      Part(id: 'p1', partNo: 'AC2000123230', requestQty: 2, price: 12000.00),
      Part(id: 'p2', partNo: 'AC2000123231', requestQty: 5, price: 5500.50),
      Part(id: 'p3', partNo: 'AC2000123232', requestQty: 1, price: 8000.00),
      Part(id: 'p4', partNo: 'AC2000123342', requestQty: 1, price: 1000.00),
      Part(id: 'p5', partNo: 'AC2000123932', requestQty: 6, price: 3000.00),
      Part(id: 'p6', partNo: 'AC2000123937', requestQty: 6, price: 300.00),
    ];
  }

  Future<void> _showQuantityDialog(Part part) async {
    // Use your existing, separate QuantityEditDialog class
    final newQuantity = await showDialog<int>(
      context: context,
      builder:
          (context) => QuantityEditDialog(
            initialQuantity: part.receivedQty,
            title: 'Delivered Quantity',
            maxQuantity: part.requestQty, // Or any custom title
          ),
    );

    // If the dialog returned a new value, update the state.
    // The 'mounted' check is a best practice for async operations in stateful widgets.
    if (newQuantity != null && mounted) {
      setState(() {
        part.receivedQty = newQuantity;
      });
    }
  }
  // Toggles the selection of a part.
  // void _togglePartSelection(String partId) {
  //   setState(() {
  //     final part = _parts.firstWhere((p) => p.id == partId);
  //     part.isSelected = !part.isSelected;
  //     if (!part.isSelected) {
  //       part.receivedQty = 0;
  //     }
  //   });
  // }

  Future<void> _togglePartSelection(String partId) async {
    final part = _parts.firstWhere((p) => p.id == partId);

    setState(() {
      part.isSelected = !part.isSelected;
      if (!part.isSelected) {
        part.receivedQty = 0;
      } else {
        // Selected
        part.receivedQty = 1;
      }
    });
    if (part.isSelected) {
      await _showQuantityDialog(part);
    }
  }

  // ---------------------
  @override
  Widget build(BuildContext context) {
    // 1. The root is a Column to separate the body and the fixed footer.
    return Column(
      children: [
        // 2. The body is wrapped in Expanded so it takes up the available space.
        Expanded(
          // 3. A single ListView makes all the content scrollable.
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Your info cards at the top.
              DealerInfoCard(dealer: widget.dealer),
              const SizedBox(height: 12),
              TinInfoDisplay(tinData: widget.tindata),
              const SizedBox(height: 12),

              // 4. The FilterableListView is wrapped in a SizedBox to give it a
              //    fixed, predictable height within the scrollable list.
              SizedBox(
                // You can adjust this height based on your design needs.
                height: 300.0,
                child: FilterableListView<Part>(
                  items: _parts,
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
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              onChanged:
                                  (value) => _togglePartSelection(part.id),
                            ),
                          ),
                    ),
                    DynamicColumn<Part>(
                      label: 'Receive Qty',
                      flex: 3,
                      cellBuilder:
                          (context, part) => QuantitySelector(
                            value: part.receivedQty,
                            enabled: part.isSelected,
                            dialogTitle: 'Delivered Quantity',
                            maxQuantity: part.requestQty,
                            onChanged: (newValue) {
                              setState(() => part.receivedQty = newValue);
                            },
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 5. The fixed footer section remains outside the Expanded widget.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTotalAmountSection(totalAmount),
              const SizedBox(height: 16),
              ActionButton(
                icon: Icons.check_circle_outline,
                label: 'Save',
                disabled: totalAmount == 0,
                onPressed: widget.onSubmit,
              ),
            ],
          ),
        ),
      ],
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
