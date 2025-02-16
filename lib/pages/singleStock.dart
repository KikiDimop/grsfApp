import 'package:database/models/areasForStock.dart';
import 'package:database/models/speciesForStock.dart';
import 'package:database/models/stock.dart';
import 'package:database/models/stockOwner.dart';
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
  List<AreasForStock>? areas;
  List<StockOwner>? owners;
  List<SpeciesForStock>? species;
  bool isLoading = true;
  String? error;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedOrder = 'Name';
  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      String whereStr = 'uuid = "${widget.stock.uuid}"';

      final results = await Future.wait([
        DatabaseService.instance.readAll(
          tableName: 'AreasForStock',
          where: whereStr,
          fromMap: AreasForStock.fromMap,
        ),
        DatabaseService.instance.readAll(
          tableName: 'StockOwner',
          where: whereStr,
          fromMap: StockOwner.fromMap,
        ),
        DatabaseService.instance.readAll(
          tableName: 'SpeciesForStock',
          where: whereStr,
          fromMap: SpeciesForStock.fromMap,
        ),
      ]);

      setState(() {
        areas = results[0] as List<AreasForStock>;
        owners = results[1] as List<StockOwner>;
        species = results[2] as List<SpeciesForStock>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  bool _showDetails = true;
  bool _showAreasList = false;
  bool _showSpeciesList = false;
  bool _showOwnerList = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (_showAreasList || _showSpeciesList || _showOwnerList) {
              setState(() {
                _showDetails = true;
                _showAreasList = false;
                _showSpeciesList = false;
                _showOwnerList = false;
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text('Error: $error',
                      style: const TextStyle(color: Colors.red)))
              : Column(
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
                            _displayList(
                              searchHint: 'Search Area',
                              listDisplay: _areasList(),
                            ),
                          ],
                        ),
                      )
                    else if (_showSpeciesList)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _listTitle(title: 'Species'),
                            const SizedBox(height: 5),
                            _displayList(
                              searchHint: 'Search Species',
                              listDisplay: _speciesList(),
                            ),
                          ],
                        ),
                      )
                    else if (_showOwnerList)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _listTitle(title: 'Owners'),
                            const SizedBox(height: 5),
                            _displayList(
                              searchHint: 'Search Owner',
                              listDisplay: _ownersList(),
                            ),
                          ],
                        ),
                      )
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

  Expanded _displayList(
      {required String searchHint, required Widget listDisplay}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffd9dcd6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (!searchHint.contains('Owner'))
              Column(
                children: [
                  _searchField(hint: searchHint),
                  const SizedBox(height: 16),
                  _orderByDropdown(),
                  const SizedBox(height: 16),
                ],
              ),
            Expanded(
              child: listDisplay,
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
                  _truncatedDisplay('Short Name', widget.stock.shortName ?? '',40),
                  _truncatedDisplay(
                      'Semantic ID', widget.stock.grsfSemanticID ?? '',40),
                  _truncatedDisplay(
                      'Semantic Title', widget.stock.grsfName ?? '',40),
                  _truncatedDisplay('UUID', widget.stock.uuid ?? '',40),
                  _truncatedDisplay('Type', widget.stock.type ?? '',40),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _truncatedDisplay(String title, String value, int maxLength) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xff16425B)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  value.length > maxLength ? '${value.substring(0, maxLength)}...' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff16425B),
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
              ),
              if (value.length > maxLength)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InkWell(
                    onTap: () => _showFullText(context, title, value),
                    child: const Icon(
                      Icons.more_horiz,
                      color: Color(0xff16425B),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFullText(BuildContext context, String title, String value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffd9dcd6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff16425B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xff16425B),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff16425B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailsSection(BuildContext context) {
    if (areas == null || owners == null || species == null) {
      return const Center(child: Text('No data available'));
    }

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
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xffd9dcd6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (species!.length == 1)
                    _buildSpeciesDetails(species!.first),
                  if (areas!.length == 1) _buildAreaDetails(areas!.first),
                  if (owners!.length == 1) _buildOwnerDetails(owners!.first),
                  Wrap(
                    // Changed from Row to Wrap
                    spacing: 5, // Horizontal spacing between buttons
                    runSpacing: 5, // Vertical spacing between rows
                    alignment: WrapAlignment.center,
                    children: [
                      if (species!.length > 1)
                        _button(
                          label: 'View Species',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = false;
                              _showSpeciesList = true;
                            });
                          },
                        ),
                      if (areas!.length > 1)
                        _button(
                          label: 'View Areas',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = true;
                              _showOwnerList = false;
                              _showSpeciesList = false;
                            });
                          },
                        ),
                      if (owners!.length > 1)
                        _button(
                          label: 'View Owners',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = true;
                              _showSpeciesList = false;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSpeciesDetails(SpeciesForStock species) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Species',
            style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
          ),
          displayRow('Code     : ', species.speciesCode ?? ''),
          displayRow('System : ', species.speciesType ?? ''),
          displayRow('Name    : ', species.speciesName ?? ''),
        ],
      ),
    );
  }

  Widget _buildAreaDetails(AreasForStock area) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assessment Area Details',
            style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
          ),
          displayRow('Code     : ', area.areaCode ?? ''),
          displayRow('System : ', area.areaType ?? ''),
          displayRow('Name    : ', area.areaName ?? ''),
        ],
      ),
    );
  }

  Widget _buildOwnerDetails(StockOwner owner) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Owner',
            style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
          ),
          Text(
            owner.owner ?? '',
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

  Widget _areasList() {
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
            (area.areaType
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();

    // Apply sorting logic
    filteredAreas.sort((a, b) {
      int comparison = 0;
      if (_selectedOrder == 'Name') {
        comparison = a.areaName?.compareTo(b.areaName ?? '') ?? 0;
      } else if (_selectedOrder == 'Code') {
        comparison = a.areaCode?.compareTo(b.areaCode ?? '') ?? 0;
      } else if (_selectedOrder == 'System') {
        comparison = a.areaType?.compareTo(b.areaType ?? '') ?? 0;
      }
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
                return _listViewItem(item: area);
              },
            ),
    );
  }

  Widget _speciesList() {
    if (species == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    // Filter by search query
    final filteredSpecies = species!
        .where((sp) =>
            _searchQuery.isEmpty ||
            (sp.speciesName
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (sp.speciesCode
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (sp.speciesType
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();

    // Apply sorting logic
    filteredSpecies.sort((a, b) {
      int comparison = 0;
      if (_selectedOrder == 'Name') {
        comparison = a.speciesName?.compareTo(b.speciesName ?? '') ?? 0;
      } else if (_selectedOrder == 'Code') {
        comparison = a.speciesCode?.compareTo(b.speciesCode ?? '') ?? 0;
      } else if (_selectedOrder == 'System') {
        comparison = a.speciesType?.compareTo(b.speciesType ?? '') ?? 0;
      }
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: filteredSpecies.isEmpty
          ? const Center(
              child: Text(
                'No areas found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: filteredSpecies.length,
              itemBuilder: (context, index) {
                final i = filteredSpecies[index];
                return _listViewItem(item: i);
              },
            ),
    );
  }

  Widget _ownersList() {
    if (owners == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    // Filter by search query
    owners = owners?.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: owners!.isEmpty
          ? const Center(
              child: Text(
                'No areas found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: owners!.length,
              itemBuilder: (context, index) {
                final area = owners![index];
                return _listViewItem(item: area);
              },
            ),
    );
  }
}
