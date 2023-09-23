import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../widgets/navigation_drawer.dart';

class ExpenditureDataPage extends StatefulWidget {
  const ExpenditureDataPage(
    this.scaffold,
    this.navigationDrawer, {
    super.key,
  });

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;

  @override
  State<ExpenditureDataPage> createState() => _ExpenditureDataPageState();
}

class _ExpenditureDataPageState extends State<ExpenditureDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pengeluaran"),
        leading: IconButton(
          onPressed: () {
            widget.scaffold.currentState!.openDrawer();
          },
          icon: const Icon(Symbols.menu),
        ),
      ),
      // CONTENT HERE:
      body: const Center(
        child: Text("Data Pengeluaran"),
      ),
    );
  }
}
