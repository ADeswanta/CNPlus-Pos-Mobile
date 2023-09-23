import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintSelectorPage extends StatefulWidget {
  const PrintSelectorPage({super.key});

  @override
  State<PrintSelectorPage> createState() => PrintSelectorPageState();
}

class PrintSelectorPageState extends State<PrintSelectorPage> {
  FlutterBlue bluetoothPrint = FlutterBlue.instance;
  BluetoothDevice? _device;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      List<String>? pref = prefs.getStringList('currentPrinter');
      String? deviceAddress =
          pref != null && pref!.isNotEmpty ? pref!.elementAt(0) : null;
      if (deviceAddress != null) {
        setState(() {
          bluetoothPrint.connectedDevices.then((value) {
            if (value.isNotEmpty) {
              _device = value.firstWhere(
                  (element) => element.id.toString() == deviceAddress);
            }
          });
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bluetoothPrint.connectedDevices.then((state) {
        debugPrint('cur device status: $state');

        if (state.isNotEmpty) {
          _device = state.first;
        }
      });

      bluetoothPrint.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          print('${r.device.name} found! rssi: ${r.rssi}');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Printer"),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Symbols.close),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Symbols.check),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          return FloatingActionButton.extended(
            isExtended: !snapshot.data!,
            onPressed: !snapshot.data!
                ? () {
                    debugPrint("Scan");
                    bluetoothPrint.startScan(timeout: Duration(seconds: 4));
                  }
                : null,
            icon: !snapshot.data!
                ? Icon(Symbols.search)
                : SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator()),
            label: Text("Scan"),
          );
        },
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: bluetoothPrint.scanResults,
        initialData: const [],
        builder: (c, snapshot) => Column(
          children: [
            ...snapshot.data!.map((d) {
              if (d.device.name != "") {
                return ListTile(
                  title: Text(d.device.name),
                  subtitle: Text(d.device.id.toString()),
                  onTap: () {
                    SharedPreferences.getInstance().then(
                      (value) => value.setStringList(
                        'currentPrinter',
                        [d.device.id.toString(), d.device.name],
                      ),
                    );
                    setState(() {
                      _device = d.device;
                    });
                    d.device.connect();
                  },
                  trailing: _device != null && _device!.id == d.device.id
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                        )
                      : null,
                );
              } else {
                return SizedBox();
              }
            }).toList(),
          ],
        ),
      ),
    );
  }
}
