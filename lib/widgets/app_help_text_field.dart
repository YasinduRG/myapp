import 'package:flutter/material.dart';
import 'package:myapp/contracts/mappable.dart';
import 'package:myapp/theme/app_theme.dart';

//typedef DisplayStringCallback<T> = String Function(T item);
typedef CommitStateChangedCallback = void Function(bool isCommitted);

class AppSelectionField<T extends Mappable> extends StatefulWidget {
    final T? initialValue; // <<< ADD THIS NEW PROPERTY

  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final List<T> items;
  final void Function(T) onSelected;
  //final DisplayStringCallback<T> displayString;
  final CommitStateChangedCallback? onCommitStateChanged;
  final String selectionSheetTitle;
  final List<String> displayNames;
  final List<String> valueFields;
  final String mainField;

  const AppSelectionField({
    super.key,
    required this.controller,
    required this.labelText,
    this.icon = Icons.question_mark,
    required this.items,
    required this.onSelected,
    //required this.displayString,
    this.onCommitStateChanged, // Make it optional
    required this.selectionSheetTitle,
    required this.displayNames,
    required this.valueFields,
    required this.mainField,
    this.initialValue
  });

  @override
  State<AppSelectionField<T>> createState() => _AppSelectionFieldState<T>();
}

class _AppSelectionFieldState<T extends Mappable>
    extends State<AppSelectionField<T>> {
  T? _lastSelectedItem;

  @override
  void initState() {
    super.initState();
    _lastSelectedItem = widget.initialValue;
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }


  /// --- NEW: A simple helper to get the main field's value. ---
  String _getMainFieldValue(T item) {
    final map = item.toMap();
    return map[widget.mainField]?.toString() ?? '';
  }



  void _handleTextChange() {
    if (_lastSelectedItem != null &&
        widget.controller.text !=
             _getMainFieldValue(_lastSelectedItem as T)) {
      _lastSelectedItem = null;
      widget.onCommitStateChanged?.call(false);
    }
  }

  Future<void> _showSelectionSheet(BuildContext context) async {
    final initialQuery = widget.controller.text;

    // --- NEW LOGIC: ATTEMPT AUTO-SELECTION FIRST ---
    // If the text field is not empty, check for a unique, exact match.
    if (initialQuery.isNotEmpty) {
      final exactMatches =
          widget.items.where((item) {
            final map = item.toMap();
            final fieldValue =
                map[widget.mainField]?.toString().toLowerCase() ?? '';
            return fieldValue == initialQuery.toLowerCase();
          }).toList();

      // If exactly one match is found, select it and skip showing the sheet.
      if (exactMatches.length == 1) {
        final selectedItem = exactMatches.first;

        // Use the same logic as when selecting from the sheet
        widget.controller.removeListener(_handleTextChange);
        _lastSelectedItem = selectedItem;
        //widget.controller.text = widget.displayString(selectedItem);
        widget.controller.text = _getMainFieldValue(selectedItem);
        widget.onSelected(selectedItem);
        widget.onCommitStateChanged?.call(true);
        widget.controller.addListener(_handleTextChange);

        // Exit the function since we've made a selection.
        return;
      }
    }

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
        );
      },
    );

    if (selectedItem != null) {
      widget.controller.removeListener(_handleTextChange);
      _lastSelectedItem = selectedItem;
      widget.controller.text = _getMainFieldValue(selectedItem);
      //widget.controller.text = widget.displayString(selectedItem);
      widget.onSelected(selectedItem);
      widget.onCommitStateChanged?.call(true);
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
  final TextEditingController controller;

  final String labelText;
  final IconData icon; // Make the icon customizable
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
    this.icon = Icons.search,
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
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: const TextStyle(color: AppColors.borderDark),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: contentPadding,

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    hideBorder
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.borderDark),
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
                // Use primary color when the field is focused.
                if (states.contains(MaterialState.focused)) {
                  return const TextStyle(color: AppColors.primary);
                }
                // Use border color when unfocused (but has content, so it's floating).
                return const TextStyle(color: AppColors.borderDark);
              }),
              errorStyle: const TextStyle(color: AppColors.danger),
            ),
          ),
        ),
        const SizedBox(width: 8),

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

class SelectionSheet<T extends Mappable> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String? initialSearchQuery;

  /// The header titles for the table (e.g., ['Account Code', 'Surname']).
  final List<String> displayNames;

  /// The property keys to look up in the map (e.g., ['accountCode', 'surname']).
  final List<String> valueFields;

  const SelectionSheet({
    super.key,
    required this.title,
    required this.items,
    this.initialSearchQuery,
    required this.displayNames,
    required this.valueFields,
  }) : assert(
         displayNames.length == valueFields.length,
         'Error: The number of display names must match the number of value fields.',
       );

  @override
  State<SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T extends Mappable>
    extends State<SelectionSheet<T>> {
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

  void _performFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems =
            widget.items.where((item) {
              final map = item.toMap();
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
                            final map = item.toMap();
                            return DataRow(
                              cells:
                                  widget.valueFields.map((field) {
                                    final cellValue =
                                        map[field]?.toString() ?? '';
                                    return DataCell(
                                      Text(cellValue),
                                      onTap: () {
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
