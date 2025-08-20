import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';

class QuantitySelector extends StatelessWidget {
  /// The current quantity to display.
  final int value;
  final ValueChanged<int>? onChanged;
  final bool enabled;
  final String dialogTitle;

  const QuantitySelector({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.dialogTitle = 'Update Quantity', // Default title
  });

  // This internal method handles the logic of showing the dialog.
  Future<void> _showEditDialog(BuildContext context) async {
    if (!enabled || onChanged == null) return;

    final newValue = await showDialog<int>(
      context: context,
      builder:
          (context) =>
              QuantityEditDialog(initialQuantity: value, title: dialogTitle),
    );
    if (newValue != null) {
      onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuantityStepperDisplay(
      quantity: value,
      enabled: enabled,
      onTap: () => _showEditDialog(context),
    );
  }
}

class QuantityStepperDisplay extends StatelessWidget {
  final int quantity;
  final bool enabled;
  final VoidCallback? onTap;

  const QuantityStepperDisplay({
    super.key,
    required this.quantity,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = enabled ? onTap : null;
    final color = enabled ? AppColors.text : AppColors.border;

    return InkWell(
      onTap: effectiveOnTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.remove, color: color, size: 16),
            Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Icon(Icons.add, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

class QuantityEditDialog extends StatefulWidget {
  final int initialQuantity;
  final String title;

  const QuantityEditDialog({
    super.key,
    required this.initialQuantity,
    required this.title,
  });

  @override
  State<QuantityEditDialog> createState() => _QuantityEditDialogState();
}

class _QuantityEditDialogState extends State<QuantityEditDialog> {
  late int _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              Icons.remove_circle,
              color: AppColors.danger,
              size: 30,
            ),
            onPressed: () {
              if (_currentQuantity > 0) {
                setState(() => _currentQuantity--);
              }
            },
          ),
          Text(
            _currentQuantity.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.primary,
              size: 30,
            ),
            onPressed: () => setState(() => _currentQuantity++),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Pop without a value
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
        ElevatedButton(
          onPressed:
              () => Navigator.of(
                context,
              ).pop(_currentQuantity), // Pop with the new value
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Ok', style: TextStyle(color: AppColors.white)),
        ),
      ],
    );
  }
}
