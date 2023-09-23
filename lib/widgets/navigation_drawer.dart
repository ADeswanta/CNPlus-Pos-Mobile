import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

var navigations = [
  {"type": "section", "label": "Welcome"},
  {
    "type": "item",
    "label": "Dashboard",
    "icon": Symbols.dashboard,
    "route": "Dashboard"
  },
  {
    "type": "item",
    "label": "POS",
    "icon": Symbols.point_of_sale,
    "route": "POS"
  },
  {
    "type": "expandable",
    "label": "Laporan",
    "icon": Symbols.monitoring,
    "child": [
      {
        "type": "item",
        "label": "Achievement Summary",
        "icon": Symbols.show_chart,
        "route": "Report/Summary"
      },
      {
        "type": "item",
        "label": "Sales Harian",
        "icon": Symbols.calendar_month,
        "route": "Report/DailySales"
      },
      {
        "type": "item",
        "label": "Transaksi",
        "icon": Symbols.shopping_cart,
        "route": "Report/Transactions"
      },
      {
        "type": "item",
        "label": "Item Sales",
        "icon": Symbols.sell,
        "route": "Report/ItemSales"
      },
      {
        "type": "item",
        "label": "Stok Barang",
        "icon": Symbols.inventory_2,
        "route": "Report/StockInventory"
      }
    ]
  },
  {
    "type": "expandable",
    "label": "Akunting",
    "icon": Symbols.calculate,
    "child": [
      {
        "type": "item",
        "label": "Data Pengeluaran",
        "icon": Symbols.edit_square,
        "route": "Accounting/ExpenditureData"
      },
      {
        "type": "item",
        "label": "Laba / Rugi",
        "icon": Symbols.bar_chart_4_bars,
        "route": "Accounting/Profit-Loss"
      },
    ]
  },
  {
    "type": "item",
    "label": "Profile",
    "icon": Symbols.account_circle,
    "route": "Profile",
  },
  {"type": "section", "label": "General"},
  {
    "type": "item",
    "label": "Settings",
    "icon": Symbols.settings,
    "route": "Settings"
  },
  {
    "type": "item",
    "label": "Logout",
    "icon": Symbols.logout,
    "action": (BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 7,
                ),
                child: Text("Yakin anda keluar dari aplikasi?"),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Yes'),
              onPressed: () {
                SharedPreferences.getInstance().then((pref) {
                  pref.remove("isLoggedIn");
                  pref.remove("loggedUserName");
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("login", (r) => false);
                });
              },
            ),
          ],
        ),
      );
    },
  },
];

class SeparatorWidget extends StatelessWidget {
  const SeparatorWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MainAppDrawer extends StatefulWidget {
  MainAppDrawer(
      {super.key, required this.scaffold, required this.rootNavigator});

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<NavigatorState> rootNavigator;

  String currentRoute = "Dashboard";

  @override
  State<MainAppDrawer> createState() => MainAppDrawerState();
}

class MainAppDrawerState extends State<MainAppDrawer> {
  void setCurrentNavigation(String route) {
    // setState(() {
    debugPrint("setCurrentNavigation");
    debugPrint(route);
    widget.currentRoute = route;
    // });
  }

  Widget newNavigationList(BuildContext context,
      GlobalKey<NavigatorState> rootNavigator, Map<String, dynamic> data,
      {bool subItem = false}) {
    const RoundedRectangleBorder tileShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(28), bottomRight: Radius.circular(28)));
    const RoundedRectangleBorder subTileShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)));
    const EdgeInsets tileContentPadding = EdgeInsets.only(left: 28, right: 10);
    const EdgeInsets tilePadding = EdgeInsets.only(right: 28);

    switch (data['type']) {
      case "section":
        return SeparatorWidget(label: data['label'] as String);

      case "item":
        {
          Widget tile = ListTile(
            title: Text(data['label']),
            leading: Icon(data['icon']),
            shape: subItem ? subTileShape : tileShape,
            selected: widget.currentRoute == data['route'],
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            contentPadding: tileContentPadding,
            onTap: () {
              if (data['route'] != null) {
                // widget.currentRoute = data['route'];

                Navigator.of(context).pop();
                rootNavigator.currentState!.pushNamed(data['route']);
                // debugPrint(ModalRoute.of(rootNavigator.currentState!.context)!
                //     .settings
                //     .name
                //     .toString());
              } else if (data['action'] != null) {
                data['action'].call(context);
              } else {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${data['label']}: Not Implemented'),
                  ),
                );
              }
            },
          );

          if (subItem) {
            return tile;
          } else {
            return Padding(
              padding: tilePadding,
              child: tile,
            );
          }
        }

      case "expandable":
        {
          return Padding(
            padding: tilePadding,
            child: ExpansionTile(
              title: Text(data['label']),
              leading: Icon(data['icon']),
              shape: tileShape,
              childrenPadding: const EdgeInsets.only(left: 28),
              tilePadding: tileContentPadding,
              initiallyExpanded: widget.currentRoute
                  .startsWith('${data['route'].toString()}/'),
              children: [
                ...(data['child'] as List<Map<String, dynamic>>).map(
                  (e) => newNavigationList(context, rootNavigator, e,
                      subItem: true),
                ),
              ],
            ),
          );
        }

      default:
        throw const FormatException('Invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = const TextStyle(
      fontFamily: 'Lexend',
      fontSize: 18,
      letterSpacing: 1,
    );

    return Drawer(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    widget.scaffold.currentState!.closeDrawer();
                  },
                  icon: const Icon(Symbols.left_panel_close),
                ),
                const SizedBox(width: 16, height: 64),
                Text(
                  'CNPLUS ',
                  style: titleStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'POS',
                  style: titleStyle.copyWith(fontWeight: FontWeight.w800),
                ),
                // Text(
                //   'CNPlus POS',
                //   style: Theme.of(context).textTheme.titleSmall,
                // ),
              ],
            ),
          ),
          ...navigations.map(
            (e) => newNavigationList(context, widget.rootNavigator, e),
          )
        ],
      ),
    );
  }
}
