import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/models/fishery.dart';
import 'package:grsfApp/models/fisheryOwner.dart';
import 'package:grsfApp/models/fishingGear.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DisplaySingleFishery extends StatefulWidget {
  final Fishery fishery;
  const DisplaySingleFishery({super.key, required this.fishery});

  @override
  State<DisplaySingleFishery> createState() => _DisplaySingleFisheryState();
}

class _DisplaySingleFisheryState extends State<DisplaySingleFishery> {
  List<AreasForFishery>? areas;
  List<FisheryOwner>? owners;
  List<Gear>? gears;
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
      String whereStr = 'uuid = "${widget.fishery.uuid}"';
      String whereStrGear = 'fishing_gear_id = "${widget.fishery.gearCode}"';

      final results = await Future.wait([
        DatabaseService.instance.readAll(
          tableName: 'AreasForFishery',
          where: whereStr,
          fromMap: AreasForFishery.fromMap,
        ),
        DatabaseService.instance.readAll(
          tableName: 'FisheryOwner',
          where: whereStr,
          fromMap: FisheryOwner.fromMap,
        ),
        DatabaseService.instance.readAll(
          tableName: 'Gear',
          where: whereStrGear,
          fromMap: Gear.fromMap,
        ),
      ]);

      setState(() {
        areas = results[0] as List<AreasForFishery>;
        owners = results[1] as List<FisheryOwner>;
        gears = results[2] as List<Gear>;
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
  bool _showOwnerList = false;
  bool _showGearsList = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (_showAreasList || _showOwnerList) {
              setState(() {
                _showDetails = true;
                _showAreasList = false;
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
                    else if (_showGearsList)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _listTitle(title: 'Fishing Gears'),
                            const SizedBox(height: 5),
                            _displayList(
                              searchHint: 'Search Fishing Gear',
                              listDisplay: _gearsList(),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Fishery Identity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffd9dcd6),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: dataInfoDialogDisplay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffd9dcd6), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded edges
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Button padding
                ),
                child: const Text(
                  'Data Info',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff16425B),
                      fontWeight: FontWeight.bold // Text color
                      ),
                ),
              )
            ],
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
                  _truncatedDisplay(
                      'Short Name', widget.fishery.shortName ?? '', 40),
                  _truncatedDisplay(
                      'Semantic ID', widget.fishery.grsfSemanticID ?? '', 40),
                  _truncatedDisplay(
                      'Semantic Title', widget.fishery.grsfName ?? '', 40),
                  _truncatedDisplay('UUID', widget.fishery.uuid ?? '', 40),
                  _truncatedDisplay('Type', widget.fishery.type ?? '', 40),
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
                  value.length > maxLength
                      ? '${value.substring(0, maxLength)}...'
                      : value,
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
    if (areas == null || owners == null || gears == null) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Fishery Details',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Species',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xff16425B)),
                        ),
                        displayRow(
                            'Code     : ', widget.fishery.speciesCode ?? ''),
                        displayRow(
                            'System : ', widget.fishery.speciesType ?? ''),
                        displayRow(
                            'Name    : ', widget.fishery.speciesName ?? ''),
                      ],
                    ),
                  ),
                  if (areas!.length == 1) _buildAreaDetails(areas!.first),
                  if (owners!.length == 1) _buildOwnerDetails(owners!.first),
                  if (gears!.length == 1) _buildGearDetails(gears!.first),
                  simpleDisplay('Management Authority',
                      widget.fishery.managementEntities ?? '-'),
                  Wrap(
                    spacing: 3,
                    runSpacing: 1,
                    alignment: WrapAlignment.start,
                    children: [
                      if (areas!.length > 1)
                        _button(
                          label: 'Areas',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = true;
                              _showOwnerList = false;
                              _showGearsList = false;
                            });
                          },
                        ),
                      if (owners!.length > 1)
                        _button(
                          label: 'Owners',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = true;
                              _showGearsList = false;
                            });
                          },
                        ),
                      if (gears!.length > 1)
                        _button(
                          label: 'Fishing Gears',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = false;
                              _showGearsList = false;
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

  Widget _buildGearDetails(Gear gear) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fishing Gear Details',
            style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
          ),
          displayRow('Code     : ', gear.fishingGearId ?? ''),
          displayRow('System : ', gear.fishingGearType ?? ''),
          displayRow('Name    : ', gear.fishingGearName ?? ''),
        ],
      ),
    );
  }

  Widget _buildAreaDetails(AreasForFishery area) {
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

  Widget _buildOwnerDetails(FisheryOwner owner) {
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
        widget.fishery.status ?? '',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: getColor(widget.fishery.status),
        ),
      ),
    );
  }

  void dataInfoDialogDisplay() {
    // Show popup dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffd9dcd6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded edges
          ),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjusts height to content
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Action for Related Stocks
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff16425B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Catches',
                    style: TextStyle(fontSize: 14, color: Color(0xffd9dcd6)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Action for Related Fisheries
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff16425B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Landings',
                    style: TextStyle(fontSize: 14, color: Color(0xffd9dcd6)),
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

    if (item is AreasForFishery) {
      name = item.areaName ?? 'No Name';
      system = item.areaType ?? 'No System';
      code = item.areaCode ?? 'No Code';
    } else if (item is FisheryOwner) {
      name = item.owner ?? 'No Name';
    } else if (item is Gear) {
      name = item.fishingGearName ?? 'No Name';
      system = item.fishingGearType ?? 'No System';
      code = item.fishingGearId ?? 'No ID';
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
                'No owners found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: owners!.length,
              itemBuilder: (context, index) {
                final i = owners![index];
                return _listViewItem(item: i);
              },
            ),
    );
  }

  Widget _gearsList() {
    if (gears == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    final filteredGears = gears!
        .where((gear) =>
            _searchQuery.isEmpty ||
            (gear.fishingGearName
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (gear.fishingGearId
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (gear.fishingGearType
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();

    filteredGears.sort((a, b) {
      int comparison = 0;
      if (_selectedOrder == 'Name') {
        comparison = a.fishingGearName?.compareTo(b.fishingGearName ?? '') ?? 0;
      } else if (_selectedOrder == 'Code') {
        comparison = a.fishingGearId?.compareTo(b.fishingGearId ?? '') ?? 0;
      } else if (_selectedOrder == 'System') {
        comparison = a.fishingGearType?.compareTo(b.fishingGearType ?? '') ?? 0;
      }
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: filteredGears.isEmpty
          ? const Center(
              child: Text(
                'No areas found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: filteredGears.length,
              itemBuilder: (context, index) {
                final i = filteredGears[index];
                return _listViewItem(item: i);
              },
            ),
    );
  }
}
