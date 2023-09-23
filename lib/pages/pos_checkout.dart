import 'package:cnplus_pos/pages/pdf_preview.dart';
import 'package:cnplus_pos/pages/reciepts/transaction_receipt.dart';
import 'package:cnplus_pos/pages/shopping_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import '../api.dart';
// import 'pdf_preview/transaction_receipt';

import '../utils.dart';
import '../widgets/order_sheet.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final Map<String, dynamic> info = {
    "customerName": "",
    "transactionType": "OFFLINE",
    "additionalCharge": 0,
    "serviceCharge": 0,
    "discount": 0,
    "discountPrice": 0,
    "paymentMethod": "CASH",
    "paymentNominal": 0,
    "cardNumber": "",
    "total": 0
  };
  final double headerHeight = 48;
  // int finalTotal = 0;

  int calculateDiscount(int subtotal) {
    int value = (subtotal * ((info['discount'] as int) / 100)).toInt();
    info['discountPrice'] = value;
    return value;
  }

  int calculateFinalTotal(int subtotal) {
    int value = subtotal -
        calculateDiscount(subtotal) +
        (info['additionalCharge'] as int) +
        (info['serviceCharge'] as int);
    info['total'] = value;
    return value;
  }

  void sendTransaction(BuildContext context, CartProvider cartProvider,
      Map<String, dynamic> data) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      useRootNavigator: false,
      builder: (_) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              Container(
                margin: EdgeInsets.only(
                  left: 7,
                ),
                child: Text("Loading..."),
              ),
            ],
          ),
        );
      },
    );
    bool authResponse = await ServerAPI().uploadTransaction(cartProvider, info);
    debugPrint(authResponse.toString());
    if (authResponse) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Transaksi Tersimpan",
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: 7,
                  ),
                  child: Text("Something went wrong"),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> forms = [
      TextFormField(
        decoration: InputDecoration(
          labelText: "Nama Customer",
          border: OutlineInputBorder(),
        ),
        onChanged: (val) {
          info['customerName'] = val;
          setState(() {});
        },
      ),
      InputDecorator(
        decoration: InputDecoration(
          labelText: "Tipe",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            onChanged: (String? value) => setState(() {
              info['transactionType'] = value;
            }),
            value: info['transactionType'],
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: "OFFLINE", child: Text("Toko")),
              DropdownMenuItem(value: "ONLINE", child: Text("Online"))
            ],
          ),
        ),
      ),
      Row(children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: const [IDRFormatter()],
            initialValue: '0',
            onChanged: (val) {
              info['additionalCharge'] = int.parse(val.replaceAll(',', ''));
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: "Additional charge",
              prefixText: "Rp ",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: const [IDRFormatter()],
            initialValue: '0',
            onChanged: (val) {
              info['serviceCharge'] = int.parse(val.replaceAll(',', ''));
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: "Service charge",
              prefixText: "Rp ",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: TextFormField(
            keyboardType: TextInputType.number,
            initialValue: '0',
            inputFormatters: [
              NumberFormatter(),
              LengthLimitingTextInputFormatter(3),
              NumericalRangeFormatter(0, 100)
            ],
            onChanged: (val) {
              info['discount'] = int.parse(val);
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: "Discount",
              suffixText: "%",
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ]),
      InputDecorator(
        decoration: InputDecoration(
          labelText: "Pembayaran",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            onChanged: (String? value) => setState(() {
              info['paymentMethod'] = value;
            }),
            value: info['paymentMethod'],
            items: const [
              DropdownMenuItem(value: "CASH", child: Text("Cash")),
              DropdownMenuItem(value: "CREDIT", child: Text("Credit")),
              DropdownMenuItem(value: "DEBIT", child: Text("Debit"))
            ],
          ),
        ),
      ),
      Column(children: [
        Visibility(
          visible: info['paymentMethod'] != "CASH",
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  const CardNumberFormatter()
                ],
                onChanged: (val) {
                  info['cardNumber'] = val;
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Nomor Kartu",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12)
            ],
          ),
        ),
        TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: const [IDRFormatter()],
          initialValue: '0',
          onChanged: (val) {
            info['paymentNominal'] = int.parse(val.replaceAll(',', ''));
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: "Nominal",
            prefixText: "Rp ",
            border: OutlineInputBorder(),
          ),
        )
      ])
    ];

    CartProvider cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Checkout"),
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: EdgeInsets.only(bottom: headerHeight),
            //   child: Wrap(
            //     children: [
            //       Column(
            //         children: [
            //           // Padding(
            //           //   padding: EdgeInsets.all(12),
            //           //   child: ListView.separated(
            //           //     itemBuilder: (context, index) {
            //           //       return forms[index];
            //           //     },
            //           //     separatorBuilder: (_, __) => SizedBox(height: 8),
            //           //     itemCount: forms.length,
            //           //   ),
            //           // ),
            //           ListView.separated(
            //             itemBuilder: (context, index) {
            //               return forms[index];
            //             },
            //             separatorBuilder: (_, __) => SizedBox(height: 8),
            //             itemCount: forms.length,
            //           ),
            //           ...info['orders'].cart.map((data) => OrderItem(
            //                 data,
            //                 deletable: false,
            //               ))
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) {
                        return forms[index];
                      },
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemCount: forms.length,
                    ),
                    ...cartProvider.cart.map((data) => OrderItem(
                          data,
                          deletable: false,
                        )),
                    Consumer<CartProvider>(
                      builder: (context, provider, widget) {
                        if (provider.cart.isEmpty) {
                          return const Center(
                              child: Text('Your Cart is Empty'));
                        } else {
                          return Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Wrap(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Subtotal"),
                                          ValueListenableBuilder<int>(
                                            valueListenable: provider.total,
                                            builder: (context, value, widget) {
                                              return Text(
                                                Utils.convertToIDR(value),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Diskon"),
                                          ValueListenableBuilder<int>(
                                            valueListenable: provider.total,
                                            builder: (context, value, widget) {
                                              return Text(
                                                Utils.convertToIDR(
                                                    (calculateDiscount(value) *
                                                        -1)),
                                                // info['paymentNominal'],
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700),
                                              );
                                            },
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Consumer<CartProvider>(
              builder: (context, provider, widget) {
                if (provider.cart.isEmpty) {
                  return const Center(child: Text('Your Cart is Empty'));
                } else {
                  return Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total"),
                                  ValueListenableBuilder<int>(
                                    valueListenable: provider.total,
                                    builder: (context, value, widget) {
                                      return Text(
                                        Utils.convertToIDR(
                                            calculateFinalTotal(value)),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24,
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Bayar"),
                                  Text(
                                    Utils.convertToIDR(info['paymentNominal']),
                                    // info['paymentNominal'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Kembalian"),
                                  ValueListenableBuilder<int>(
                                    valueListenable: provider.total,
                                    builder: (context, value, widget) {
                                      return Text(
                                        Utils.convertToIDR(
                                            info['paymentNominal'] -
                                                calculateFinalTotal(value)),
                                        // info['paymentNominal'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24,
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  IconButton.outlined(
                                    onPressed: () {
                                      printReceipt(
                                        context,
                                        info['customerName'],
                                        cartProvider.total.value,
                                        info['discountPrice'],
                                        info['total'],
                                        info['paymentNominal'],
                                        cartProvider.cart,
                                      );
                                    },
                                    icon: const Icon(Symbols.print),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SizedBox(
                                      height: 40,
                                      child: FilledButton(
                                        onPressed: () {
                                          printReceipt(
                                            context,
                                            info['customerName'],
                                            cartProvider.total.value,
                                            info['discountPrice'],
                                            info['total'],
                                            info['paymentNominal'],
                                            cartProvider.cart,
                                          );
                                          sendTransaction(
                                              context, cartProvider, info);
                                        },
                                        child: const Text("Cetak & Simpan"),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

            // Column(
            //   children: [
            //     Flexible(
            //       child: ListView.separated(
            //         padding: const EdgeInsets.all(12),
            //         shrinkWrap: true,
            //         itemBuilder: (context, index) {
            //           return forms[index];
            //         },
            //         separatorBuilder: (_, __) => SizedBox(height: 8),
            //         itemCount: forms.length,
            //       ),
            //     ),
            //     Flexible(
            //       child: ListView(shrinkWrap: true, children: [
            //         ...info['orders'].cart.map((data) => OrderItem(
            //               data,
            //               deletable: false,
            //             ))
            //       ]),
            //     )
            //   ],
            // ),
            // Column(children: [
            //   Expanded(
            //     child: ListView.separated(
            //       padding: EdgeInsets.only(bottom: headerHeight),
            //       itemBuilder: (context, index) {
            //         return forms[index];
            //       },
            //       separatorBuilder: (_, __) => SizedBox(height: 8),
            //       itemCount: forms.length,
            //     ),
            //   ),

            // ]),

            // const CheckoutSheet()
          ],
        ));
  }
}
