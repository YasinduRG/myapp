import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';

typedef DisplayStringCallback<T> = String Function(T item);
typedef ToMapConverter<T> = Map<String, dynamic> Function(T item);
// typedef CommitStateChangedCallback = void Function(bool isCommitted);

// class AppSelectionField<T> extends StatelessWidget {
//   // --- Standard properties ---
//   final TextEditingController controller;
//   final String labelText;
//   final IconData icon;

//   // --- Data and Selection properties ---
//   final List<T> items;
//   final void Function(T) onSelected;
//   final DisplayStringCallback<T> displayString;

//   final CommitStateChangedCallback? onCommitStateChanged;

//   // --- NEW DECLARATIVE API for the Sheet ---
//   final String selectionSheetTitle;
//   final List<String> displayNames;
//   final List<String> valueFields;
//   final ToMapConverter<T> toMapConverter;

//   const AppSelectionField({
//     super.key,
//     required this.controller,
//     required this.labelText,
//     this.icon = Icons.question_mark,
//     required this.items,
//     required this.onSelected,
//     required this.displayString,
//     this.onCommitStateChanged,
//     required this.selectionSheetTitle,
//     required this.displayNames,
//     required this.valueFields,
//     required this.toMapConverter,
//   });

//   Future<void> _showSelectionSheet(BuildContext context) async {
//     final initialQuery = controller.text;

//     final selectedItem = await showModalBottomSheet<T>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         // --- Call the new, refactored SelectionSheet ---
//         return SelectionSheet<T>(
//           title: selectionSheetTitle,
//           items: items,
//           initialSearchQuery: initialQuery,
//           displayNames: displayNames,
//           valueFields: valueFields,
//           toMapConverter: toMapConverter,
//         );
//       },
//     );

//     if (selectedItem != null) {
//       controller.text = displayString(selectedItem);
//       onSelected(selectedItem);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Assuming you have an AppTextFieldWithIcon or similar widget
//     return AppHelpTextField(
//       controller: controller,
//       labelText: labelText,
//       icon: icon,
//       onIconPressed: () => _showSelectionSheet(context),
//     );
//   }
// }

typedef CommitStateChangedCallback = void Function(bool isCommitted);

class AppSelectionField<T> extends StatefulWidget {
  // --- Standard properties ---
  final TextEditingController controller;
  final String labelText;
  final IconData icon;

  // --- Data and Selection properties ---
  final List<T> items;
  final void Function(T) onSelected;
  final DisplayStringCallback<T> displayString;

  // --- NEW: Callback to inform the parent of the commit state ---
  final CommitStateChangedCallback? onCommitStateChanged;

  // --- Declarative API for the Sheet ---
  final String selectionSheetTitle;
  final List<String> displayNames;
  final List<String> valueFields;
  final ToMapConverter<T> toMapConverter;

  const AppSelectionField({
    super.key,
    required this.controller,
    required this.labelText,
    this.icon = Icons.question_mark,
    required this.items,
    required this.onSelected,
    required this.displayString,
    this.onCommitStateChanged, // Make it optional
    required this.selectionSheetTitle,
    required this.displayNames,
    required this.valueFields,
    required this.toMapConverter,
  });

  @override
  State<AppSelectionField<T>> createState() => _AppSelectionFieldState<T>();
}

class _AppSelectionFieldState<T> extends State<AppSelectionField<T>> {
  T? _lastSelectedItem;

  @override
  void initState() {
    super.initState();
    // 2. Listen for user input to invalidate the state
    widget.controller.addListener(_handleTextChange);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    // 3. If an item was previously selected and the text no longer matches,
    //    it means the user has typed. Inform the parent that the state is no longer committed.
    if (_lastSelectedItem != null && widget.controller.text != widget.displayString(_lastSelectedItem as T)) {
      // Set the last selected item to null so this only fires once
      _lastSelectedItem = null;
      widget.onCommitStateChanged?.call(false);
    }
  }

