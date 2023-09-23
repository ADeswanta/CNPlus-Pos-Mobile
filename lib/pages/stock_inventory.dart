import 'package:cnplus_pos/api.dart';
import 'package:cnplus_pos/models/product_model.dart';
import 'package:cnplus_pos/models/sales_model.dart';
import 'package:cnplus_pos/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../widgets/navigation_drawer.dart';

class StockItem extends StatelessWidget {
  StockItem(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
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
                      Text(
                        Utils.convertToIDR(product.price).toString(),
                      )
                    ],
                  ),
                ],
              ),
              Text(
                product.stock.toString(),
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

class StockInventoryPage extends StatefulWidget {
  const StockInventoryPage(
    this.scaffold,
    this.navigationDrawer, {
    super.key,
  });

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;

  @override
  State<StockInventoryPage> createState() => _StockInventoryPageState();
}

class _StockInventoryPageState extends State<StockInventoryPage> {
  late List<Product>? products = [];
  late int status = 9;

  void _loadSales() async {
    ServerAPI().getProducts().then((server) {
      status = server.$1 ? 0 : 1;
      if (server.$1) {
        products = server.$2;
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
        title: const Text("Stok Barang"),
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
          : products != null && status == 0
              ? products!.isNotEmpty
                  ? Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [...products!.map((e) => StockItem(e))],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Stock Terakhir:"),
                              Text("0"),
                            ],
                          ),
                        )
                      ],
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
