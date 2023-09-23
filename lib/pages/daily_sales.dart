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
                  Row(
                    children: [
                      Text("Modal: "),
                      Text(Utils.convertToIDR(sales.fund).toString()),
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

class FilterModel {
  DateTimeRange? range;

  FilterModel({this.range});

  bool isSet() {
    return range != null;
  }
}

class FilterPanel extends StatelessWidget {
  FilterPanel(FilterModel this.data, {super.key});

  final FilterModel data;

  @override
  Widget build(BuildContext context) {
    if (data.isSet()) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: Text("Date Range: "),
              ),
              Text(DateFormat('M/d/yyyy').format(data.range!.start)),
              Text(" - "),
              Text(DateFormat('M/d/yyyy').format(data.range!.end)),
            ],
          ),
        ]),
      );
    }

    return SizedBox();
  }
}

class DailySalesPage extends StatefulWidget {
  const DailySalesPage(
    this.scaffold,
    this.navigationDrawer, {
    super.key,
  });

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;

  @override
  State<DailySalesPage> createState() => _DailySalesPageState();
}

class _DailySalesPageState extends State<DailySalesPage> {
  late List<Sales>? sales = [];
  late int status = 9;

  FilterModel filter = FilterModel();

  void _loadSales() async {
    debugPrint(filter.range.toString());
    ServerAPI().getSales(filter.range).then((server) {
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
        title: const Text("Sales Harian"),
        leading: IconButton(
          onPressed: () {
            widget.scaffold.currentState!.openDrawer();
          },
          icon: const Icon(Symbols.menu),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Symbols.filter_list),
        onPressed: () {
          // showDialog(
          //   context: context,
          //   useRootNavigator: false,
          //   builder: (_) {
          //     // var decoration = InputDecoration(
          //     //   labelText: widget.title,
          //     //   border: OutlineInputBorder(),
          //     //   prefix: widget.type == "currency" ? Text("Rp ") : null,
          //     // );
          //     return showDatePicker(
          //         firstDate: DateTime, lastDate: DateTime.now());
          //   },
          // );
          showDateRangePicker(
            context: context,
            firstDate: DateTime(2000, 1, 1),
            lastDate: DateTime(2030, 12, 31),
          ).then((value) => setState(() {
                filter.range = value;
                _loadSales();
              }));
        },
      ),
      // CONTENT HERE:
      body: status == 9
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : sales != null && status == 0
              ? sales!.isNotEmpty
                  ? ListView(
                      children: [
                        FilterPanel(filter),
                        ...sales!.map((e) => SalesItem(e))
                      ],
                    )
                  : Column(
                      children: [
                        FilterPanel(filter),
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
