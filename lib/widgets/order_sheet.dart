import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import 'package:snapping_sheet_2/snapping_sheet.dart';

import '../utils.dart';
import '../pages/shopping_cart.dart';
import './spin_button.dart';

class OrderItem extends StatefulWidget {
  const OrderItem(this.data,
      {super.key, this.deletable = true, this.editable = true});

  final Cart data;
  final bool deletable;
  final bool editable;

  @override
  State<OrderItem> createState() => OrderItemState();
}

class OrderItemState extends State<OrderItem> {
  final GlobalKey<SpinButtonState> spinButtonKey = GlobalKey<SpinButtonState>();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final data = widget.data;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: data.quantity,
            builder: (context, val, child) {
              if (widget.deletable) {
                return IconButton(
                  onPressed: () => cart.removeProduct(data.product.id),
                  icon: const Icon(Symbols.delete),
                );
              }
              return const SizedBox();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 60,
              height: 60,
              decoration: const ShapeDecoration(
                color: Colors.cyan,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.product.name),
                Row(
                  children: [
                    Text(
                      Utils.convertToIDR(data.product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      (data.product.unitType != '')
                          ? '/${data.product.unitType}'
                          : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<int>(
                    valueListenable: data.quantity,
                    builder: (context, val, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widget.editable
                              ? SpinButton(
                                  key: spinButtonKey,
                                  value: val,
                                  increaseCallback: () =>
                                      cart.increaseQuantity(data.product.id),
                                  decreaseCallback: () =>
                                      cart.decreaseQuantity(data.product.id),
                                )
                              : Text("Qty: $val"),
                          Text(
                            Utils.convertToIDR(data.product.price * val),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSheet extends StatefulWidget {
  const OrderSheet({super.key});

  // final List<Map<String, dynamic>> productCart;

  @override
  State<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<OrderSheet> {
  final snappingSheetController = SnappingSheetController();
  final _myScrollController = ScrollController();
  bool isSheetExpanded = false;
  bool isSheetHide = false;

  void hideSheet() {
    snappingSheetController.snapToPosition(const SnappingPosition.factor(
      positionFactor: 0.0,
      grabbingContentOffset: GrabbingContentOffset.top,
    ));
  }

  void expandSheet([bool full = false]) {
    if (full) {
      snappingSheetController.snapToPosition(const SnappingPosition.factor(
        positionFactor: 1.0,
        grabbingContentOffset: GrabbingContentOffset.bottom,
      ));
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = 56;

    return SnappingSheet(
      controller: snappingSheetController,
      grabbingHeight: headerHeight,
      grabbing: Container(
        height: headerHeight,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: !isSheetExpanded
                ? const BorderRadius.vertical(top: Radius.circular(28))
                : null,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.2),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (!isSheetHide) {
                        hideSheet();
                      } else {
                        expandSheet(true);
                      }
                    },
                    icon: isSheetHide
                        ? const Icon(Symbols.expand_less)
                        : const Icon(Symbols.expand_more),
                  ),
                  Text(
                    "Active Orders",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                      width: 32,
                      height: 24,
                      // padding: EdgeInsets.all(4),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(child: Consumer<CartProvider>(
                          builder: (context, provider, widget) {
                        return Text(
                          '${provider.cart.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        );
                      })))
                ],
              ),
              Consumer<CartProvider>(
                builder: (context, provider, widget) {
                  return Visibility(
                    visible: !isSheetHide && provider.cart.isNotEmpty,
                    child: TextButton.icon(
                      onPressed: () {
                        provider.clearAllCarts();
                        hideSheet();
                      },
                      icon: const Icon(Symbols.clear_all),
                      label: const Text("Clear All"),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
      onSheetMoved: (posData) => setState(() {
        isSheetExpanded = (posData.relativeToSnappingPositions == 1);
        isSheetHide = (posData.relativeToSnappingPositions == 0);
      }),
      lockOverflowDrag: true,
      sheetBelow: SnappingSheetContent(
        childScrollController: _myScrollController,
        draggable: (details) => true,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Consumer<CartProvider>(
            builder: (context, provider, widget) {
              if (provider.cart.isEmpty) {
                return const Center(child: Text('Your Cart is Empty'));
              } else {
                return Stack(alignment: Alignment.bottomCenter, children: [
                  ListView(
                    padding: const EdgeInsets.only(
                      bottom: 120,
                    ),
                    controller: _myScrollController,
                    children: [
                      ...provider.cart.map((data) => OrderItem(data)),
                    ],
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total"),
                                  ValueListenableBuilder<int>(
                                    valueListenable: provider.total,
                                    builder: (context, value, widget) {
                                      return Text(
                                        Utils.convertToIDR(value),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24,
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  IconButton.outlined(
                                    onPressed: () {
                                      debugPrint("print");
                                    },
                                    icon: const Icon(Symbols.print),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SizedBox(
                                      height: 40,
                                      child: FilledButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              "POS/Checkout");
                                        },
                                        child: const Text("Checkout"),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ]);
              }
            },
          ),
        ),
      ),
    );
  }
}
