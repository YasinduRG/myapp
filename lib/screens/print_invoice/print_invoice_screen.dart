import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/app_footer.dart';
import 'package:myapp/models/invoic_model.dart';
import 'package:myapp/models/dealer_model.dart';
import 'package:myapp/widgets/auth_dealer_view.dart';

// --- MAIN WIDGET: Manages the flow state ---
class PrintInvoiceScreen extends StatefulWidget {
  const PrintInvoiceScreen({super.key});

  @override
  State<PrintInvoiceScreen> createState() => _PrintInvoiceScreenState();
}

class _PrintInvoiceScreenState extends State<PrintInvoiceScreen> {
  int _currentStep = 0;
  Dealer? _selectedDealer;

  // 1. MODIFIED: The callback now accepts the authenticated dealer.
  void _onAuthenticated(Dealer authenticatedDealer) {
    setState(() {
      _selectedDealer = authenticatedDealer; // 2. Set the selected dealer
      _currentStep = 1; // 3. Move to the next step
    });
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    // This dealer is created here for demonstration.
    // In a real app, you would likely fetch or pass this data.
    final dealerToAuth = Dealer(
        name: 'B Motors',
        surname: 'B Motors',
        accountCode: 'AC2000123231',
        address: 'Test Address 2',
        city: 'City 2');

    switch (_currentStep) {
      case 0:
        currentView = AuthenticateDealerView(
          dealer: dealerToAuth,
          // Pass the modified callback. When onAuthenticated is called
          // inside AuthenticateDealerView, it will pass the dealer object back.
          onAuthenticated: () => _onAuthenticated(dealerToAuth),
        );
        break;
      case 1:
        // Now _selectedDealer is guaranteed to be non-null here.
        currentView = PrintInvoiceMainScreen(dealer: _selectedDealer!);
        break;
      default:
        currentView = const Center(child: Text('Error: Invalid step'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.primary),
                    onPressed: _goBack,
                  ),
                  Expanded(
                    child: Text(
                      _currentStep == 0 ? 'Authenticate Dealer' : 'Print Invoice',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48), // Balances the back button
                ],
              ),
            ),
            Expanded(child: currentView),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: AppFooter(),
            )
          ],
        ),
      ),
    );
  }
}

class PrintInvoiceMainScreen extends StatelessWidget {
  final Dealer dealer;
  const PrintInvoiceMainScreen({super.key, required this.dealer});

  // Dummy data based on the figma
  final List<InvoiceItem> _invoiceItems = const [
    InvoiceItem(invoiceNumber: 'MIN2025111700000567', invoiceAmount: '24000'),
    InvoiceItem(invoiceNumber: 'MIN2025111700000444', invoiceAmount: '24000'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // No top padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. MODIFIED: Header and the following SizedBox are removed.
          const SizedBox(height: 24),

          // 2. Dealer Info
          Text(
            dealer.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 3. Invoice Details Table
          _buildInvoiceTable(),
          const Spacer(),

          // 4. Confirmation Text
          _buildConfirmationBox(),
          const SizedBox(height: 20),

          // 5. Agree Button
          _buildAgreeButton(),
          // 6. MODIFIED: AppFooter is removed as it's now handled by the parent screen.
        ],
      ),
    );
  }

  // Helper method to build the header
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Text(
          'Print Invoice',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 48), // Spacer to balance the back button
      ],
    );
  }

  // Helper method to build the invoice list
  Widget _buildInvoiceTable() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table Header
          const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Invoice Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Invoice Amount',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(thickness: 1.5),

          // Table Rows from data
          ..._invoiceItems
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.invoiceNumber,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.invoiceAmount,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // Helper method to build the confirmation message box
  Widget _buildConfirmationBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
      ),
      child: const Text(
        'All Items Were Received in Good Condition fa...',
        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Helper method to build the main action button
  Widget _buildAgreeButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Handle agree action
      },
      icon: const Icon(Icons.handshake_outlined, color: AppColors.white),
      label: const Text(
        'Agree',
        style: TextStyle(color: AppColors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
