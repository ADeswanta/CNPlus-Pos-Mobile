import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.label, this.prefix});

  final String label;
  final Widget? prefix;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  FocusNode focusNode = FocusNode();
  bool _isFocus = false;
  bool _isEmpty = true;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() => setState(() {
          _isFocus = focusNode.hasFocus;
        }));
    _controller.addListener(() => setState(() {
          _isEmpty = _controller.text.isEmpty;
        }));
  }

  @override
  Widget build(BuildContext context) {
    const BoxConstraints iconConstraints = BoxConstraints(minWidth: 64);
    return TextField(
      focusNode: focusNode,
      controller: _controller,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        prefixIconConstraints: iconConstraints,
        suffixIconConstraints: iconConstraints,
        prefixIcon: const Icon(Symbols.search),
        suffixIcon: Visibility(
          visible: _isFocus && !_isEmpty,
          child: IconButton(
            icon: const Icon(Symbols.clear),
            onPressed: () => _controller.clear(),
          ),
        ),
        hintText: widget.label,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
        ),
      ),
    );
  }
}
