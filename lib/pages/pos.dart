import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

import '../widgets/navigation_drawer.dart';
import '../widgets/search_field.dart';
import '../widgets/order_sheet.dart';

import '../models/product_model.dart';
import 'shopping_cart.dart';

import '../api.dart';

List<Product> productLists = [
  Product(id: "M00001", name: "Product 1", price: 10000, stock: 500),
  Product(id: "M00002", name: "Product 2", price: 50000, stock: 500),
  Product(
      id: "M00003",
      name: "Product 3",
      price: 8000,
      unitType: 'ons',
      stock: 500),
  Product(
      id: "M00004",
      name: "Product 4",
      price: 1000,
      unitType: 'ons',
      stock: 500),
  Product(id: "M00005", name: "Product 5", price: 20000, stock: 500),
  Product(
      id: "M00006",
      name: "Product 6",
      price: 25000,
      unitType: 'ons',
      stock: 500),
  Product(
      id: "M00007",
      name: "Product 7",
      price: 3000,
      unitType: 'ons',
      stock: 500),
  Product(id: "M00008", name: "Product 8", price: 2200, stock: 500),
  Product(
      id: "M00009",
      name: "Product 9",
      price: 8500,
      unitType: 'ons',
      stock: 500),
  Product(id: "M00010", name: "Product 10", price: 11000, stock: 500),
];

class ProductItemList extends StatelessWidget {
  const ProductItemList(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 96,
        child: Row(
          children: [
            product.image != null
                ? Image.asset(product.image!)
                : Container(height: 96, width: 96, color: Colors.cyan),
            SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expanded(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).listTileTheme.titleTextStyle,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              Utils.convertToIDR(product.price),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              (product.unitType != '')
                                  ? '/${product.unitType}'
                                  : '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Symbols.inventory_2,
                            size: 16,
                          ),
                        ),
                        Text(product.stock.toString())
                      ],
                    ),
                    // )
                  ],
                ),
              ),
            ),
            Consumer<CartProvider>(
              builder: (context, provider, widget) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: () => provider.addProduct(product),
                    icon: const Icon(Symbols.add_shopping_cart),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class POSPage extends StatefulWidget {
  const POSPage(this.scaffold, this.navigationDrawer, this.routeObserver,
      {super.key});

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;
  final RouteObserver<PageRoute> routeObserver;

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> with RouteAware {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Product>? products = [];
  late int status = 9;

  // List<Map<String, dynamic>> productCarts = [
  //   {
  //     "name": "Product 1",
  //     "price": 50000,
  //     "amount": 1,
  //   },
  //   {
  //     "name": "Product 2",
  //     "price": 10000,
  //     "amount": 5,
  //   }
  // ];

  // void addProductToCart(product) {
  //   setState(() {
  //     final existProduct = productCarts.where((x) {
  //       return x['name'] == product['name'] && x['price'] == product['price'];
  //     });
  //     if (existProduct.isNotEmpty) {
  //       existProduct.last['amount'] += 1;
  //     } else {
  //       productCarts.add(
  //           {"name": product['name'], "price": product['price'], "amount": 1});
  //     }
  //   });
  // }

  // void removeProductAtIndex(product) {
  //   setState(() {
  //     productCarts.removeWhere((element) => element = product);
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  // }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   widget.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  // }

  // @override
  // void dispose() {
  //   widget.routeObserver.unsubscribe(this);
  //   super.dispose();
  // }

  // @override
  // void didPush() {
  //   widget.navigationDrawer.currentState
  //       ?.setCurrentNavigation(ModalRoute.of(context)!.settings.name!);
  // }

  // @override
  // void didPop() {
  //   debugPrint("didPop: ${ModalRoute.of(context)!.settings.name}");
  //   debugPrint(widget.navigationDrawer.currentState.toString());
  //   // widget.navigationDrawer.currentState!.setCurrentNavigation(ModalRoute.of(context)!.settings.name!);
  // }

  void _loadProducts() {
    ServerAPI().getProducts().then((server) {
      status = server.$1 ? 0 : 1;
      if (server.$1) {
        products = server.$2;
      }

      debugPrint(server.$2.toString());

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    // final cart = Provider.of<CartProvider>(context);
    // debugPrint("we're in Transaksi/POS");
    // widget.navigationDrawer.currentState?.setCurrentNavigation("Transaksi/POS");

    // debugPrint(ModalRoute.of(context)!.settings.name);

    double headerHeight = 56;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("POS"),
        leading: IconButton(
          onPressed: () {
            widget.scaffold.currentState!.openDrawer();
          },
          icon: const Icon(Symbols.menu),
        ),
      ),
      body: (status == 9)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : status == 0
              ? products != null && products!.isNotEmpty
                  ? Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: headerHeight),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: SearchField(
                                  label: "Cari barang",
                                  prefix: Icon(Symbols.search),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemBuilder: (context, index) =>
                                      ProductItemList(products![index]),
                                  itemCount: products!.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const OrderSheet(),
                      ],
                    )
                  : const Center(
                      child: Text("Products are empty"),
                    )
              : const Center(
                  child: Text("Something went wrong."),
                ),
    );
  }
}
