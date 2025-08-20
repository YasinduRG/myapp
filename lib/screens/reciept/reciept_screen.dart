import 'package:flutter/material.dart';
import 'package:myapp/models/credit_note_model.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/action_button.dart';
import 'package:myapp/widgets/add_credit_note_view.dart';
//import 'package:myapp/views/cheque_details_view.dart'; // Adjust path
import 'package:myapp/widgets/app_page.dart';
import 'package:myapp/util/snack_bar.dart';
import 'package:myapp/widgets/date_picker_field.dart'; // Adjust path

class RecieptScreen extends StatefulWidget {
  const RecieptScreen({super.key});

  @override
  State<RecieptScreen> createState() => _RecieptScreenState();
}

class _RecieptScreenState extends State<RecieptScreen> {
  int _currentStep = 0;
  List<CreditNote> _creditNotes = []; // This will be useful later

  // This is the callback that will be passed to AddCreditNotesView.
  // It receives the updated list FROM the child view.
  void _updateAndSaveCreditNotes(List<CreditNote> updatedNotes) {
    setState(() {
      // 2. Update the parent's master list with the submitted changes
      _creditNotes = updatedNotes;

      // 3. Navigate back to the first view (or wherever you need to go)
      _currentStep = 0;
    });
    showSnackBar(
      context: context,
      message: '${updatedNotes.length} credit notes have been saved.',
      type: MessageType.success,
    );
    // Optional: Show a confirmation message
  }

  void _submitChequeDetails() {
    // This is where you would process the data
    // For now, we'll just show a success message and move to the next step
    showSnackBar(
      context: context,
      message: 'Cheque Details Submitted!',
      type: MessageType.success,
    );

    setState(() {
      _currentStep = 2; // Move to the confirmation/summary view
    });
  }

  void _gotoaddCreditNotes() {
    setState(() {
      _currentStep = 1; // Move to the confirmation/summary view
    });
  }

  void _onback(){
    if (_currentStep > 0) {
          setState(() {
            _currentStep--; // Go back to the previous step
          });
        } else {
          Navigator.of(context).pop(); // Exit the page
    }
  }



  // void _addCreditNotes(List<CreditNote> notes) {
  //   // Save CREDIT NOTES HERE LATER
  //   setState(() {
  //     _currentStep = 0; // Move to the confirmation/summary view
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: _getCurrentTitle(),
      onBack:_onback,
      child: _buildCurrentView(),
    );
  }

String _getCurrentTitle() {
  switch (_currentStep) {
    case 0:
      return 'Cheque Deposit Details'; 
    case 1:
      return 'Add Credit Notes';       
    case 2:
      return 'Success';                
    default:
      return 'Error';         
  }
}

  Widget _buildCurrentView() {
    switch (_currentStep) {
      case 0:
        return RecieptDetailsView(
          onSubmit: _submitChequeDetails,
          addCreditnote: _gotoaddCreditNotes,
        );

      case 1:
        return AddCreditNotesView(
          initialNotes: _creditNotes,
          onSubmit: _updateAndSaveCreditNotes,
        );

      case 2:
        // You can create a new view here for confirmation or summary
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Submission Successful',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      default:
        return AddCreditNotesView(onSubmit: _updateAndSaveCreditNotes);
    }
  }
}

class RecieptDetailsView extends StatefulWidget {
  final VoidCallback onSubmit;
  final VoidCallback addCreditnote;

  const RecieptDetailsView({
    super.key,
    required this.onSubmit,
    required this.addCreditnote,
  });

  @override
  State<RecieptDetailsView> createState() => _RecieptDetailsViewState();
}

class _RecieptDetailsViewState extends State<RecieptDetailsView> {
  final _chequeNoController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedChequeDate;

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to check form validity on every change
    _chequeNoController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        _chequeNoController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _selectedChequeDate != null;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _chequeNoController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ActionButton(
              label: 'Add Credit Note',
              icon: Icons.add_card, // Example icon
              onPressed: widget.addCreditnote,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _chequeNoController,
              labelText: 'Cheque No.',
            ),
            const SizedBox(height: 16),
            _buildTextField(labelText: 'Account No.'), // Dummy for now
            const SizedBox(height: 16),
            DatePickerField(
              labelText: 'Cheque Date',
              selectedDate: _selectedChequeDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedChequeDate = date;
                  _validateForm(); // Validate after date selection
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(labelText: 'To Be Deposited'), // Dummy
            const SizedBox(height: 16),
            _buildTextField(labelText: 'Bank'), // Dummy
            const SizedBox(height: 16),
            _buildTextField(labelText: 'Branch'), // Dummy
            const SizedBox(height: 16),
            _buildTextField(
              controller: _amountController,
              labelText: 'Amount',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            ActionButton(
              label: 'Submit',
              icon: Icons.check_circle_outline,
              onPressed: widget.onSubmit,
              disabled: !_isFormValid,
            ),
          ],
        ),
      ),
    );
  }

  // Helper for text fields to reduce repetition
  Widget _buildTextField({
    TextEditingController? controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
