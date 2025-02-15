import 'package:database/models/areasForStock.dart';
import 'package:database/models/speciesForStock.dart';
import 'package:database/models/stock.dart';
import 'package:database/models/stockOwner.dart';
import 'package:database/pages/areaForStockDisplay.dart';
import 'package:database/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DisplaySingleStock extends StatefulWidget {
  final Stock stock;
  const DisplaySingleStock({super.key, required this.stock});

  @override
  State<DisplaySingleStock> createState() => _DisplaySingleStockState();
}

class _DisplaySingleStockState extends State<DisplaySingleStock> {
  late Future<List<AreasForStock>> _areaForStock;
  late Future<List<SpeciesForStock>> _speciesForStock;
  late Future<List<StockOwner>> _stockOwner;

  late List<AreasForStock> areas;
  late List<StockOwner> owners;
  late List<SpeciesForStock> species;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedOrder = 'Name';
  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();

    String? whereStr = 'uuid = "${widget.stock.uuid}"';
    _areaForStock = DatabaseService.instance.readAll(
        tableName: 'AreasForStock',
        where: whereStr,
        fromMap: AreasForStock.fromMap);
    _speciesForStock = DatabaseService.instance.readAll(
        tableName: 'SpeciesForStock',
        where: whereStr,
        fromMap: SpeciesForStock.fromMap);
    _stockOwner = DatabaseService.instance.readAll(
        tableName: 'StockOwner', where: whereStr, fromMap: StockOwner.fromMap);
  }

  bool _showDetails = true;
  bool _showAreasList = false;

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xff16425B),
    appBar: AppBar(
      leading: IconButton(
        onPressed: () {
          if (_showAreasList) {
            setState(() {
              _showDetails = true;
              _showAreasList = false;
            });
          } else {
            Navigator.pop(context);
          }
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
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _identitySection(context),
        const SizedBox(height: 5),
        if (_showDetails) 
          _detailsSection(context)
        else if (_showAreasList) 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _listTitle(title: 'Assessment Areas'),
                const SizedBox(height: 5),
                _displayList(searchHint: 'Search Area'),
              ],
            ),
          ),
      ],
    ),
  );
}

Padding _listTitle({required String title}) {
  return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xffd9dcd6),
          ),
        ),
      );
}

Expanded _displayList({required String searchHint}) {
  return Expanded(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffd9dcd6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
        ),
      );
}

  Widget _orderByDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _identitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Stock Identity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffd9dcd6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the white box
          children: [
            Container(
              width:
                  MediaQuery.of(context).size.width * 0.9, // Make it responsive
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffd9dcd6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statusDisplay(),
                  simpleDisplay('Short Name', widget.stock.shortName ?? ''),
                  simpleDisplay(
                      'Semantic ID', widget.stock.grsfSemanticID ?? ''),
                  simpleDisplay('Semantic Title', widget.stock.grsfName ?? ''),
                  simpleDisplay('UUID', widget.stock.uuid ?? ''),
                  simpleDisplay('Type', widget.stock.type ?? ''),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Stock Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffd9dcd6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffd9dcd6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  showDetails(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget showDetails() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_areaForStock, _stockOwner, _speciesForStock]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData ||
            snapshot.data![0] == null ||
            snapshot.data![1] == null) {
          return const Text('No data found');
        }

        areas = snapshot.data![0] as List<AreasForStock>;
        owners = snapshot.data![1] as List<StockOwner>;
        species = snapshot.data![2] as List<SpeciesForStock>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (species.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Species',
                      style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
                    ),
                    displayRow('Code     : ', species.first.speciesCode ?? ''),
                    displayRow('System : ', species.first.speciesType ?? ''),
                    displayRow('Name    : ', species.first.speciesName ?? ''),
                  ],
                ),
              ),
            if (areas.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment Area Details',
                      style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
                    ),
                    displayRow('Code     : ', areas.first.areaCode ?? ''),
                    displayRow('System : ', areas.first.areaType ?? ''),
                    displayRow('Name    : ', areas.first.areaName ?? ''),
                  ],
                ),
              ),
            if (owners.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Owner',
                      style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
                    ),
                    Text(
                      owners.first.owner ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff16425B),
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                if (species.length > 1)
                  _button(
                    label: 'Species List',
                    onPressed: () {
                      setState(() {
                        _showDetails = false;
                        
                      });
                    },
                  ),
                const SizedBox(
                  width: 10,
                ),
                if (areas.length > 1)
                  _button(
                    label: 'View Areas',
                    onPressed: () {
                      setState(() {
                        _showDetails = false;
                        _showAreasList = true;
                      });
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => AreasForStoc(uuid: widget.stock.uuid ?? ''),
                      //   ),
                      // );
                    },
                  ),
                const SizedBox(
                  width: 10,
                ),
                if (owners.length > 1)
                  _button(
                    label: 'View Owners',
                    onPressed: () {
                      setState(() {
                        _showDetails = false;
                      });
                    },
                  ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget displayRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2, // Adjusts width based on screen size
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xff16425B),
              ),
            ),
          ),
          const SizedBox(width: 5), // Spacing between label and value
          Expanded(
            flex: 4, // Allows value to take remaining space
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              softWrap: true, // Ensures text wraps properly
            ),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff16425B), // Dynamic background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded edges
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // Dynamic padding
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xffd9dcd6), // Dynamic text color
        ),
      ),
    );
  }

  Align statusDisplay() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        widget.stock.status ?? '',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: widget.stock.getColor(),
        ),
      ),
    );
  }

  Widget simpleDisplay(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4), // Spacing between items
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xff16425B)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff16425B),
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
          ),
        ],
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
          borderRadius: BorderRadius.circular(8),
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
 
  Widget _results() {
    return FutureBuilder<List<dynamic>>(
      future: _areaForStock,
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


}
