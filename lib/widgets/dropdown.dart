// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';

// class DropdownWidget extends StatefulWidget {
//   final List<String> items;
//   final ValueChanged<String>? onSelected; // Callback for selection changes

//   const DropdownWidget({
//     super.key,
//     required this.items,
//     this.onSelected,
//   });

//   @override
//   DropdownWidgetState createState() => DropdownWidgetState();
// }

// class DropdownWidgetState extends State<DropdownWidget> {
//   late String selected;

//   @override
//   void initState() {
//     super.initState();
//     selected = '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DropdownSearch<String>(
//       popupProps:
//           const PopupProps.menu(showSearchBox: true, fit: FlexFit.loose),
//       items: (String? filter, _) async => widget.items,
//       onChanged: (String? value) {
//         if (value != null) {
//           setState(() {
//             selected = value;
//           });
//           widget.onSelected?.call(value);
//         }
//       },
//       selectedItem: selected,
//     );
//   }
// }

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
              // labelText: 'Select an item',
              labelStyle: TextStyle(color: Colors.grey[600]),
              // hintText: 'Search or select...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.blueAccent,
              ),
            ),
          ),
          // Customize the popup menu
          popupProps: PopupProps.menu(
            showSearchBox: true,
            fit: FlexFit.loose,
            // Customize the search field in the popup
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                // hintText: 'Type to search...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.blueAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
              ),
            ),
            // Customize the popup menu container
            containerBuilder: (context, popupWidget) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
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
