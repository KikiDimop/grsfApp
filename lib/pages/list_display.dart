import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/widgets/global_ui.dart';

class GenericDisplayList<T> extends StatefulWidget {
  final List<T>? items;
  final List<dynamic> stockdataList;
  final Widget identity;
  final String listTitle;
  final String searchHint;
  final List<SortOption> sortOptions;
  final Widget Function(T item) itemBuilder;
  final bool forStockData;

  const GenericDisplayList({
    super.key,
    required this.items,
    required this.identity,
    required this.listTitle,
    required this.searchHint,
    required this.sortOptions,
    required this.itemBuilder,
    this.forStockData = false,
    required this.stockdataList,
  });

  @override
  State<GenericDisplayList<T>> createState() => _GenericDisplayListState<T>();
}

class _GenericDisplayListState<T> extends State<GenericDisplayList<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedOrder;
  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _selectedOrder =
        widget.sortOptions.isNotEmpty ? widget.sortOptions.first.value : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xff16425B),
        foregroundColor: const Color(0xffd9dcd6),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home_filled),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.identity,
            const SizedBox(height: 5),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  listTitle(title: widget.listTitle),
                  const SizedBox(height: 5),
                  Expanded(
                    child: _displayList(
                      searchHint: widget.searchHint,
                      listDisplay: (widget.forStockData)
                          ? stockDataList(
                              list: widget.stockdataList,
                              searchQuery: _searchQuery,
                              sortField: _selectedOrder,
                              sortOrder: _sortOrder)
                          : dataList<T>(
                              items: widget.items,
                              searchQuery: _searchQuery,
                              sortField: _selectedOrder,
                              sortOrder: _sortOrder,
                              listViewItem: ({required item}) =>
                                  widget.itemBuilder(item),
                            ),
                      displayDropDown: widget.sortOptions.isNotEmpty,
                      forStockData: widget.forStockData,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _displayList({
    required String searchHint,
    required Widget listDisplay,
    required bool displayDropDown,
    required bool forStockData,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffd9dcd6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Column(
            children: [
              _searchField(hint: searchHint),
              if (displayDropDown) _orderByDropdown()
            ],
          ),
          Expanded(
            child: listDisplay,
          ),
        ],
      ),
    );
  }

  Widget _orderByDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xff16425B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  value: _selectedOrder,
                  onChanged: (value) {
                    setState(() {
                      _selectedOrder = value ?? widget.sortOptions.first.value;
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    offset: const Offset(0, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xff16425B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down,
                        color: Color(0xffd9dcd6), size: 30),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  items: widget.sortOptions.map((option) {
                    return DropdownMenuItem(
                      value: option.value,
                      child: Text(
                        option.label,
                        style: const TextStyle(color: Color(0xffd9dcd6)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(
              _sortOrder == 'asc'
                  ? Icons.arrow_circle_up
                  : Icons.arrow_circle_down,
              color: const Color(0xffd9dcd6),
              size: 40,
            ),
            onPressed: () {
              setState(() {
                _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _searchField({required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Color(0xffd9dcd6)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xff16425B),
          contentPadding: const EdgeInsets.all(15),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xffd9dcd6),
            fontSize: 14,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.search,
              color: Color(0xffd9dcd6),
            ),
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.cancel,
                color: Color(0xffd9dcd6),
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class SortOption {
  final String value;
  final String label;

  const SortOption({required this.value, required this.label});
}
