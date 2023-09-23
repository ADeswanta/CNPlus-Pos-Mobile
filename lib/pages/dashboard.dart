import 'package:cnplus_pos/pages/reciepts/transaction_receipt.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../widgets/navigation_drawer.dart';

class DashboardCard {
  const DashboardCard(this.icon, this.label, this.value,
      [this.backgroundColor = const Color.fromARGB(0, 255, 255, 255)]);

  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
}

const List<DashboardCard> dashboardCards = [
  DashboardCard(
      Symbols.local_shipping, "Terjual hari ini", "0 pcs", Color(0xFFFEC14B)),
  DashboardCard(Symbols.wallet, "Target harian", "0%", Color(0xFF365EED)),
  DashboardCard(Symbols.emergency_home, "Stok akan habis", "29 barang",
      Color(0xFFFE3C54)),
  DashboardCard(Symbols.pie_chart, "Target bulanan", "0%", Color(0xFF8298AC)),
];

class SeparatorWidget extends StatelessWidget {
  const SeparatorWidget(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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

class DashboardPage extends StatefulWidget {
  DashboardPage(this.scaffold, this.navigationDrawer, this.routeObserver,
      {super.key});

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;
  final RouteObserver<PageRoute> routeObserver;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var onPop = () {};

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
  //   // widget.navigationDrawer.currentState
  //   //     ?.setCurrentNavigation(ModalRoute.of(context)!.settings.name!);
  //   onPop = () {
  //     debugPrint(widget.navigationDrawer.currentState.toString());
  //   };
  // }

  // @override
  // void didPop() {
  //   debugPrint("didPop: ${ModalRoute.of(context)!.settings.name}");
  //   onPop();
  //   // widget.navigationDrawer.currentState!
  //   //     .setCurrentNavigation(ModalRoute.of(context)!.settings.name!);
  // }

  @override
  Widget build(BuildContext context) {
    // debugPrint("we're in dashboard");
    // widget.navigationDrawer.currentState?.setCurrentNavigation("Dashboard");
    // debugPrint(ModalRoute.of(context)!.settings.name);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Dashboard"),
        leading: IconButton(
          onPressed: () {
            widget.scaffold.currentState!.openDrawer();
          },
          icon: const Icon(Symbols.menu),
        ),
        actions: [
          IconButton(
            onPressed: () {
              scaffoldKey.currentState!.openEndDrawer();
            },
            icon: const Icon(Symbols.notifications),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('Profile');
            },
            icon: const Icon(Symbols.account_circle),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            AppBar(
              title: const Text("Notifications"),
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () {
                    scaffoldKey.currentState!.closeEndDrawer();
                  },
                  icon: const Icon(Symbols.close),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: const [
                  SeparatorWidget("Stok Opname"),
                  ListTile(title: Text("Belum ada stok opname terbaru.")),
                  SeparatorWidget("Retur"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          ...dashboardCards.map(
            (DashboardCard card) {
              return Card(
                elevation: 0,
                color: card.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        card.icon,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.value,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            card.label,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // FilledButton.tonal(
          //     onPressed: () {
          //       printReceipt();
          //     },
          //     child: Text("Print Test"))
        ],
      ),
    );
  }
}
