import 'package:flutter/material.dart';
import 'package:myapp/models/column_model.dart';
import 'package:myapp/theme/app_theme.dart';

class FilterableListView<T> extends StatefulWidget {
  final List<T> items;

  final List<T> Function(List<T> allItems, String query) filterLogic;

  final List<DynamicColumn<T>> columns;

  final VoidCallback? onFilterPressed;

  final String searchHintText;

  const FilterableListView({
    super.key,
    required this.items,
    required this.filterLogic,
    required this.columns,
    this.onFilterPressed,
    this.searchHintText = 'Search...',
  });

  @override
  State<FilterableListView<T>> createState() => _FilterableListViewState<T>();
}

class _FilterableListViewState<T> extends State<FilterableListView<T>> {
  late final TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _searchController.addListener(_performFilter);
  }

  @override
  void didUpdateWidget(FilterableListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _performFilter();
    }
  }

  void _performFilter() {
    final query = _searchController.text;
    setState(() {
      _filteredItems = widget.filterLogic(widget.items, query);
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
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              return _buildRow(_filteredItems[index]);
            },
          ),
        ),
      ],
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
              foregroundColor:
                  AppColors.primary, // Assuming AppColors.primary is defined
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
      color: AppColors.white,
      child: Row(
        children:
            widget.columns.map((column) {
              return Expanded(
                flex: column.flex,
                child: Text(
                  column.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
        children:
            widget.columns.map((column) {
              return Expanded(
                flex: column.flex,
                child: column.cellBuilder(context, item),
              );
            }).toList(),
      ),
    );
  }
}
