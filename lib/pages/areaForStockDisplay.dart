import 'package:database/models/areasForStock.dart';
import 'package:database/models/speciesForStock.dart';
import 'package:database/models/stockOwner.dart';
import 'package:database/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AreasForStoc extends StatefulWidget {
  final String uuid;
  const AreasForStoc({super.key, required this.uuid});

  @override
  State<AreasForStoc> createState() => _AreasForStocState();
}

class _AreasForStocState extends State<AreasForStoc> {
  late Future<List<AreasForStock>> _areas;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedOrder = 'Name';
  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _areas = DatabaseService.instance.readAll(
        tableName: 'AreasForStock',
        where: 'uuid = "${widget.uuid}"',
        fromMap: AreasForStock.fromMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
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
      body: _display(searchHint:  'Search Area'),
    );
  }

  Container _display({required String searchHint}) {
    return Container(
      margin:
          const EdgeInsets.all(10), // Adds some space around the container
      padding: const EdgeInsets.all(10), // Adds space inside the container
      decoration: BoxDecoration(
        color: const Color(0xffd9dcd6).withOpacity(0.1), // Light background
        borderRadius: BorderRadius.circular(12), // Rounded edges
      ),
      child: Column(
        children: [
          _searchField(hint: searchHint),
          const SizedBox(height: 16),
          _orderByDropdown(),
          const SizedBox(height: 16),
          Expanded(
            child: _results(),
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
                      _selectedOrder = value ?? 'Name';
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    offset: const Offset(
                        0, 8), // Ensures a consistent dropdown position
                    decoration: BoxDecoration(
                      color: Color(0xff16425B),
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
                  items: const [
                    DropdownMenuItem(
                        value: 'Name',
                        child: Text(
                          'Order by Name',
                          style: TextStyle(color: Color(0xffd9dcd6)),
                        )),
                    DropdownMenuItem(
                        value: 'Code',
                        child: Text('Order by Code',
                            style: TextStyle(color: Color(0xffd9dcd6)))),
                    DropdownMenuItem(
                        value: 'System',
                        child: Text('Order by System',
                            style: TextStyle(color: Color(0xffd9dcd6)))),
                  ],
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

  Widget _results() {
    return FutureBuilder<List<dynamic>>(
      future: _areas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xffd9dcd6),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading areas: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final areas = snapshot.data ?? [];

        // Filter by search query
        final filteredAreas = areas
            .where((area) =>
                _searchQuery.isEmpty ||
                (area.areaName
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false) ||
                (area.areaCode
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false) ||
                (area.areaType
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false))
            .toList();

        // Apply sorting logic based on selected order and sort order (asc/desc)
        filteredAreas.sort((a, b) {
          int comparison = 0;
          if (_selectedOrder == 'Name') {
            comparison = a.areaName?.compareTo(b.areaName ?? '') ?? 0;
          } else if (_selectedOrder == 'Code') {
            comparison = a.areaCode?.compareTo(b.areaCode ?? '') ?? 0;
          } else if (_selectedOrder == 'System') {
            comparison = a.areaType?.compareTo(b.areaType ?? '') ?? 0;
          }

          // If descending, invert the comparison result
          return _sortOrder == 'asc' ? comparison : -comparison;
        });

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(10),
          child: filteredAreas.isEmpty
              ? const Center(
                  child: Text(
                    'No areas found',
                    style: TextStyle(color: Color(0xffd9dcd6)),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredAreas.length,
                  itemBuilder: (context, index) {
                    final area = filteredAreas[index];
                    return _listViewItem(
                      item : area,
                    );
                  },
                ),
        );
      },
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
        style: const TextStyle(color: Color(0xffd9dcd6)), // Text color
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

  Widget _listViewItem({required dynamic item}) {
    String name = '';
    String system = '';
    String code = '';

    if (item is SpeciesForStock) {
      name = item.speciesName ?? 'No Name';
      system = item.speciesType ?? 'No System';
      code = item.speciesCode ?? 'No Code';
    } else if (item is AreasForStock) {
      name = item.areaName ?? 'No Name';
      system = item.areaType ?? 'No System';
      code = item.areaCode ?? 'No Code';
    } else if (item is StockOwner) {
      name = item.owner ?? 'No Name';
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffd9dcd6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff16425B),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 1),
            if (system.isNotEmpty && code.isNotEmpty) // Fixed condition here
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Code',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff16425B),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          code,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff16425B),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff16425B),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          system,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xff16425B),
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

}
