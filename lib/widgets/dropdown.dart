import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class DropdownWidget extends StatefulWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String>? onSelected;

  const DropdownWidget({
    super.key,
    required this.items,
    this.onSelected,
    required this.label,
  });

  @override
  DropdownWidgetState createState() => DropdownWidgetState();
}

class DropdownWidgetState extends State<DropdownWidget> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        DropdownSearch<String>(
          // Customize the dropdown button decoration
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xffd9dcd6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: Color(0xff16425B),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: Color(0xff16425B),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: Color(0xff16425B),
                  width: 2.0,
                ),
              ),
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xff16425B),
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            fit: FlexFit.loose,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xff16425B),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xffd9dcd6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Color(0xff16425B),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xff16425B)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
              ),
            ),
            containerBuilder: (context, popupWidget) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xffd9dcd6),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xff16425B),
                      blurRadius: 8.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: popupWidget,
              );
            },
          ),
          items: (String? filter, _) async => widget.items,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                selected = value;
              });
              widget.onSelected?.call(value);
            }
          },
          selectedItem: selected.isEmpty ? null : selected,
        ),
      ],
    );
  }
}
