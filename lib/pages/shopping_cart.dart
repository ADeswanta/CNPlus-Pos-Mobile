// import 'package:provider/provider.dart';

import 'package:flutter/widgets.dart';
import '../models/product_model.dart';

class Cart {
  final String id;
  final Product product;
  final ValueNotifier<int> quantity;

  Cart({
    required this.id,
    required this.product,
    required this.quantity,
  });

  Cart.fromMap(Map<dynamic, dynamic> data)
      : id = data['id'],
        product = data['product'],
        quantity = ValueNotifier(data['quantity']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product,
      'quantity': quantity.value,
    };
  }
}

class CartProvider with ChangeNotifier {
  List<Cart> cart = [];

  ValueNotifier<int> total = ValueNotifier(0);
  ValueNotifier<int> totalQuantity = ValueNotifier(0);

  void addProduct(Product product) {
    final exist = cart.where((element) => element.id == product.id);
    if (exist.isNotEmpty) {
      increaseQuantity(product.id);
    } else {
      cart.add(
          Cart(id: product.id, product: product, quantity: ValueNotifier(1)));
    }
    setTotal();
    setTotalQuantity();
    notifyListeners();
  }

  void removeProduct(String id) {
    final index = cart.indexWhere((element) => element.id == id);
    cart.removeAt(index);
    setTotal();
    setTotalQuantity();
    notifyListeners();
  }

  void increaseQuantity(String id) {
    cart.where((element) => element.id == id).first.quantity.value += 1;
    setTotal();
    setTotalQuantity();
  }

  void decreaseQuantity(String id) {
    cart.where((element) => element.id == id).first.quantity.value -= 1;
    setTotal();
    setTotalQuantity();
  }

  void clearAllCarts() {
    cart.clear();
    notifyListeners();
  }

  Product? getProduct(String id) {
    return cart.where((element) => element.id == id).first.product;
  }

  void setTotal() {
    int newTotal = 0;
    for (var element in cart) {
      newTotal += element.product.price * element.quantity.value;
    }
    total.value = newTotal;
  }

  void setTotalQuantity() {
    int newTotal = 0;
    for (var element in cart) {
      newTotal += element.quantity.value;
    }
    totalQuantity.value = newTotal;
  }

  List<String> getAllProductIDs() {
    return cart.map((e) => e.id).toList();
  }

  Map<String, int> getAllProductQuantities() {
    return {for (var v in cart) v.id: v.quantity.value};
    // return {for (var e in cart) e.id: e.quantity.value};
    // return cart.map((e) => e.quantity.value);
  }
}
