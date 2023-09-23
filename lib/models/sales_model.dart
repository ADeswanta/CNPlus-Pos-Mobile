class Sales {
  // late final int? id;
  final String id;
  final DateTime date;
  final int quantitiesSold;
  final int fund;
  final int sale;

  Sales({
    required this.id,
    required this.date,
    required this.quantitiesSold,
    required this.fund,
    required this.sale,
  });

  Sales.fromMap(Map<dynamic, dynamic> data)
      : id = data['id'],
        date = data['date'],
        quantitiesSold = data['quantitiesSold'],
        fund = data['fund'],
        sale = data['sale'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'quantitiesSold': quantitiesSold,
      'fund': fund,
      'sale': sale,
    };
  }
}