  Future<void> _showSelectionSheet(BuildContext context) async {
    final initialQuery = widget.controller.text;

    final selectedItem = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SelectionSheet<T>(
          title: widget.selectionSheetTitle,
          items: widget.items,
          initialSearchQuery: initialQuery,
          displayNames: widget.displayNames,
          valueFields: widget.valueFields,
          toMapConverter: widget.toMapConverter,
        );
      },
    );

    if (selectedItem != null) {
      // Temporarily remove the listener to prevent our own change from triggering an invalid state
      widget.controller.removeListener(_handleTextChange);

      // 4. When an item is selected, update the state and inform the parent.
      _lastSelectedItem = selectedItem;
      widget.controller.text = widget.displayString(selectedItem);
      widget.onSelected(selectedItem);
      widget.onCommitStateChanged?.call(true); // State is now committed

      // Re-add the listener to watch for future user changes
      widget.controller.addListener(_handleTextChange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppHelpTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      icon: widget.icon,
      onIconPressed: () => _showSelectionSheet(context),
    );
  }
}

class AppHelpTextField extends StatelessWidget {
  // --- 1. NOW A REQUIRED PARAMETER ---
  // The parent form MUST provide a controller to manage the text state.
  final TextEditingController controller;

  final String labelText;
  //final String? hintText;
  final IconData icon; // Make the icon customizable

  // --- 2. CHANGED CALLBACK ---
  // A generic callback for when the icon button is pressed.
  final VoidCallback? onIconPressed;

  // --- 3. STANDARD TEXTFIELD PARAMETERS ---
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool hideBorder;
  final EdgeInsetsGeometry? contentPadding;

