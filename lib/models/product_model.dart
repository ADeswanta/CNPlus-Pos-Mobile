class Product {
  // late final int? id;
  final String id;
  final String name;
  final int price;
  final int stock;
  final String? unitType;
  final String? image;

  Product(
      {required this.id,
      required this.name,
      required this.price,
			this.unitType = '',
      this.stock = 0,
      this.image});

  Product.fromMap(Map<dynamic, dynamic> data)
      : id = data['id'],
        name = data['name'],
        price = data['price'],
				unitType = data['unitType'],
        stock = data['stock'],
        image = data['image'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
			'unitType': unitType,
      'stock': stock,
      'image': image,
    };
  }
}
