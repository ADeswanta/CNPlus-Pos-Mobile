import 'package:cnplus_pos/pages/transaction_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../api.dart';
import '../models/transaction_model.dart';
import '../utils.dart';
import '../widgets/navigation_drawer.dart';

// List<Transaction> transactions = [
//   Transaction(
//     id: "1",
//     customerName: "Testing",
//     transactionDate: DateTime.now(),
//     transactionType: "CASH",
//     paymentMethod: "CASH",
//     cardNumber: "CASH",
//     subTotal: 120000,
//     discountPrice: 0,
//     grandTotal: 120000,
//     paymentNominal: 200000,
//     totalQuantities: 1,
//     cart: null,
//   ),
//   Transaction(
//     id: "2",
//     customerName: "Another Testing",
//     transactionDate: DateTime(2023, 8, 13),
//     transactionType: "CASH",
//     paymentMethod: "CASH",
//     cardNumber: "CASH",
//     subTotal: 120000,
//     discountPrice: 0,
//     grandTotal: 120000,
//     paymentNominal: 200000,
//     totalQuantities: 1,
//     cart: null,
//   ),
// ];

class TransactionItem extends StatelessWidget {
  TransactionItem(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.customerName),
      trailing: Text(DateFormat('dd MMM yyyy')
          .format(DateTime.parse(transaction.transactionDate.toString()))),
      subtitle: Text(Utils.convertToIDR(transaction.grandTotal).toString()),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            // debugPrint(ModalRoute.of(context)!.settings.toString());
            return TransactionDetailPage(transaction);
          },
        ));
      },
    );
  }
}

class TransactionReportPage extends StatefulWidget {
  const TransactionReportPage(
    this.scaffold,
    this.navigationDrawer, {
    super.key,
  });

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;

  @override
  State<TransactionReportPage> createState() => _TransactionReportPageState();
}

class _TransactionReportPageState extends State<TransactionReportPage> {
  late List<Transaction>? transactions = [];
  late int status = 9;

  void _loadTransactions() async {
    ServerAPI().getTransactionReport().then((server) {
      status = server.$1 ? 0 : 1;
      if (server.$1) {
        transactions = server.$2;
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaksi"),
        leading: IconButton(
          onPressed: () {
            widget.scaffold.currentState!.openDrawer();
          },
          icon: const Icon(Symbols.menu),
        ),
      ),
      // CONTENT HERE:
      body: status == 9
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : transactions != null && transactions!.isNotEmpty && status == 0
              ? ListView(
                  children: [...transactions!.map((e) => TransactionItem(e))],
                )
              : const Center(
                  child: Text("Something went wrong."),
                ),
    );
  }
}
