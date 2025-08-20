class ReturnItem {
  final String partNo;
  final int requestQty;
  bool isSelected;
  ReturnItem({
    required this.partNo,
    required this.requestQty,
    this.isSelected = false,
  });
}