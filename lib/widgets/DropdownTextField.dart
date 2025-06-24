import 'package:flutter/material.dart';

class DropdownTextField extends StatefulWidget {
  final List<String> items;
  final String label;
  final TextEditingController controller;
  final VoidCallback? onValidate;

  const DropdownTextField(
      {super.key,
      required this.items,
      required this.label,
      required this.controller,
      this.onValidate});

  void validate() {
    if (onValidate != null) {
      onValidate!();
    }
  }

  @override
  _DropdownTextFieldState createState() => _DropdownTextFieldState();
}

class _DropdownTextFieldState extends State<DropdownTextField> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  String? _selectedItem;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _validateInput();
        _removeOverlay();
      }
    });
  }

  void _validateInput() {
    final input = widget.controller.text.trim();
    String? matchedItem;

    // Find a case-insensitive match
    for (var item in widget.items) {
      if (item.toLowerCase() == input.toLowerCase()) {
        matchedItem = item;
        break;
      }
    }

    if (input.isNotEmpty && matchedItem == null) {
      setState(() {
        widget.controller.clear();
        _selectedItem = null;
      });
    } else if (input.isNotEmpty && matchedItem != null) {
      setState(() {
        widget.controller.text = matchedItem!;
        _selectedItem = matchedItem;
      });
    } else {
      setState(() {
        _selectedItem = null;
      });
    }
    if (widget.onValidate != null) {
      widget.onValidate!();
    }
  }

  void _updateDropdownMenu() {
    _removeOverlay();

    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final input = widget.controller.text.trim().toLowerCase();
    final filteredItems = input.isEmpty
        ? widget.items
        : widget.items
            .where((item) => item.toLowerCase().contains(input))
            .toList();

    if (filteredItems.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        left: position.dx,
        top: position.dy + size.height,
        child: Material(
          elevation: 4.0,
          color: const Color(0xffd9dcd6),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: filteredItems.map((String item) {
                return ListTile(
                  title: Text(
                    item,
                    style: const TextStyle(
                      color: Color(0xff16425B),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget.controller.text = item;
                      _selectedItem = item;
                      _focusNode.unfocus();
                      _removeOverlay();
                    });
                    if (widget.onValidate != null) {
                      widget.onValidate!();
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {}); // Update icon state
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != '')
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 4),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff16425B),
              ),
            ),
          ),
        SizedBox(
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffd9dcd6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xff16425B)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: TextField(
                key: _textFieldKey,
                controller: widget.controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: Color(0xff16425B),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _overlayEntry != null
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: const Color(0xff16425B),
                    ),
                    onPressed: () {
                      if (_overlayEntry != null) {
                        _removeOverlay();
                      } else {
                        _updateDropdownMenu();
                      }
                    },
                  ),
                ),
                onTap: _updateDropdownMenu,
                onChanged: (value) {
                  setState(() {
                    _selectedItem = null;
                    _updateDropdownMenu();
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
