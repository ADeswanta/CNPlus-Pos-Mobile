
class Transaction {
  final String id;
  final String customerName;
  final String inputBy;
  final DateTime transactionDate;
  final String transactionType;
  final String paymentMethod;
  final String cardNumber;
  final int subTotal;
  final int discountPrice;
  final int grandTotal;
  final int paymentNominal;
  final int totalQuantities;
  final List<dynamic>? cart;

  Transaction(
      {required this.id,
      required this.customerName,
      required this.inputBy,
      required this.transactionDate,
      required this.transactionType,
      required this.paymentMethod,
      required this.cardNumber,
      required this.subTotal,
      required this.discountPrice,
      required this.grandTotal,
      required this.paymentNominal,
      required this.totalQuantities,
      this.cart});
}
