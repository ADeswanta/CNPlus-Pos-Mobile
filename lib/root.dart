import 'package:cnplus_pos/pages/daily_sales.dart';
import 'package:cnplus_pos/pages/expenditure_data.dart';
import 'package:cnplus_pos/pages/item_sales.dart';
import 'package:cnplus_pos/pages/profile.dart';
import 'package:cnplus_pos/pages/profit_and_loss.dart';
import 'package:cnplus_pos/pages/report_summary.dart';
import 'package:cnplus_pos/pages/settings.dart';
import 'package:cnplus_pos/pages/shopping_cart.dart';
import 'package:cnplus_pos/pages/stock_inventory.dart';
import 'package:cnplus_pos/pages/transaction_report.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './widgets/navigation_drawer.dart';

import './pages/dashboard.dart';
import './pages/pos.dart';
import './pages/pos_checkout.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final navigationDrawerKey = GlobalKey<MainAppDrawerState>();

  @override
  Widget build(BuildContext context) {
    // final NavigatorObserver navigatorObserver = NavigatorObserver();
    final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

    // navigatorObserver.didPop((_) {
    //   debugPrint("didPop");
    // });

    // if (!checkAuthentication(context)) {
    //   debugPrint("Go to login");
    //   return const Center();
    // }

    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      builder: (context, widget) {
        return WillPopScope(
          onWillPop: () async {
            debugPrint('onWillPop');
            debugPrint(rootNavigatorKey.currentState!.widget.pages.toString());
            if (rootNavigatorKey.currentState != null &&
                rootNavigatorKey.currentState!.canPop()) {
              rootNavigatorKey.currentState!.pop();
              return false;
            }
            return true;
          },
          child: Scaffold(
            key: scaffoldKey,
            drawer: MainAppDrawer(
              key: navigationDrawerKey,
              scaffold: scaffoldKey,
              rootNavigator: rootNavigatorKey,
            ),
            body: Navigator(
              key: rootNavigatorKey,
              initialRoute: 'Dashboard',
              observers: [routeObserver],
              // pages: [Page()],
              onGenerateRoute: (RouteSettings settings) {
                late Widget page;

                page = switch (settings.name) {
                  "Dashboard" => DashboardPage(
                      scaffoldKey, navigationDrawerKey, routeObserver),
                  "POS" =>
                    POSPage(scaffoldKey, navigationDrawerKey, routeObserver),
                  "POS/Checkout" => CheckoutPage(),
                  "Report/Summary" =>
                    ReportSummaryPage(scaffoldKey, navigationDrawerKey),
                  "Report/DailySales" =>
                    DailySalesPage(scaffoldKey, navigationDrawerKey),
                  "Report/Transactions" =>
                    TransactionReportPage(scaffoldKey, navigationDrawerKey),
                  "Report/ItemSales" =>
                    ItemSalesPage(scaffoldKey, navigationDrawerKey),
                  "Report/StockInventory" =>
                    StockInventoryPage(scaffoldKey, navigationDrawerKey),
                  "Accounting/ExpenditureData" =>
                    ExpenditureDataPage(scaffoldKey, navigationDrawerKey),
                  "Accounting/Profit-Loss" =>
                    ProfitAndLossPage(scaffoldKey, navigationDrawerKey),
                  "Profile" => ProfilePage(scaffoldKey, navigationDrawerKey),
                  "Settings" => SettingsPage(scaffoldKey, navigationDrawerKey),
                  _ => throw Exception("Invalid Route")
                };

                return MaterialPageRoute(
                  builder: (context) {
                    // debugPrint(ModalRoute.of(context)!.settings.toString());
                    return page;
                  },
                  settings: settings,
                );

                // return PageRouteBuilder(
                //   pageBuilder: (context, _, __) {
                //     // debugPrint(ModalRoute.of(context)!.settings.toString());
                //     return page;
                //   },
                //   settings: settings,
                //   transitionDuration: Duration.zero,
                //   reverseTransitionDuration: Duration.zero,
                // );
              },
            ),
          ),
        );
      },
    );
  }
}
