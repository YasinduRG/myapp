import 'package:flutter/material.dart';
import 'package:myapp/models/dealer_model.dart';
import 'package:myapp/widgets/action_button.dart';
import 'package:myapp/widgets/app_help_text_field.dart';





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
  final TextEditingController _dealerController = TextEditingController();
  // 1. This is the only state we need to track now.
  bool _isDealerSelectionCommitted = false;

  @override
  void initState() {
    super.initState();
    // If a dealer is pre-selected, the state is initially valid.
    if (widget.selectedDealer != null) {
      _dealerController.text = widget.selectedDealer!.name;
      _isDealerSelectionCommitted = true;
    }
  }

  @override
  void dispose() {
    _dealerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSelectionField<Dealer>(
            controller: _dealerController,
            labelText: 'Select Dealer',
            selectionSheetTitle: 'Select a Dealer',
            initialValue: widget.selectedDealer,
            items: widget.dealers,
            onSelected: widget.onDealerSelected,
            //displayString: (dealer) => dealer.name,
            onCommitStateChanged: (isCommitted) {
              setState(() {
                _isDealerSelectionCommitted = isCommitted;
              });
            },
            displayNames: const ['Account Code', 'Name', 'Address', 'City'],
            valueFields: const ['accountCode', 'name', 'address', 'city'],
            mainField: 'name',
          ),
          const Spacer(),
          ActionButton(
            icon: Icons.check_circle_outline,
            label: 'Submit',
            onPressed: widget.onSubmit,
            disabled: !_isDealerSelectionCommitted,
          ),
        ],
      ),
    );
  }
}

// class _SelectDealerViewState extends State<SelectDealerView> {
//   //late List<Dealer> _filteredDealers;
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _dealerController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // _filteredDealers = widget.dealers;
//     // _searchController.addListener(_filterDealers);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // void _filterDealers() {
//   //   final query = _searchController.text.toLowerCase();
//   //   setState(() {
//   //     // _filteredDealers =
//   //     //     widget.dealers.where((dealer) {
//   //     //       return dealer.name.toLowerCase().contains(query) ||
//   //     //           dealer.surname.toLowerCase().contains(query) ||
//   //     //           dealer.accountCode.toLowerCase().contains(query) ||
//   //     //           dealer.address.toLowerCase().contains(query) ||
//   //     //           dealer.city.toLowerCase().contains(query);
//   //     //     }).toList();
//   //   });
//   // }

//   // Future<void> _showDealerSelection(BuildContext context) async {
//   //   final selectedDealer = await showModalBottomSheet<Dealer>(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (_) {
//   //       return SelectionSheet<Dealer>(
//   //         title: 'Select Dealer',
//   //         items: _filteredDealers,
//   //         searchController: _searchController,
//   //         headerBuilder: const Row(
//   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //           children: [
//   //             Expanded(
//   //               child: Text(
//   //                 'Account Code',
//   //                 style: TextStyle(fontWeight: FontWeight.bold),
//   //               ),
//   //             ),
//   //             Expanded(
//   //               child: Text(
//   //                 'Surname',
//   //                 style: TextStyle(fontWeight: FontWeight.bold),
//   //               ),
//   //             ),
//   //             Expanded(
//   //               child: Text(
//   //                 'Address',
//   //                 style: TextStyle(fontWeight: FontWeight.bold),
//   //               ),
//   //             ),
//   //             Expanded(
//   //               child: Text(
//   //                 'City',
//   //                 style: TextStyle(fontWeight: FontWeight.bold),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //         itemBuilder: (Dealer dealer) {
//   //           return InkWell(
//   //             onTap: () => Navigator.of(context).pop(dealer),
//   //             child: Padding(
//   //               padding: const EdgeInsets.symmetric(
//   //                 horizontal: 16.0,
//   //                 vertical: 12.0,
//   //               ),
//   //               child: Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Expanded(child: Text(dealer.accountCode)),
//   //                   Expanded(child: Text(dealer.surname)),
//   //                   Expanded(child: Text(dealer.address)),
//   //                   Expanded(child: Text(dealer.city)),
//   //                 ],
//   //               ),
//   //             ),
//   //           );
//   //         },
//   //       );
//   //     },
//   //   );

//   //   if (selectedDealer != null) {
//   //     widget.onDealerSelected(selectedDealer);
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AppSelectionField<Dealer>(
//             controller: _dealerController,
//             labelText: 'Select Dealer',
//             selectionSheetTitle: 'Select a Dealer',
//             items: widget.dealers,
//             onSelected: widget.onDealerSelected,
//             displayString: (dealer) => dealer.name,

//             // --- The beautiful, simple API you wanted ---
//             toMapConverter: (dealer) => dealer.toMap(),
//             displayNames: const ['Account Code', 'Name', 'Address', 'City'],
//             valueFields: const ['accountCode', 'name', 'address', 'city'],
//           ),

//           //   AppHelpTextField(
//           //   // Pass the controller you created
//           //   controller: _dealerController,
//           //   labelText: 'Dealer',
//           //   hintText: 'Enter Dealer Name or Code',
//           //   icon: Icons.search, // A more appropriate icon
//           //   // The icon now triggers the search/lookup action
//           //   onIconPressed: _handleDealerSearch,
//           // ),

//           // CustomSelectionFormField<Dealer>(
//           //   labelText: 'Select Dealer',
//           //   selectedValue: widget.selectedDealer,
//           //   displayString: (dealer) => dealer.name,
//           //   onShowPicker: _showDealerSelection,
//           // ),
//           const Spacer(),
//           ActionButton(
//             icon: Icons.check_circle_outline,
//             label: 'Submit',
//             onPressed: widget.onSubmit,
//             disabled: widget.selectedDealer == null,
//           ),
//         ],
//       ),
//     );
//   }
// }
