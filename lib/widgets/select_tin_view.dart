// Step 3 TIN Number Selection
import 'package:flutter/material.dart';
import 'package:myapp/models/dealer_model.dart';
import 'package:myapp/models/tin_model.dart';
import 'package:myapp/widgets/action_button.dart';
import 'package:myapp/widgets/custom_selection_form_field.dart';
import 'package:myapp/widgets/selection_sheet.dart';

class SelectTinNumberView extends StatefulWidget {
  final Dealer dealer;
  final List<TinData> tins;
  final Function(TinData) onTinNumberSelected;
  final VoidCallback onSubmit;
  final TinData? selectedTin;

  const SelectTinNumberView({
    super.key,
    required this.tins,
    required this.onTinNumberSelected,
    required this.onSubmit,
    required this.dealer,
    this.selectedTin,
  });

  @override
  State<SelectTinNumberView> createState() => _SelectTinNumberViewState();
}

class _SelectTinNumberViewState extends State<SelectTinNumberView> {
  // State variables for filtering logic.
  late List<TinData> _filteredTins;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the filtered list with all TINs.
    _filteredTins = widget.tins;
    // Add a listener to handle filtering as the user types.
    _searchController.addListener(_filterTins);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed.
    _searchController.dispose();
    super.dispose();
  }

  // Function to filter the list of TINs based on the search query.
  void _filterTins() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTins =
          widget.tins.where((tin) {
            // Search by both TIN number and total value.
            return tin.tinNumber.toLowerCase().contains(query) ||
                tin.totalValue.toString().toLowerCase().contains(query);
          }).toList();
    });
  }

  // Shows the modal bottom sheet for TIN selection.
  Future<void> _showTinSelection(BuildContext context) async {
    final selectedTin = await showModalBottomSheet<TinData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        // Assuming a generic SelectionSheet widget exists.
        return SelectionSheet<TinData>(
          title: 'Select TIN Number',
          items: _filteredTins, // Use the filtered list.
          searchController: _searchController, // Pass the search controller.
          // Define the header for the list.
          headerBuilder: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TIN Number',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'Total Value',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          // Define how each item in the list is built.
          itemBuilder: (TinData tin) {
            return InkWell(
              onTap: () => Navigator.of(context).pop(tin),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(tin.tinNumber)),
                    Expanded(
                      child: Text(tin.totalValue.toStringAsFixed(2)),
                    ), // Format value for display
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // If a TIN was selected, call the callback function.
    if (selectedTin != null) {
      widget.onTinNumberSelected(selectedTin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.dealer.name} - ${widget.dealer.accountCode}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // The custom form field to show the selection and trigger the sheet.
          CustomSelectionFormField<TinData>(
            labelText: 'Select TIN Number',
            selectedValue: widget.selectedTin,
            // Display the TIN number in the field when selected.
            displayString: (tin) => tin.tinNumber,
            onShowPicker: _showTinSelection,
          ),
          const Spacer(), // Pushes the button to the bottom.
          // The submit button.
          ActionButton(
            icon: Icons.check_circle_outline,
            label: 'Submit',
            onPressed: widget.onSubmit,
            disabled: widget.selectedTin == null,
          ),
        ],
      ),
    );
  }
}
