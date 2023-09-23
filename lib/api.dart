import 'package:cnplus_pos/models/sales_model.dart';
import 'package:cnplus_pos/models/transaction_model.dart';
import 'package:cnplus_pos/pages/shopping_cart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import './models/product_model.dart';

Uri ServerURL(String path, [Map<String, String>? params]) {
  return Uri(
    scheme: 'https',
    host: 'cnplus.id',
    path: "khaliqa_hijab/api/v1/${path}",
    queryParameters: params,
  );
}

class ServerAPI {
  Future<dynamic> authenticate(String username, String password) async {
    debugPrint('$username; $password');
    try {
      var url = ServerURL(
        "account/login",
        {"username": username, "password": password},
      );

      debugPrint("begin post");
      var response = await http.post(url);
      if (response.statusCode == 200) {
        dynamic resBody = json.decode(response.body);
        return resBody;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<(bool, List<Product>?)> getProducts() async {
    try {
      var url = ServerURL("barang");
      debugPrint(url.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> products = json.decode(response.body)['data'];
        return (
          true,
          products
              .map((e) => Product(
                    id: e['id_barang'].toString(),
                    name: e['nama_barang'],
                    price: int.parse(e['harga_jual']),
                    stock: int.parse(e['last_stock']),
                  ))
              .toList()
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      return (false, null);
    }
    return (false, null);
  }

  Future<(bool, Product?)> getProductById(int id) async {
    try {
      var url = ServerURL("barang");
      debugPrint(url.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> products = json.decode(response.body)['data'];
        // products.where((e) {
        //   debugPrint("e");
        //   debugPrint(e);
        //   return false;
        // });
        // debugPrint("start");
        Map<String, dynamic> product =
            products.where((e) => e['id_barang'] == id).first;
        // debugPrint("end");
        debugPrint("product:");
        debugPrint(product.toString());
        return (
          true,
          Product(
            id: product['id_barang'].toString(),
            name: product['nama_barang'],
            price: int.parse(product['harga_jual']),
            stock: int.parse(product['last_stock']),
          )
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      return (false, null);
    }
    return (false, null);
  }

  Future<Cart> convertToCart(Map<String, dynamic> data) async {
    var product = (await getProductById(data['id_barang']));
    return Cart(
        id: data['id_barang'],
        product: product.$2!,
        quantity: ValueNotifier(data['qty']));
  }

  Future<(bool, List<Transaction>?)> getTransactionReport() async {
    debugPrint("getTransactionReport");
    try {
      var url = ServerURL("transaction/list");
      debugPrint(url.path);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> transaction = json.decode(response.body)['data'];
        return (
          true,
          transaction.map((e) {
            return Transaction(
              id: e['id'].toString(),
              customerName:
                  e['nama'] != null ? e['nama'].toString() : "Unknown",
              inputBy: e['input_by'],
              transactionDate: DateTime.parse(e['tanggal'].toString()),
              transactionType: e['tipe_transaksi'].toString(),
              paymentMethod: e['jenis_pembayaran'].toString(),
              cardNumber: e['no_kartu'].toString(),
              subTotal: int.parse(e['harga'].toString()),
              discountPrice: int.parse(e['diskon'].toString()),
              grandTotal: int.parse(e['total_harga'].toString()),
              paymentNominal: int.parse(e['nominal_bayar'].toString()),
              totalQuantities: int.parse(e['total_qty'].toString()),
              cart: e['detail'],
            );
          }).toList()
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      return (false, null);
    }
    return (false, null);
  }

  Future<bool> uploadTransaction(
      CartProvider cartProvider, Map<String, dynamic> data) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? isLoggedIn = pref.getString("loggedUserName");
      String customerName = data['customerName'];
      String transactionType = data['transactionType'];
      String paymentMethod = data['paymentMethod'];
      String cardNumber = data['cardNumber'];
      String subTotal = cartProvider.total.value.toString();
      String discount = data['discountPrice'].toString();
      String grandTotal = data['total'].toString();
      String totalQuantity = cartProvider.totalQuantity.value.toString();
      String paymentNominal = data['paymentNominal'].toString();
      var productIDs = cartProvider.getAllProductIDs();
      var productQuantities = cartProvider.getAllProductQuantities();

      var url = ServerURL(
        "transaction/create",
        {
          "nama_customer": customerName,
          "tipe": transactionType,
          "jenis_pembayaran": paymentMethod,
          "no_kartu": cardNumber,
          "harga": subTotal,
          "diskon": discount,
          "total_harga": grandTotal,
          "input_by": isLoggedIn ?? "",
          "total_qty": totalQuantity,
          "total_bayar": paymentNominal,
          ...{for (var v in productIDs) "prod_id[${productIDs.indexOf(v)}]": v},
          // "prod_id[]": productIDs,
          ...productQuantities.map<String, String>(
              (key, value) => MapEntry("qty[$key]", value.toString())),
          // "qty[]": productQuantities,
        },
      );

      // debugPrint(productIDs);
      // debugPrint(productQuantities);
      debugPrint(Uri.decodeComponent(url.toString()));
      var response = await http.post(url);
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<(bool, List<Sales>?)> getSales([DateTimeRange? range]) async {
    List<Sales> dummyData = [
      Sales(
        id: "1",
        date: DateTime.parse("2023-09-03"),
        quantitiesSold: 100,
        fund: 1100000,
        sale: 1200000,
      ),
      Sales(
        id: "2",
        date: DateTime.now(),
        quantitiesSold: 100,
        fund: 1100000,
        sale: 1200000,
      ),
      Sales(
        id: "3",
        date: DateTime.parse("2023-08-03"),
        quantitiesSold: 100,
        fund: 1100000,
        sale: 1200000,
      )
    ];

    try {
      if (range != null) {
        List<Sales> result = List.empty(growable: true);
        for (Sales e in dummyData) {
          if (range.start.difference(e.date).isNegative &&
              !range.end.difference(e.date).isNegative) {
            result.add(e);
          }
        }
        return (true, result);
      }

      return (true, dummyData);
    } catch (e) {
      debugPrint(e.toString());
      return (false, null);
    }
  }
}
