// import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cnplus_pos/pages/profile.dart';
import 'package:cnplus_pos/pages/settings.dart';
import 'package:cnplus_pos/pages/shopping_cart.dart';
import 'package:cnplus_pos/pages/transaction_report.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:top_modal_sheet/top_modal_sheet.dart';

import './widgets/navigation_drawer.dart';

import './root.dart';
import './login.dart';
import './pages/dashboard.dart';
import './pages/pos.dart';
import './pages/pos_checkout.dart';

void main() {
  runApp(const MyApp());
}

// class AppTheme extends ThemeData {

// }

TextTheme headlineFont = const TextTheme(
  displayLarge: TextStyle(fontFamily: 'Lexend'),
  displayMedium: TextStyle(fontFamily: 'Lexend'),
  displaySmall: TextStyle(fontFamily: 'Lexend'),
  headlineLarge: TextStyle(fontFamily: 'Lexend'),
  headlineMedium: TextStyle(fontFamily: 'Lexend'),
  headlineSmall: TextStyle(fontFamily: 'Lexend'),
  titleLarge: TextStyle(fontFamily: 'Lexend'),
  titleMedium: TextStyle(fontFamily: 'Lexend'),
  titleSmall: TextStyle(fontFamily: 'Lexend'),
);

ThemeData appThemeData([bool isDark = false]) {
  Color background = isDark ? Colors.grey.shade900 : Colors.white;
  Color foreground = isDark ? Colors.white : Colors.black;

  return ThemeData(
      fontFamily: 'Inter',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F56A8),
              brightness: isDark ? Brightness.dark : Brightness.light)
          .copyWith(
        background: background,
        surface: background,
      ),
      textTheme: headlineFont,
      drawerTheme: DrawerThemeData(backgroundColor: background));
}

// @AutoRouterConfig(
//   replaceInRouteName: 'Page,Route'
// )
// class AppRouter extends $AppRouter {
//   @override
//   List<AutoRoute> get routes =>
//     AutoRoute(page: RootPage, path: "/"),
//     AutoRoute(page: LoginPage, path: "login"),
//   ];
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // bool? isLoggedIn;
    // SharedPreferences.getInstance().then((value) {
    //   isLoggedIn = value.getBool("isLoggedIn");
    // });
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'CNPlus POS',
        theme: appThemeData(),
        darkTheme: appThemeData(true),
        // initialRoute: isLoggedIn ? '/' : 'login',
        // routerDelegate: AppRouter().delegate(
        //   initialRoutes: [
        //     if (!isSignedIn) LandingScreen(),
        //     if (isSignedIn && !isTnCAccepted) PledgeScreen(),
        //     if (isSignedIn && isTnCAccepted) DashboardScreen(),
        //   ],
        // ),
        home: const MainPage(),
        routes: {
          'home': (context) => const RootPage(),
          'login': (context) => const LoginPage(),
        },
        // builder: (context, child) {
        //   SharedPreferences.getInstance().then((pref) {
        //     bool? result = pref.getBool("result");
        //     // debugPrint(pref.getBool("result").toString());

        //     bool isLoggedIn = result != null && result;

        //     debugPrint(isLoggedIn.toString());
        //     if (!isLoggedIn) {
        //       return const LoginPage();
        //     } else {
        //       return const RootPage();
        //     }
        //   });
        //   return const LoginPage();
        // },
      );
    });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final navigationDrawerKey = GlobalKey<MainAppDrawerState>();

// bool isLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     SharedPreferences.getInstance().then((pref) {
//       bool? result = pref.getBool("isLoggedIn");
//       debugPrint("pref.getBool('isLoggedIn').toString():");
//       debugPrint(pref.getBool("isLoggedIn").toString());

//       bool isLoggedIn = result != null && result;

//       debugPrint("isLoggedIn.toString():");
//       debugPrint(isLoggedIn.toString());
//     });
//   }

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((pref) {
      pref.setStringList("currentPrinter", []);

      bool? result = pref.getBool("isLoggedIn");
      // debugPrint(pref.getBool("result").toString());

      setState(() {
        isLoggedIn = result != null && result;
      });

      debugPrint(isLoggedIn.toString());
      if (!isLoggedIn) {
        Navigator.of(context).pushNamedAndRemoveUntil("login", (r) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil("home", (r) => false);
      }
    });
  }

  // bool isLoggedIn = false;

  // void checkAuthentication(BuildContext context) {
  //   SharedPreferences.getInstance().then((pref) {
  //     bool? result = pref.getBool("result");
  //     // debugPrint(pref.getBool("result").toString());

  //     setState(() {
  //       isLoggedIn = result != null && result;
  //     });

  //     debugPrint(isLoggedIn.toString());
  //     if (!isLoggedIn) {
  //       Navigator.of(context).pushNamedAndRemoveUntil("login", (r) => false);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // // final NavigatorObserver navigatorObserver = NavigatorObserver();
    // final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

    // // navigatorObserver.didPop((_) {
    // //   debugPrint("didPop");
    // // });

    // // if (!checkAuthentication(context)) {
    // //   debugPrint("Go to login");
    // //   return const Center();
    // // }

    // // checkAuthentication(context);

    // // debugPrint("status.toString()");
    // // debugPrint(status.toString());

    // return ChangeNotifierProvider(
    //   create: (_) => CartProvider(),
    //   builder: (context, widget) {
    //     return WillPopScope(
    //       onWillPop: () async {
    //         debugPrint('onWillPop');
    //         debugPrint(rootNavigatorKey.currentState!.widget.pages.toString());
    //         if (rootNavigatorKey.currentState != null &&
    //             rootNavigatorKey.currentState!.canPop()) {
    //           rootNavigatorKey.currentState!.pop();
    //           return false;
    //         }
    //         return true;
    //       },
    //       child: Scaffold(
    //         key: scaffoldKey,
    //         drawer: MainAppDrawer(
    //           key: navigationDrawerKey,
    //           scaffold: scaffoldKey,
    //           rootNavigator: rootNavigatorKey,
    //         ),
    //         body: Navigator(
    //           key: rootNavigatorKey,
    //           initialRoute: 'Dashboard',
    //           observers: [routeObserver],
    //           // pages: [Page()],
    //           onGenerateRoute: (RouteSettings settings) {
    //             late Widget page;

    //             page = switch (settings.name) {
    //               "Dashboard" => DashboardPage(
    //                   scaffoldKey, navigationDrawerKey, routeObserver),
    //               "POS" =>
    //                 POSPage(scaffoldKey, navigationDrawerKey, routeObserver),
    //               "POS/Checkout" => CheckoutPage(),
    //               "Report/Transactions" =>
    //                 TransactionReportPage(scaffoldKey, navigationDrawerKey),
    //               "Profile" => ProfilePage(scaffoldKey, navigationDrawerKey),
    //               "Settings" => SettingsPage(scaffoldKey, navigationDrawerKey),
    //               _ => throw Exception("Invalid Route")
    //             };

    //             return MaterialPageRoute(
    //               builder: (context) {
    //                 // debugPrint(ModalRoute.of(context)!.settings.toString());
    //                 return page;
    //               },
    //               settings: settings,
    //             );

    //             // return PageRouteBuilder(
    //             //   pageBuilder: (context, _, __) {
    //             //     // debugPrint(ModalRoute.of(context)!.settings.toString());
    //             //     return page;
    //             //   },
    //             //   settings: settings,
    //             //   transitionDuration: Duration.zero,
    //             //   reverseTransitionDuration: Duration.zero,
    //             // );
    //           },
    //         ),
    //       ),
    //     );
    //   },
    // );

    return Center();
  }
}
