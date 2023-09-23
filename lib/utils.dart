import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Utils {
  static String convertToIDR(int value) {
    return 'Rp ${NumberFormat('###,###,###').format(value)}';
  }
}

class NumberFormatter extends TextInputFormatter {
  const NumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == "") {
      return TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: newValue.text.length),
      );
    } else if (int.parse(oldValue.text) == 0) {
      return TextEditingValue(
        text: newValue.text.replaceAll('0', ''),
        selection: TextSelection.collapsed(offset: oldValue.text.length),
      );
    } else {
      return newValue;
    }
  }
}

class IDRFormatter extends TextInputFormatter {
  const IDRFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // debugPrint(oldValue.text);
    // debugPrint(newValue.text);

    if (newValue.text.length > 3) {
      String format = NumberFormat('###,###,###')
          .format(int.parse(newValue.text.replaceAll(',', '')));
      // debugPrint(NumberFormat('###,###,000')
      //     .format(int.parse(newValue.text.replaceAll(',', ''))));
      return TextEditingValue(
        text: format,
        selection: TextSelection.collapsed(offset: format.length),
      );
    } else {
      if (newValue.text == "") {
        return TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: newValue.text.length),
        );
      } else if (int.parse(oldValue.text) == 0 && oldValue.text != "") {
        return TextEditingValue(
          text: newValue.text.replaceAll('0', ''),
          selection: TextSelection.collapsed(offset: oldValue.text.length),
        );
      } else {
        return newValue;
      }
    }
  }
}

class CardNumberFormatter extends TextInputFormatter {
  const CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Add double spaces.
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class NumericalRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;

  NumericalRangeFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min) {
      return TextEditingValue().copyWith(text: min.toString());
    } else {
      return int.parse(newValue.text) > max
          ? TextEditingValue().copyWith(text: max.toString())
          : newValue;
    }
  }
}
