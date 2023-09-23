// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_symbols_icons/symbols.dart';
// import 'package:top_modal_sheet/top_modal_sheet.dart';

import './pages/dashboard.dart';
import './pages/transaksi_pos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'CNPlus POS',
        theme: ThemeData(
          // appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          colorScheme: lightColorScheme ??
              ColorScheme.fromSeed(seedColor: const Color(0xFF0FA883)),
          useMaterial3: true,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary),
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ??
              ColorScheme.fromSeed(seedColor: const Color(0xFF0FA883)),
          useMaterial3: true,
        ),
        // home: const RootPage(title: 'Dashboard'),
        initialRoute: '/',
        routes: {
          '/': (context) => const RootPage(),
          '/login': (context) => Container(),
        },
      );
    });
  }
}

enum RouteIndex { dashboard, transaksiPOS }

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String route;

  @override
  State<RootPage> createState() => _RootPageState();
}

class AppDrawerList {
  const AppDrawerList(this.label, this.icon);

  final String label;
  final Widget icon;
}

class AppDrawerSection {
  const AppDrawerSection(this.label);

  final String label;
}

const navigations = [
  {"type": "section", "label": "Welcome"},
  {
    "type": "item",
    "label": "Dashboard",
    "icon": Symbols.dashboard,
    "route": "Dashboard"
  },
  {
    "type": "expandable",
    "label": "Transaksi",
    "icon": Symbols.receipt_long,
    "child": [
      {
        "type": "item",
        "label": "POS",
        "icon": Symbols.point_of_sale,
        "route": "Transaksi/POS"
      },
      {"type": "item", "label": "Pesanan", "icon": Symbols.local_mall}
    ]
  },
  {
    "type": "expandable",
    "label": "Stok Peminjaman",
    "icon": Symbols.book,
    "child": [
      {"type": "item", "label": "POS", "icon": Symbols.point_of_sale},
      {"type": "item", "label": "Pesanan", "icon": Symbols.local_mall}
    ]
  },
  {"type": "item", "label": "Laporan", "icon": Symbols.monitoring},
  {"type": "item", "label": "Akunting", "icon": Symbols.calculate},
  {"type": "item", "label": "Master Data", "icon": Symbols.tune},
  {"type": "item", "label": "Profile", "icon": Symbols.account_circle},
  {"type": "section", "label": "General"},
  {"type": "item", "label": "Settings", "icon": Symbols.settings},
  {
    "type": "item",
    "label": "Logout",
    "icon": Symbols.logout,
    "route": "/login"
  },
];

class SeparatorWidget extends StatelessWidget {
  const SeparatorWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        child: Text(label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            )));
  }
}

class _RootPageState extends State<RootPage> {
  Widget newNavigationList(BuildContext context,
      GlobalKey<NavigatorState> rootNavigator, Map<String, dynamic> data,
      {bool subItem = false}) {
    String currentRoute = "Dashboard";
    const RoundedRectangleBorder tileShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(28), bottomRight: Radius.circular(28)));
    const RoundedRectangleBorder subTileShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)));
    const EdgeInsets tileContentPadding = EdgeInsets.only(left: 28, right: 10);
    const EdgeInsets tilePadding = EdgeInsets.only(right: 28);

    // debugPrint('render');

    switch (data['type']) {
      case "section":
        return SeparatorWidget(label: data['label'] as String);

      case "item":
        {
          Widget tile = ListTile(
              title: Text(data['label']),
              leading: Icon(data['icon']),
              shape: subItem ? subTileShape : tileShape,
              // selected: false,
              selected: currentRoute == data['route'],
              selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
              contentPadding: tileContentPadding,
              onTap: () {
                if (data['route'] != null) {
                  debugPrint(data['route']);

                  // setState(() {
                  //   currentRoute = data['route'];
                  // });

                  Navigator.of(context).pop();
                  rootNavigator.currentState!.pushNamed(data['route']);
                }
              });

          if (subItem) {
            return tile;
          } else {
            return Padding(padding: tilePadding, child: tile);
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
                  children: [
                    ...(data['child'] as List<Map<String, dynamic>>).map((e) =>
                        newNavigationList(context, rootNavigator, e,
                            subItem: true))
                  ]));
        }

      default:
        throw const FormatException('Invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();

    return WillPopScope(
        onWillPop: () async {
          debugPrint('onWillPop');
          debugPrint(ModalRoute.of(rootNavigatorKey.currentState!.context)!
              .settings
              .name
              .toString());
          // debugPrint(Navigator.of(context).canPop().toString());
          // debugPrint(rootNavigatorKey.currentState!.canPop().toString());
          if (rootNavigatorKey.currentState != null &&
              rootNavigatorKey.currentState!.canPop()) {
            rootNavigatorKey.currentState!.pop();
            return false;
          }
          return true;
        },
        child: Scaffold(
            key: scaffoldKey,
            drawer: Drawer(
                child: ListView(
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              scaffoldKey.currentState!.closeDrawer();
                            },
                            icon: const Icon(Symbols.left_panel_close)),
                        const SizedBox(width: 16, height: 64),
                        Text(
                          'CNPlus POS',
                          style: Theme.of(context).textTheme.titleSmall,
                        )
                      ],
                    )),
                ...navigations
                    .map((e) => newNavigationList(context, rootNavigatorKey, e))
              ],
            )
                // children: [
                //   Padding(
                //       padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                //       child: Row(
                //         children: [
                //           IconButton(
                //               onPressed: () {
                //                 scaffoldKey.currentState!.closeDrawer();
                //               },
                //               icon: const Icon(Symbols.left_panel_close)),
                //           Text(
                //             'CNPlus POS',
                //             style: Theme.of(context).textTheme.titleSmall,
                //           )
                //         ],
                //       )),
                //   ...navigationList(context, navigations),
                //   // ...drawerItems.map((dynamic list) {
                //   //   if (list is AppDrawerList) {
                //   //     return NavigationDrawerDestination(
                //   //         label: Text(list.label), icon: list.icon);
                //   //   } else {
                //   //     return Padding(
                //   //         padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
                //   //         child: Text(list.label.toUpperCase(),
                //   //             style: TextStyle(
                //   //               color: Theme.of(context).colorScheme.primary,
                //   //               fontWeight: FontWeight.bold,
                //   //             )));
                //   //   }
                //   // })
                // ],
                ),
            body: Navigator(
              key: rootNavigatorKey,
              initialRoute: 'Dashboard',
              onGenerateRoute: (RouteSettings settings) {
                late Widget page;

                page = switch (settings.name) {
                  "Dashboard" => DashboardPage(scaffold: scaffoldKey),
                  "Transaksi/POS" => TransaksiPOSPage(scaffold: scaffoldKey),
                  _ => throw Exception("Invalid Route")
                };

                return PageRouteBuilder(
                  pageBuilder: (context, _, __) {
                    return page;
                  },
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
              },
            )));
  }
}
