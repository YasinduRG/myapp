import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/app_footer.dart';
import 'package:myapp/models/invoic_model.dart';



class PrintInvoiceScreen extends StatelessWidget {
  const PrintInvoiceScreen({super.key});

  // Dummy data based on the image
  final List<InvoiceItem> _invoiceItems = const [
    InvoiceItem(invoiceNumber: 'MIN2025111700000567', invoiceAmount: '24000'),
    InvoiceItem(invoiceNumber: 'MIN2025111700000444', invoiceAmount: '24000'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Custom Header
              _buildHeader(context),
              const SizedBox(height: 24),

              // 2. Dealer Info
              const Text(
                'ABC Motors- AC200200000000',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 24),

              // 6. App Footer
              const AppFooter(),
            ],
          ),
        ),
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
                child: Text('Invoice Number', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ),
              Expanded(
                flex: 2,
                child: Text('Invoice Amount', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const Divider(thickness: 1.5),

          // Table Rows from data
          ..._invoiceItems.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(item.invoiceNumber, style: const TextStyle(fontSize: 14)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(item.invoiceAmount, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          )).toList(),
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
      label: const Text('Agree', style: TextStyle(color: AppColors.white, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}