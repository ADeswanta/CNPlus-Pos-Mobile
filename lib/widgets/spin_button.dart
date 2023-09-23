import 'package:flutter/material.dart';

class SpinButton extends StatefulWidget {
  SpinButton({
    super.key,
    required this.increaseCallback,
    required this.decreaseCallback,
    required this.value,
    this.minValue = 1,
    this.maxValue = 10,
  });

  static _default(_) {}

  final int value;
  final int minValue;
  final int maxValue;
  final VoidCallback increaseCallback;
  final VoidCallback decreaseCallback;

  @override
  State<SpinButton> createState() => SpinButtonState();
}

class SpinButtonState extends State<SpinButton> {
  // int counter = 0;

  // void setValue(int value) => setState(() => counter = value);

  // @override
  // void initState() {
  //   super.initState();
  //   counter = widget.initialValue;
  // }

  @override
  Widget build(BuildContext context) {
    // debugPrint(counter.toString());

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(99)),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            onPressed:
                widget.value > widget.minValue ? widget.decreaseCallback : null,
          ),
          SizedBox(
            width: 24,
            child: Text(
              widget.value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            onPressed:
                widget.value < widget.maxValue ? widget.increaseCallback : null,
          ),
        ],
      ),
    );
  }
}