  const AppHelpTextField({
    super.key,
    required this.controller,
    required this.labelText,
    //this.hintText,
    this.icon = Icons.search, // Default to a search icon, more fitting
    this.onIconPressed,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.hideBorder = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment
              .start, // Align items correctly with validation errors
      children: [
        Expanded(
          // --- 4. A FULLY EDITABLE TEXTFORMFIELD ---
          // No more IgnorePointer or readOnly. This is a standard input field.
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              labelText: labelText,
              // hintText: hintText,
              labelStyle: const TextStyle(color: AppColors.border),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: contentPadding,

              // Decoration logic copied from your original AppTextField
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    hideBorder
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    hideBorder
                        ? BorderSide.none
                        : const BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    hideBorder
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.danger, width: 2.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    hideBorder
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.danger, width: 2.0),
              ),
              floatingLabelStyle: MaterialStateTextStyle.resolveWith((states) {
                if (states.contains(MaterialState.error)) {
                  return const TextStyle(color: AppColors.danger);
                }
                return const TextStyle(color: AppColors.primary);
              }),
              errorStyle: const TextStyle(color: AppColors.danger),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // --- 5. The IconButton triggers the generic callback ---
        IconButton(
          onPressed: onIconPressed,
          icon: Icon(icon), // Use the customizable icon
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}

class SelectionSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String? initialSearchQuery;

  /// The header titles for the table (e.g., ['Account Code', 'Surname']).
  final List<String> displayNames;

  /// The property keys to look up in the map (e.g., ['accountCode', 'surname']).
  final List<String> valueFields;

  /// A function that converts an item of type T to a Map.
  final ToMapConverter<T> toMapConverter;

  const SelectionSheet({
    super.key,
    required this.title,
    required this.items,
    this.initialSearchQuery,
    required this.displayNames,
    required this.valueFields,
    required this.toMapConverter,
  }) : assert(
         displayNames.length == valueFields.length,
         'Error: The number of display names must match the number of value fields.',
       );

  @override
  State<SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<SelectionSheet<T>> {
  // --- Internal State Management (Unchanged) ---
  late final TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _filteredItems = [];
    _searchController.addListener(_performFilter);
    _performFilter();
  }

  @override
  void dispose() {
    _searchController.removeListener(_performFilter);
    _searchController.dispose();
    super.dispose();
  }

  /// Filters the master item list based on the search controller's text. (Unchanged)
  void _performFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems =
            widget.items.where((item) {
              final map = widget.toMapConverter(item);
              return widget.valueFields.any((field) {
                final value = map[field]?.toString().toLowerCase() ?? '';
                return value.contains(query);
              });
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // --- Search Bar (Unchanged) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by any field...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              // --- Data Table with Horizontal Scrolling ---
              Expanded(
                child: SingleChildScrollView(
                  controller:
                      scrollController, // This handles VERTICAL scrolling
                  child: SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // This handles HORIZONTAL scrolling
                    child: DataTable(
                      columns:
                          widget.displayNames.map((name) {
                            return DataColumn(
                              label: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                      rows:
                          _filteredItems.map((item) {
                            final map = widget.toMapConverter(item);
                            return DataRow(
                              // 1. REMOVED `onSelectChanged` to hide the checkboxes.
                              cells:
                                  widget.valueFields.map((field) {
                                    final cellValue =
                                        map[field]?.toString() ?? '';
                                    return DataCell(
                                      Text(cellValue),
                                      // 2. ADDED `onTap` to each cell to make the whole row tappable.
                                      onTap: () {
                                        // Pop the original item `T`, not the map.
                                        Navigator.of(context).pop(item);
                                      },
                                    );
                                  }).toList(),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


// //typedef ToMapConverter<T> = Map<String, dynamic> Function(T item);

// class SelectionSheet<T> extends StatefulWidget {
//   final String title;
//   final List<T> items;
//   final String? initialSearchQuery;

//   // --- THE NEW, SIMPLER API ---
//   final List<String> displayNames;
//   final List<String> valueFields;
//   final ToMapConverter<T> toMapConverter;

//   const SelectionSheet({
//     super.key,
//     required this.title,
//     required this.items,
//     this.initialSearchQuery,
//     required this.displayNames,
//     required this.valueFields,
//     required this.toMapConverter,
//   }) : assert(displayNames.length == valueFields.length,
//             'displayNames and valueFields must have the same length');

//   @override
//   State<SelectionSheet<T>> createState() => _SelectionSheetState<T>();
// }

// class _SelectionSheetState<T> extends State<SelectionSheet<T>> {
//   late final TextEditingController _searchController;
//   late List<T> _filteredItems;

//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController(text: widget.initialSearchQuery);
//     _filteredItems = [];
//     _searchController.addListener(_performFilter);
//     _performFilter(); // Run once initially
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_performFilter);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _performFilter() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         _filteredItems = widget.items;
//       } else {
//         _filteredItems = widget.items.where((item) {
//           final map = widget.toMapConverter(item);
//           return widget.valueFields.any((field) {
//             final value = map[field]?.toString().toLowerCase() ?? '';
//             return value.contains(query);
//           });
//         }).toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       // ... same DraggableScrollableSheet setup
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               // ... same search bar setup using _searchController
//                 Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                 child: TextField(
//                   controller: _searchController,
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: 'Search by any field...',
//                     prefixIcon: const Icon(Icons.search),
//                     isDense: true,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: const BorderSide(color: Colors.grey),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
//                     ),
//                   ),
//                 ),
//               ),
//               const Divider(height: 1),
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   child: DataTable(
//                     columns: widget.displayNames.map((name) {
//                       return DataColumn(
//                           label: Text(name,
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold)));
//                     }).toList(),
//                     rows: _filteredItems.map((item) {
//                       final map = widget.toMapConverter(item);
//                       return DataRow(
//                         onSelectChanged: (isSelected) {
//                           if (isSelected ?? false) {
//                             // Pop the original item `T`, not the map.
//                             Navigator.of(context).pop(item);
//                           }
//                         },
//                         cells: widget.valueFields.map((field) {
//                           final cellValue = map[field]?.toString() ?? '';
//                           return DataCell(Text(cellValue));
//                         }).toList(),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }