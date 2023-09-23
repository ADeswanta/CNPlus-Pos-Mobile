import 'package:cnplus_pos/utils.dart';
import 'package:cnplus_pos/widgets/printer_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/navigation_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(
    this.scaffold,
    this.navigationDrawer, {
    super.key,
  });

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class SettingsItem extends StatefulWidget {
  const SettingsItem(
      {super.key,
      required this.name,
      required this.title,
      required this.defaultValue,
      required this.type,
      this.customType,
      this.valueGetter,
      this.dialogBuilder});

  final String name;
  final String title;
  final dynamic defaultValue;
  final String type;
  final String? customType;
  final String Function(dynamic)? valueGetter;
  final Widget Function(BuildContext)? dialogBuilder;

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  dynamic value;

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue;

    SharedPreferences.getInstance().then((pref) {
      value = switch (widget.type) {
        "string" => pref.getString(widget.name) ?? widget.defaultValue,
        "number" ||
        "currency" =>
          pref.getInt(widget.name) ?? widget.defaultValue,
        "custom" => switch (widget.customType) {
            "string" => pref.getString(widget.name),
            "stringList" => pref.getStringList(widget.name),
            _ => pref.get(widget.name)
          },
        _ => pref.getString(widget.name) ?? widget.defaultValue
      };
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String textValue = switch (widget.type) {
      "currency" => Utils.convertToIDR(value).toString(),
      "custom" => widget.valueGetter?.call(value) ?? "N/A",
      _ => value.toString()
    };

    return ListTile(
      title: Text(widget.title),
      subtitle: Text(textValue),
      isThreeLine: true,
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: widget.dialogBuilder ??
              (_) {
                var decoration = InputDecoration(
                  labelText: widget.title,
                  border: OutlineInputBorder(),
                  prefix: widget.type == "currency" ? Text("Rp ") : null,
                );

                Widget inputWidget = switch (widget.type) {
                  "string" => TextFormField(
                      decoration: decoration,
                      onChanged: (val) {
                        value = val;
                      },
                      initialValue: value,
                      maxLines: null,
                    ),
                  "number" => TextFormField(
                      decoration: decoration,
                      onChanged: (val) {
                        value = int.parse(val);
                      },
                      initialValue: value,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [NumberFormatter()],
                    ),
                  "currency" => TextFormField(
                      decoration: decoration,
                      onChanged: (val) {
                        value = int.parse(val.replaceAll(',', ''));
                      },
                      initialValue:
                          NumberFormat('###,###,###').format(value).toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: const [IDRFormatter()],
                    ),
                  _ => Text(widget.defaultValue.toString())
                };
                return AlertDialog(
                  contentPadding: EdgeInsets.all(20),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   widget.name,
                        //   style: Theme.of(context).dialogTheme.titleTextStyle,
                        //   textAlign: TextAlign.start,
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        inputWidget
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('Cancel'),
                      onPressed: () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();

                        debugPrint(pref.getKeys().join(', '));
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('Apply'),
                      onPressed: () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();

                        switch (widget.type) {
                          case "string":
                            pref.setString(widget.name, value);
                          case "number":
                          case "currency":
                            pref.setInt(widget.name, value);
                        }

                        debugPrint(pref.getKeys().join(', '));
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                    ),
                  ],
                );
              },
        );
      },
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          onPressed: () {
            widget.scaffold.currentState!.openDrawer();
          },
          icon: const Icon(Symbols.menu),
        ),
      ),
      // CONTENT HERE:
      body: ListView(
        children: [
          // ListTile(
          //   title: Text("Current Thermal Printer"),
          //   subtitle: SharedPreferences.getInstance().then((value) {}),
          // ),
          SettingsItem(
            name: "currentPrinter",
            title: "Current Thermal Printer",
            defaultValue: null,
            type: "custom",
            customType: "stringList",
            valueGetter: (value) {
              debugPrint("valueGetter - value:");
              debugPrint(value.toString());
              // String result = "N/A";
              // if (value == null) {
              //   return result;
              // }

              // FlutterBlue.instance.connectedDevices.then((devices) {
              //   if (devices.isNotEmpty) {
              //     result = devices
              //         .firstWhere((element) => element.id.toString() == value)
              //         .name;
              //     debugPrint("valueGetter - result (1):");
              //     debugPrint(result);
              //   }
              // });

              // debugPrint("valueGetter - result (2):");
              // return result;
              if (value == null || value.isEmpty) {
                return "N/A";
              }

              //return "unkown";
              return value.elementAt(1);
            },
            dialogBuilder: (context) {
              return Dialog.fullscreen(child: PrintSelectorPage());
            },
          ),
          SettingsItem(
            name: "targetHarian",
            title: "Target Harian",
            defaultValue: 5000000,
            type: "currency",
          ),
          SettingsItem(
            name: "targetBulanan",
            title: "Target Bulanan",
            defaultValue: 10000000,
            type: "currency",
          ),
          SettingsItem(
            name: "pajak",
            title: "Pajak",
            defaultValue: 1000,
            type: "currency",
          ),
          SettingsItem(
            name: "headerStruk",
            title: "Header Struk",
            defaultValue:
                "Jl. Rajawali Blok D No. 20\nTegal - Pacul\n0858-6903-6028",
            type: "string",
          ),
          SettingsItem(
            name: "footerStruk",
            title: "Footer Struk",
            defaultValue: "Terima Kasih dan Selamat Datang Kembali",
            type: "string",
          ),
        ],
      ),
    );
  }
}
