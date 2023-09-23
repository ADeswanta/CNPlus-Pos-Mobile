import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:cnplus_pos/pages/shopping_cart.dart';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatNumber(int value) {
  return NumberFormat('###,###,###').format(value);
}

class BluePrint {
  BluePrint({this.chunkLen = 512});

  final int chunkLen;
  final _data = List<int>.empty(growable: true);

  void add(List<int> data) {
    _data.addAll(data);
  }

  List<List<int>> getChunks() {
    final chunks = List<List<int>>.empty(growable: true);
    for (var i = 0; i < _data.length; i += chunkLen) {
      chunks.add(_data.sublist(i, min(i + chunkLen, _data.length)));
    }
    return chunks;
  }

  Future<void> printData(BluetoothDevice device) async {
    final data = getChunks();
    final characs = await _getCharacteristics(device);
    for (var i = 0; i < characs.length; i++) {
      if (await _tryPrint(characs[i], data)) {
        break;
      }
    }
  }

  Future<bool> _tryPrint(
    BluetoothCharacteristic charac,
    List<List<int>> data,
  ) async {
    for (var i = 0; i < data.length; i++) {
      try {
        await charac.write(data[i]);
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  Future<List<BluetoothCharacteristic>> _getCharacteristics(
    BluetoothDevice device,
  ) async {
    final services = await device.discoverServices();
    final res = List<BluetoothCharacteristic>.empty(growable: true);
    for (var i = 0; i < services.length; i++) {
      res.addAll(services[i].characteristics);
    }
    return res;
  }
}

void printReceipt(
  BuildContext context,
  String customerName,
  int subTotal,
  int discountPrice,
  int grandTotal,
  int paymentNominal,
  List<Cart> carts,
) async {
  SharedPreferences.getInstance().then((value) async {
    List<String>? current = value.getStringList("currentPrinter");

    if (current == null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: 7,
                  ),
                  child: Text("Thermal Printer not connected"),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    FlutterBlue.instance.connectedDevices.then((value) async {
      if (value.isEmpty) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 7,
                    ),
                    child: Text("Invalid printer"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      showDialog(
        barrierDismissible: false,
        context: context,
        useRootNavigator: false,
        builder: (_) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                Container(
                  margin: EdgeInsets.only(
                    left: 7,
                  ),
                  child: Text("Printing receipt..."),
                ),
              ],
            ),
          );
        },
      );

      BluetoothDevice _device =
          value.firstWhere((dev) => dev.id.toString() == current.first);

      final gen = Generator(PaperSize.mm58, await CapabilityProfile.load());
      final printer = BluePrint();

      final ByteData data = await rootBundle.load('assets/logo-black.png');
      final Uint8List buf = data.buffer.asUint8List();
      final Image image = decodeImage(buf)!;

      DateTime now = new DateTime.now();

      // printer.add(gen.qrcode('https://altospos.com'));
      printer.add(gen.image(image));
      printer.add(gen.text(
        customerName,
        styles: PosStyles(align: PosAlign.center),
      ));
      printer.add(gen.feed(1));
      printer.add(gen.text(
        DateFormat('EEEE, dd MMMM yyyy').format(now),
        styles: PosStyles(align: PosAlign.center),
      ));
      printer.add(gen.text(
        DateFormat('hh:mm:ss').format(now),
        styles: PosStyles(align: PosAlign.center),
      ));
      printer.add(gen.feed(1));
      for (Cart cart in carts) {
        printer.add(gen.row([
          PosColumn(
            text: cart.product.name,
            width: 6,
          ),
          PosColumn(
            text: cart.quantity.value.toString(),
            width: 1,
            styles: PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: "*",
            width: 1,
            styles: PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: formatNumber(cart.product.price),
            width: 4,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]));
        printer.add(gen.row([
          PosColumn(
            text: "",
            width: 8,
          ),
          PosColumn(
            text: formatNumber(cart.product.price * cart.quantity.value),
            width: 4,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]));
      }
      printer.add(gen.feed(1));
      printer.add(gen.row([
        PosColumn(
          text: 'Subtotal',
          width: 9,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: formatNumber(subTotal),
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]));
      printer.add(gen.row([
        PosColumn(
          text: 'Diskon',
          width: 9,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '-${formatNumber(discountPrice)}',
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]));
      printer.add(gen.row([
        PosColumn(
          text: 'Pajak',
          width: 9,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '0.000',
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]));
      printer.add(gen.feed(1));
      printer.add(gen.row([
        PosColumn(
          text: 'Total',
          width: 9,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            // width: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: formatNumber(grandTotal),
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            // width: PosTextSize.size2,
          ),
        ),
      ]));
      printer.add(gen.row([
        PosColumn(
          text: 'Bayar',
          width: 9,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: formatNumber(paymentNominal),
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]));
      printer.add(gen.row([
        PosColumn(
          text: 'Kembalian',
          width: 9,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: formatNumber(paymentNominal - grandTotal),
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]));
      printer.add(gen.feed(1));
      printer.add(gen.text(
        'Terimakasih atas Kunjungannya',
        styles: PosStyles(align: PosAlign.center),
      ));
      printer.add(gen.feed(3));

      await printer.printData(_device!);

      Navigator.of(context).pop();
    });
  });
}
