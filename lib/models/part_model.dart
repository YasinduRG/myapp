class Part {
  final String id;
  final String partNo;
  final int requestQty;
  final double price; // The price for a single unit of this part.
  
  // These fields represent the state manipulated by the user in the UI.
  bool isSelected;
  int receivedQty;

  Part({
    required this.id,
    required this.partNo,
    required this.requestQty,
    required this.price,
    this.isSelected = false, // Defaults to not selected
    this.receivedQty = 0,    // Defaults to 0 received
  });
}