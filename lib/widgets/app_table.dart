import 'package:flutter/material.dart';
import 'package:myapp/contracts/mappable.dart';
import 'package:myapp/models/column_model.dart';
//import 'package:myapp/services/mock_api_service.dart';
import 'package:myapp/theme/app_theme.dart';
//import 'package:myapp/widgets/app_loading_overlay.dart';


class FilterableListView<T extends Mappable> extends StatefulWidget {
  /// The list of items to display.
  final List<T> items;

  /// The list of columns to display in the table.
  final List<DynamicColumn<T>> columns;

  /// The list of field names to be used for filtering.
  final List<String> filterableFields;

  /// Callback for when the filter button is pressed.
  final VoidCallback? onFilterPressed;

  /// The hint text to display in the search input field.
  final String searchHintText;

  const FilterableListView({
    super.key,
    required this.items,
    required this.columns,
    required this.filterableFields,
    this.onFilterPressed,
    this.searchHintText = 'Search...',
  });

  @override
  State<FilterableListView<T>> createState() => _FilterableListViewState<T>();
}

class _FilterableListViewState<T extends Mappable> extends State<FilterableListView<T>> {
  final TextEditingController _searchController = TextEditingController();

  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_performFilter);
  }

  @override
  void didUpdateWidget(FilterableListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
      // After updating the list, re-apply the current filter
      _performFilter();
    }
  }

  void _performFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final itemMap = item.toMap();
          return widget.filterableFields.any((field) {
            final value = itemMap[field];
            return value != null && value.toString().toLowerCase().contains(query);
          });
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_performFilter);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterAndSearch(),
        const SizedBox(height: 1),
        _buildHeader(),
        Container(height: 1, color: Colors.grey.shade300),
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  /// Builds the main body content based on the current state.
  Widget _buildBody() {
    if (_filteredItems.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildRow(_filteredItems[index]);
      },
    );
  }



  /// Builds the top bar containing the filter button and search field.
  Widget _buildFilterAndSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: widget.onFilterPressed,
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('Filter'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHintText,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      color:  AppColors.white,
      child: Row(
        children: widget.columns.map((column) {
          return Expanded(
            flex: column.flex,
            child: Text(
              column.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(T item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.columns.map((column) {
          return Expanded(
            flex: column.flex,
            child: column.cellBuilder(context, item),
          );
        }).toList(),
      ),
    );
  }
}


// class FilterableListView<T extends Mappable> extends StatefulWidget {
//   /// The API endpoint to fetch the data from.
//   final String dataUrl;

//   /// The list of columns to display in the table.
//   final List<DynamicColumn<T>> columns;

//   /// The list of field names to be used for filtering.
//   final List<String> filterableFields;

//   /// Callback for when the filter button is pressed.
//   final VoidCallback? onFilterPressed;

//   /// The hint text to display in the search input field.
//   final String searchHintText;

  

//   const FilterableListView({
//     super.key,
//     required this.dataUrl,
//     required this.columns,
//     required this.filterableFields,
//     this.onFilterPressed,
//     this.searchHintText = 'Search...',
//   });

//   @override
//   State<FilterableListView<T>> createState() => _FilterableListViewState<T>();
// }

// class _FilterableListViewState<T extends Mappable> extends State<FilterableListView<T>> {
//   final TextEditingController _searchController = TextEditingController();
//   // Instance of the loading overlay
//   late final AppLoadingOverlay _loadingOverlay;

//   List<T> _items = [];
//   List<T> _filteredItems = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadingOverlay = AppLoadingOverlay();
//     _searchController.addListener(_performFilter);
//     // Fetch data when the widget is first initialized
//     WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
//   }

//   @override
//   void didUpdateWidget(FilterableListView<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.dataUrl != oldWidget.dataUrl) {
//       _fetchData();
//     }
//   }

//   Future<void> _fetchData() async {
//     // Show the overlay before starting the async operation
//     _loadingOverlay.show(context);
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final data = await MockApiService.fetchData<T>(widget.dataUrl);
//       setState(() {
//         _items = data;
//         _filteredItems = data;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load data: $e';
//         _items = [];
//         _filteredItems = [];
//       });
//     } finally {
//       // Always hide the overlay when the operation is complete
//       setState(() {
//         _isLoading = false;
//       });
//       _loadingOverlay.hide();
//     }
//   }

//   void _performFilter() {
//     final query = _searchController.text.toLowerCase().trim();
//     setState(() {
//       if (query.isEmpty) {
//         _filteredItems = _items;
//       } else {
//         _filteredItems = _items.where((item) {
//           final itemMap = item.toMap();
//           return widget.filterableFields.any((field) {
//             final value = itemMap[field];
//             return value != null && value.toString().toLowerCase().contains(query);
//           });
//         }).toList();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_performFilter);
//     _searchController.dispose();
//     // Ensure the overlay is hidden if the widget is disposed
//     if (_loadingOverlay.isShowing) {
//       _loadingOverlay.hide();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildFilterAndSearch(),
//         const SizedBox(height: 1),
//         _buildHeader(),
//         Container(height: 1, color: Colors.grey.shade300),
//         Expanded(
//           child: _buildBody(),
//         ),
//       ],
//     );
//   }

//   /// Builds the main body content based on the current state.
//   Widget _buildBody() {
//     // We no longer show the loading indicator here,
//     // as the overlay handles it.
//     if (_errorMessage != null) {
//       return Center(child: Text(_errorMessage!));
//     }

//     if (_filteredItems.isEmpty && !_isLoading) {
//       return const Center(child: Text('No items found.'));
//     }

//     return ListView.builder(
//       itemCount: _filteredItems.length,
//       itemBuilder: (context, index) {
//         return _buildRow(_filteredItems[index]);
//       },
//     );
//   }



//   /// Builds the top bar containing the filter button and search field.
//   Widget _buildFilterAndSearch() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: AppColors.white, // AppColors.white
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.border), // AppColors.border
//       ),
//       child: Row(
//         children: [
//           TextButton.icon(
//             onPressed: widget.onFilterPressed,
//             icon: const Icon(Icons.filter_alt_outlined),
//             label: const Text('Filter'),
//             style: TextButton.styleFrom(
//               foregroundColor: AppColors.primary, // AppColors.primary
//             ),
//           ),
//           const VerticalDivider(width: 1, indent: 8, endIndent: 8),
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: widget.searchHintText,
//                 border: InputBorder.none,
//                 prefixIcon: const Icon(Icons.search),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
//       color:  AppColors.white, 
//       child: Row(
//         children: widget.columns.map((column) {
//           return Expanded(
//             flex: column.flex,
//             child: Text(
//               column.label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildRow(T item) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
//       decoration: BoxDecoration(
//         color: Colors.white, // AppColors.white
//         border: Border(bottom: BorderSide(color: AppColors.border)), // AppColors.border
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
//         children: widget.columns.map((column) {
//           return Expanded(
//             flex: column.flex,
//             child: column.cellBuilder(context, item),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }


  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       _buildFilterAndSearch(),
  //       const SizedBox(height: 1),
  //       _buildHeader(),
  //       Container(height: 1, color: Colors.grey.shade300), // AppColors.border
  //       Expanded(
  //         child: FutureBuilder<List<T>>(
  //           future: _fetchDataFuture,
  //           builder: (context, snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return const Center(child: CircularProgressIndicator());
  //             } else if (snapshot.hasError) {
  //               return Center(child: Text('Error: ${snapshot.error}'));
  //             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //               return const Center(child: Text('No items found.'));
  //             }

  //             return ListView.builder(
  //               itemCount: _filteredItems.length,
  //               itemBuilder: (context, index) {
  //                 return _buildRow(_filteredItems[index]);
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }



// class FilterableListView<T> extends StatefulWidget {
//   final List<T> items;

//   final List<T> Function(List<T> allItems, String query) filterLogic;

//   final List<DynamicColumn<T>> columns;

//   final VoidCallback? onFilterPressed;

//   final String searchHintText;

//   const FilterableListView({
//     super.key,
//     required this.items,
//     required this.filterLogic,
//     required this.columns,
//     this.onFilterPressed,
//     this.searchHintText = 'Search...',
//   });

//   @override
//   State<FilterableListView<T>> createState() => _FilterableListViewState<T>();
// }

// class _FilterableListViewState<T> extends State<FilterableListView<T>> {
//   late final TextEditingController _searchController;
//   late List<T> _filteredItems;

//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
//     _filteredItems = widget.items;
//     _searchController.addListener(_performFilter);
//   }

//   @override
//   void didUpdateWidget(FilterableListView<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.items != oldWidget.items) {
//       _performFilter();
//     }
//   }

//   void _performFilter() {
//     final query = _searchController.text;
//     setState(() {
//       _filteredItems = widget.filterLogic(widget.items, query);
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_performFilter);
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildFilterAndSearch(),
//         const SizedBox(height: 1),
//         _buildHeader(),
//         Container(height: 1, color: AppColors.border),
//         Expanded(
//           child: ListView.builder(
//             itemCount: _filteredItems.length,
//             itemBuilder: (context, index) {
//               return _buildRow(_filteredItems[index]);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   /// Builds the top bar containing the filter button and search field.
//   Widget _buildFilterAndSearch() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         children: [
//           TextButton.icon(
//             onPressed: widget.onFilterPressed,
//             icon: const Icon(Icons.filter_alt_outlined),
//             label: const Text('Filter'),
//             style: TextButton.styleFrom(
//               foregroundColor:
//                   AppColors.primary, // Assuming AppColors.primary is defined
//             ),
//           ),
//           const VerticalDivider(width: 1, indent: 8, endIndent: 8),
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: widget.searchHintText,
//                 border: InputBorder.none,
//                 prefixIcon: const Icon(Icons.search),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
//       color: AppColors.white,
//       child: Row(
//         children:
//             widget.columns.map((column) {
//               return Expanded(
//                 flex: column.flex,
//                 child: Text(
//                   column.label,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               );
//             }).toList(),
//       ),
//     );
//   }

//   Widget _buildRow(T item) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         border: Border(bottom: BorderSide(color: AppColors.border)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
//         children:
//             widget.columns.map((column) {
//               return Expanded(
//                 flex: column.flex,
//                 child: column.cellBuilder(context, item),
//               );
//             }).toList(),
//       ),
//     );
//   }
// }
