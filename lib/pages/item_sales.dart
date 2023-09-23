import 'package:cnplus_pos/api.dart';
import 'package:cnplus_pos/models/sales_model.dart';
import 'package:cnplus_pos/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../widgets/navigation_drawer.dart';

class SalesItem extends StatelessWidget {
  SalesItem(this.sales);

  final Sales sales;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM dd yyyy').format(sales.date),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Qty Sold: "),
                      Text(sales.quantitiesSold.toString()),
                    ],
                  ),
                ],
              ),
              Text(
                Utils.convertToIDR(sales.sale).toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    // return ListTile(
    //   title: Text(sales.customerName),
    //   trailing: Text(DateFormat('dd MMM yyyy')
    //       .format(DateTime.parse(transaction.transactionDate.toString()))),
    //   subtitle: Text(Utils.convertToIDR(transaction.grandTotal).toString()),
    //   onTap: () {
    //     Navigator.of(context).push(MaterialPageRoute(
    //       builder: (context) {
    //         // debugPrint(ModalRoute.of(context)!.settings.toString());
    //         return TransactionDetailPage(transaction);
    //       },
    //     ));
    //   },
    // );
  }
}

class ItemSalesPage extends StatefulWidget {
  const ItemSalesPage(
    this.scaffold,
    this.navigationDrawer, {
    super.key,
  });

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;

  @override
  State<ItemSalesPage> createState() => _ItemSalesPageState();
}

class _ItemSalesPageState extends State<ItemSalesPage> {
  late List<Sales>? sales = [];
  late int status = 9;

  void _loadSales() async {
    ServerAPI().getSales().then((server) {
      status = server.$1 ? 0 : 1;
      if (server.$1) {
        sales = server.$2;
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Item"),
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
          : sales != null && status == 0
              ? sales!.isNotEmpty
                  ? ListView(
                      children: [...sales!.map((e) => SalesItem(e))],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: const Center(
                            child: Text("Empty"),
                          ),
                        ),
                      ],
                    )
              : const Center(
                  child: Text("Something went wrong."),
                ),
    );
  }
}
