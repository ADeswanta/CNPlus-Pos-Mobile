import 'package:cnplus_pos/api.dart';
import 'package:cnplus_pos/models/transaction_model.dart';
import 'package:cnplus_pos/pages/pdf_preview.dart';
import 'package:cnplus_pos/pages/reciepts/transaction_receipt.dart';
// import 'package:cnplus_pos/pages/pdf_preview/transaction_receipt';
import 'package:cnplus_pos/pages/shopping_cart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../utils.dart';
import '../widgets/order_sheet.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage(
    this.transaction, {
    super.key,
  });

  final Transaction transaction;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  List<Cart> carts = List.empty(growable: true);
  int status = 9;

  void getCarts(List<dynamic> data) async {
    debugPrint("getCarts");
    data.forEach(
      (element) {
        ServerAPI()
            .getProductById(int.parse(element['id_barang']))
            .then((product) {
          status = product.$1 ? 0 : 1;
          if (product.$1) {
            carts.add(Cart(
              id: element['id_barang'],
              product: product.$2!,
              quantity: ValueNotifier(int.parse(element['qty'])),
            ));
          }
        });
        // debugPrint(product.$2.toString());

        // cart.add(await convertToCart(element));
      },
    );
    setState(() {});
    if (data.isEmpty) {
      setState(() {
        status = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCarts(widget.transaction.cart!);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.transaction.cart.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
      ),
      // CONTENT HERE:
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Nama Kustomer",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.transaction.customerName),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Nama Kasir",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.transaction.inputBy != "1"
                                ? widget.transaction.inputBy
                                : "Unknown"),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tanggal Transaksi",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(DateFormat('dd MMM yyyy')
                                .format(widget.transaction.transactionDate)),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tipe",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.transaction.transactionType),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Metode Pembayaran",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.transaction.paymentMethod),
                          ],
                        ),
                      )
                    ],
                  ),
                  status == 9
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : status == 0
                          ? carts.isNotEmpty
                              ? Column(
                                  children: [
                                    ...carts.map(
                                      (e) => OrderItem(
                                        e,
                                        deletable: false,
                                        editable: false,
                                      ),
                                    )
                                  ],
                                )
                              : Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text("Empty"),
                                )
                          : Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("Something went wrong"),
                            )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total"),
                        Text(
                          Utils.convertToIDR(widget.transaction.grandTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Bayar"),
                        Text(
                          Utils.convertToIDR(widget.transaction.paymentNominal),
                          // info['paymentNominal'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Kembalian"),
                        Text(
                          Utils.convertToIDR(widget.transaction.paymentNominal -
                              widget.transaction.grandTotal),
                          // info['paymentNominal'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              printReceipt(
                                  context,
                                  widget.transaction.customerName,
                                  widget.transaction.subTotal,
                                  widget.transaction.discountPrice,
                                  widget.transaction.grandTotal,
                                  widget.transaction.paymentNominal,
                                  carts);
                            },
                            child: const Text("Cetak Transaksi"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          // widget.transaction.cart != null
          //     ? widget.transaction.cart.isNotEmpty
          //         ? widget.transaction.cart.map((e) => OrderItem(
          //               e,
          //               deletable: false,
          //             ))
          //         : Text("Empty")
          //     : Text("Someting went wrong")
          // widget.transaction.cart != null ?
          // widget.transaction.cart!.map((e) => Text(e.product.name)) : null
        ],
      ),
    );
  }
}
