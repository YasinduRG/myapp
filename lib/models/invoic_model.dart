class InvoiceItem {
  final String invoiceNumber;
  final String invoiceAmount;

  const InvoiceItem({required this.invoiceNumber, required this.invoiceAmount});
}

class Invoice {
  final String date;
  final String invoiceNumber;
  final String customer;
  final double totalValue;

  Invoice({
    required this.date,
    required this.invoiceNumber,
    required this.customer,
    required this.totalValue,
  });
}
