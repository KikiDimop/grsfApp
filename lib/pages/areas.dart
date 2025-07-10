import 'package:grsfApp/models/area.dart';
import 'package:grsfApp/global.dart';
import 'package:grsfApp/pages/fisheries.dart';
import 'package:grsfApp/pages/stocks.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Areas extends StatefulWidget {
  const Areas({super.key});

  @override
  State<Areas> createState() => _AreasState();
}

class _AreasState extends State<Areas> {
  List<Area>? areas;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedOrder = 'Name';
  String _sortOrder = 'asc';
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        DatabaseService.instance
            .readAll(tableName: 'Area', fromMap: Area.fromMap)
      ]);

      setState(() {
        areas = results[0];
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
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
      body: Column(
        children: [
          _searchField(),
          const SizedBox(height: 5),
          _orderByDropdown(),
          const SizedBox(height: 5),
          Expanded(
            child: _results(),
          ),
        ],
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
                color: const Color(0xffd9dcd6).withOpacity(0.1),
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
    if (areas == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    // Filter by search query
    final filteredAreas = areas!
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
            (area.areaCodeType
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
        comparison = a.areaCodeType?.compareTo(b.areaCodeType ?? '') ?? 0;
      }

      // If descending, invert the comparison result
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffd9dcd6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
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
                  a: area,
                );
              },
            ),
    );
  }

  Widget _listViewItem({required Area a}) {
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
              a.areaName ?? 'No Name',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 1),
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
                        a.areaCode ?? 'No Code',
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
                        a.areaCodeType ?? 'No System',
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xffd9dcd6),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded edges
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.8, // 80% of screen width
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min, // Adjusts height to content
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                SearchStock searchStock = SearchStock(
                                  selectedSpeciesSystem: 'All',
                                  speciesCode: '',
                                  speciesName: '',
                                  selectedAreaSystem: a.areaCodeType ?? 'All',
                                  areaCode: a.areaCode ?? '',
                                  areaName: a.areaName ?? '',
                                  selectedFAOMajorArea: 'All',
                                  selectedResourceType: 'All',
                                  selectedResourceStatus: 'All',
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Stocks(
                                      search: searchStock,
                                      forSpecies: false,
                                      timeseries: '',
                                      refYear: '',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff16425B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: const Text(
                                'Related Stocks List',
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xffd9dcd6)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                SearchFishery searchFishery = SearchFishery(
                                  selectedSpeciesSystem: 'All',
                                  speciesCode: '',
                                  speciesName: '',
                                  selectedAreaSystem: a.areaCodeType ?? 'All',
                                  areaCode: a.areaCode ?? '',
                                  areaName: a.areaName ?? '',
                                  selectedGearSystem: 'All',
                                  gearCode: '',
                                  gearName: '',
                                  selectedFAOMajorArea: 'All',
                                  selectedResourceType: 'All',
                                  selectedResourceStatus: 'All',
                                  flagCode: '',
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Fisheries(
                                      search: searchFishery,
                                      timeseries: '',
                                      refYear: '',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff16425B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: const Text(
                                'Related Fisheries List',
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xffd9dcd6)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Color(0xff16425B)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff16425B), // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded edges
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8), // Button padding
              ),
              child: const Text(
                'Show Relations',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xffd9dcd6), // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          fillColor: const Color(0xffd9dcd6).withOpacity(0.1),
          contentPadding: const EdgeInsets.all(15),
          hintText: 'Search Area',
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
