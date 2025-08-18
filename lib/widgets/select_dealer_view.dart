import 'package:flutter/material.dart';
import 'package:myapp/models/dealer_model.dart';
import 'package:myapp/widgets/action_button.dart';
import 'package:myapp/widgets/custom_selection_form_field.dart';
import 'package:myapp/widgets/selection_sheet.dart';

class SelectDealerView extends StatefulWidget {
  final List<Dealer> dealers;
  final Function(Dealer) onDealerSelected;
  final VoidCallback onSubmit;
  final Dealer? selectedDealer;

  const SelectDealerView({
    super.key,
    required this.dealers,
    required this.onDealerSelected,
    required this.onSubmit,
    this.selectedDealer,
  });

  @override
  State<SelectDealerView> createState() => _SelectDealerViewState();
}

class _SelectDealerViewState extends State<SelectDealerView> {
  late List<Dealer> _filteredDealers;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredDealers = widget.dealers;
    _searchController.addListener(_filterDealers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDealers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDealers =
          widget.dealers.where((dealer) {
            return dealer.name.toLowerCase().contains(query) ||
                dealer.surname.toLowerCase().contains(query) ||
                dealer.accountCode.toLowerCase().contains(query) ||
                dealer.address.toLowerCase().contains(query) ||
                dealer.city.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<void> _showDealerSelection(BuildContext context) async {
    final selectedDealer = await showModalBottomSheet<Dealer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SelectionSheet<Dealer>(
          title: 'Select Dealer',
          items: _filteredDealers, 
          searchController: _searchController, 
          headerBuilder: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Account Code',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'Surname',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'City',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          itemBuilder: (Dealer dealer) {
            return InkWell(
              onTap: () => Navigator.of(context).pop(dealer),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(dealer.accountCode)),
                    Expanded(child: Text(dealer.surname)),
                    Expanded(child: Text(dealer.address)),
                    Expanded(child: Text(dealer.city)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedDealer != null) {
      widget.onDealerSelected(selectedDealer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSelectionFormField<Dealer>(
            labelText: 'Select Dealer',
            selectedValue: widget.selectedDealer,
            displayString: (dealer) => dealer.name,
            onShowPicker: _showDealerSelection,
          ),
          const Spacer(),
          ActionButton(
            icon: Icons.check_circle_outline,
            label: 'Submit',
            onPressed: widget.onSubmit,
            disabled: widget.selectedDealer == null,
          ),
        ],
      ),
    );
  }
}