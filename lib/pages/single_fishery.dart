import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/fishery.dart';
import 'package:grsfApp/models/fisheryOwner.dart';
import 'package:grsfApp/models/fishingGear.dart';
import 'package:grsfApp/models/flag.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/pages/list_display.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/fishery_identity_card.dart';
import 'package:grsfApp/widgets/global_ui.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DisplaySingleFishery extends StatefulWidget {
  final Fishery fishery;
  const DisplaySingleFishery({super.key, required this.fishery});

  @override
  State<DisplaySingleFishery> createState() => _DisplaySingleFisheryState();
}

class _DisplaySingleFisheryState extends State<DisplaySingleFishery> {
  List<AreasForFishery>? areas;
  List<FisheryOwner>? owners;
  List<FaoMajorArea>? faoAreas;
  List<FlagStates>? flags = [];
  List<Gear>? gears;
  bool isLoading = true;
  bool isLoading2 = true;
  bool isExistDataFromAPI = false;
  bool isExistDataInfoFromAPI = false;
  String? error;
  Map<String, dynamic>? _responseData;
  Map<String, dynamic>? _responseDataInfo;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedOrder = 'Name';
  String _selectedOrderStockData = 'Value';
  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
      isLoading2 = true;
    });

    try {
      await Future.wait([
        _fetchData(),
        _fetchDataFromAPI(),
        _fetchDataInfoFromAPI(),
      ]);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
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
        DatabaseService.instance
            .getFaoMajorAreas(widget.fishery.parentAreas ?? '')
      ]);

      setState(() {
        areas = results[0] as List<AreasForFishery>;
        owners = results[1] as List<FisheryOwner>;
        gears = results[2] as List<Gear>;
        faoAreas = results[3] as List<FaoMajorArea>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchDataFromAPI() async {
    try {
      final response = await http.get(Uri.parse(
          'https://isl.ics.forth.gr/grsf/grsf-api/resources/getfisherybasic?uuid=${widget.fishery.uuid}&response_type=JSON'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _responseData = data;
          isLoading2 = false;
          isExistDataFromAPI = true;

          //Fill lists from api data
          final rawGears = _responseData!['result']['fishing_gears'];
          final rawAreas = _responseData!['result']['assessment_areas'];
          final rawFlagStates = _responseData!['result']['flag_states'];

          final List<dynamic> gearList =
              rawGears is List ? rawGears : [rawGears];
          final List<dynamic> areaList =
              rawAreas is List ? rawAreas : [rawAreas];
          final List<dynamic> flagStateList =
              rawFlagStates is List ? rawFlagStates : [rawFlagStates];

          gears = gearList.map((item) => Gear.fromJson(item)).toList();
          areas =
              areaList.map((item) => AreasForFishery.fromJson(item)).toList();
          flags =
              flagStateList.map((item) => FlagStates.fromJson(item)).toList();
        });
      } else {
        setState(() {
          _responseData = null;
          isLoading2 = false;
        });
      }
    } catch (e) {
      setState(() {
        _responseData = null;
        isLoading2 = false;
      });
      //debugPrint('Error fetching API data: $e');
    }
  }

  Future<void> _fetchDataInfoFromAPI() async {
    try {
      final response = await http.get(Uri.parse(
          'https://isl.ics.forth.gr/grsf/grsf-api/resources/getfishery?uuid=${widget.fishery.uuid}&response_type=JSON'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _responseDataInfo = data;
          isExistDataInfoFromAPI = true;
        });
      } else {
        setState(() {
          _responseDataInfo = null;
        });
      }
    } catch (e) {
      setState(() {
        _responseDataInfo = null;
      });
      //debugPrint('Error fetching API data: $e');
    }
  }

  bool _showDetails = true;

  bool _showOwnerList = false;
  bool _showGearsList = false;
  bool _showManagementUnitsList = false;
  bool _showCatches = false;
  bool _showLandings = false;
  bool _showFaoMajorAreaList = false;
  bool _showFlagStatesList = false;

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
      body: (isLoading || isLoading2)
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text('Error: $error',
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _identitySection(true),
                      const SizedBox(height: 5),
                      _detailsSection(context)

                      // else if (_showManagementUnitsList)
                      //   SizedBox(
                      //     height: MediaQuery.of(context).size.height * 0.5,
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         listTitle(title: 'Management Units'),
                      //         const SizedBox(height: 5),
                      //         Expanded(
                      //           child: _displayList(
                      //               searchHint: 'Search Management Unit',
                      //               listDisplay: _managementUnitsList(),
                      //               displayDropDown: true,
                      //               forStockData: false),
                      //         ),
                      //       ],
                      //     ),
                      //   )

                      // else if (_showLandings)
                      //   SizedBox(
                      //     height: MediaQuery.of(context).size.height * 0.5,
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         listTitle(title: 'Landings'),
                      //         const SizedBox(height: 5),
                      //         Expanded(
                      //           child: _displayList(
                      //               searchHint: 'Search Landing',
                      //               listDisplay:
                      //                   _stockDataList(stockData: "landings"),
                      //               displayDropDown: true,
                      //               forStockData: true),
                      //         ),
                      //       ],
                      //     ),
                      //   )
                    ],
                  ),
                ),
    );
  }

  Widget _displayList(
      {required String searchHint,
      required Widget listDisplay,
      required bool displayDropDown,
      required bool forStockData}) {
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
              if (displayDropDown && !forStockData)
                _orderByDropdown()
              else if (displayDropDown && forStockData)
                _orderByDropdownStockData(),
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

  Widget _orderByDropdownStockData() {
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
                  value: _selectedOrderStockData,
                  onChanged: (value) {
                    setState(() {
                      _selectedOrderStockData = value ?? 'Value';
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
                        value: 'Value',
                        child: Text(
                          'Order by Value',
                          style: TextStyle(color: Color(0xffd9dcd6)),
                        )),
                    DropdownMenuItem(
                        value: 'Unit',
                        child: Text('Order by Unit',
                            style: TextStyle(color: Color(0xffd9dcd6)))),
                    DropdownMenuItem(
                        value: 'Data Owner',
                        child: Text('Order by Data Owner',
                            style: TextStyle(color: Color(0xffd9dcd6)))),
                    DropdownMenuItem(
                        value: 'Type',
                        child: Text('Order by Type',
                            style: TextStyle(color: Color(0xffd9dcd6)))),
                    DropdownMenuItem(
                        value: 'Ref. Year',
                        child: Text('Order by Ref. Year',
                            style: TextStyle(color: Color(0xffd9dcd6)))),
                    DropdownMenuItem(
                        value: 'Rep. Year',
                        child: Text('Order by Rep. Year',
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

  Widget _identitySection(bool withDataInfo) {
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
              if (withDataInfo)
                ElevatedButton(
                  onPressed: dataInfoDialogDisplay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xffd9dcd6), // Background color
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (!isExistDataFromAPI)
                ? FisheryIdentityCard(
                    name: widget.fishery.shortName ?? '',
                    id: widget.fishery.grsfSemanticID ?? '',
                    title: widget.fishery.grsfName ?? '',
                    uuid: widget.fishery.uuid ?? '',
                    type: widget.fishery.type ?? '',
                    status: widget.fishery.status ?? '')
                : FisheryIdentityCard(
                    name: _responseData!["result"]["short_name"],
                    id: _responseData!["result"]["semantic_id"],
                    title: _responseData!["result"]["semantic_title"],
                    uuid: _responseData!["result"]["uuid"],
                    type: widget.fishery.type ?? '',
                    status: _responseData!["result"]["status"],
                    url: _responseData!["result"]["source_urls"][0] ?? '',
                  )
          ],
        ),
      ],
    );
  }

  Widget _detailsSection(BuildContext context) {
    if (areas == null || owners == null || gears == null || faoAreas == null) {
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
                          if (!isExistDataFromAPI)
                            dataDetailsDisplay(
                                label: 'Species',
                                code: widget.fishery.speciesCode ?? '',
                                system: widget.fishery.speciesType ?? '',
                                name: widget.fishery.speciesName ?? '',
                                withIcon: true,
                                onIconPressed: () => openSourceLink(
                                    'https://images.google.com/search?tbm=isch&q=${widget.fishery.speciesName ?? ''}'),
                                icon: Icons.image)
                          else
                            dataDetailsDisplay(
                                label: 'Species',
                                code: _responseData!["result"]["species"]
                                        ["species_code"] ??
                                    '',
                                system: _responseData!["result"]["species"]
                                        ["species_type"] ??
                                    '',
                                name: _responseData!["result"]["species"]
                                        ["species_name"] ??
                                    '',
                                withIcon: true,
                                onIconPressed: () => openSourceLink(
                                    'https://images.google.com/search?tbm=isch&q=${_responseData!["result"]["species"]["species_name"] ?? ''}'),
                                icon: Icons.image),
                        ]),
                  ),
                  if (areas!.length == 1)
                    dataDetailsDisplay(
                        label: 'Assessment Area Details',
                        code: areas!.first.areaCode ?? '',
                        system: areas!.first.areaType ?? '',
                        name: areas!.first.areaName ?? '',
                        withIcon: false), //_buildAreaDetails(areas!.first),
                  if (owners!.length == 1)
                    dataDisplay(
                        label: 'Data Owner',
                        value: owners!.first.owner ??
                            ''), //_buildOwnerDetails(owners!.first),
                  if (gears!.length == 1)
                    dataDetailsDisplay(
                        label: 'Fishing Gear Details',
                        code: gears!.first.fishingGearId ?? '',
                        system: gears!.first.fishingGearType ?? '',
                        name: gears!.first.fishingGearName ?? '',
                        withIcon: true,
                        onIconPressed: () => openSourceLink(
                            'https://images.google.com/search?tbm=isch&q=${gears!.first.fishingGearName ?? ''}'),
                        icon: Icons.image), //_buildGearDetails(gears!.first),
                  if (faoAreas!.length == 1)
                    dataDetailsDisplay(
                        label: 'Fao Major Area',
                        code: faoAreas!.first.faoMajorAreaCode ?? '',
                        system: '',
                        name: faoAreas!.first.faoMajorAreaName ?? '',
                        withIcon:
                            false), //_buildFaoMajorAreaDetails(faoAreas!.first),
                  dataDisplay(
                      label: 'Management Authority',
                      value: widget.fishery.managementEntities ?? '-'),
                  if (isExistDataFromAPI && flags!.length == 1)
                    dataDetailsDisplay(
                        label: 'Flag State',
                        code: _responseData!["result"]["flag_states"]
                                ["flag_state_code"] ??
                            '',
                        system: _responseData!["result"]["flag_states"]
                                ["flag_state_type"] ??
                            '',
                        name: _responseData!["result"]["flag_states"]
                                ["flag_state_name"] ??
                            '',
                        withIcon: false),
                  Wrap(
                    spacing: 3,
                    runSpacing: 1,
                    alignment: WrapAlignment.start,
                    children: [
                      if (areas!.length > 1)
                        customButton(
                          label: 'Areas',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GenericDisplayList<AreasForFishery>(
                                  items: areas,
                                  identity: _identitySection(false),
                                  listTitle: 'Assessment Areas',
                                  searchHint: 'Search Area',
                                  sortOptions: const [
                                    SortOption(
                                        value: 'Name', label: 'Order by Name'),
                                    SortOption(
                                        value: 'Code', label: 'Order by Code'),
                                    SortOption(
                                        value: 'System',
                                        label: 'Order by System'),
                                  ],
                                  itemBuilder: (item) =>
                                      listViewItem(item: item),
                                ),
                              ),
                            );
                          },
                        ),
                      if (owners!.length > 1)
                        customButton(
                          label: 'Owners',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GenericDisplayList<FisheryOwner>(
                                  items: owners,
                                  identity: _identitySection(false),
                                  listTitle: 'Owners',
                                  searchHint: 'Search Owner',
                                  sortOptions: const [
                                    SortOption(
                                        value: 'Name', label: 'Order by Name'),
                                  ],
                                  itemBuilder: (item) =>
                                      listViewItem(item: item),
                                ),
                              ),
                            );
                          },
                        ),
                      if (gears!.length > 1)
                        customButton(
                          label: 'Fishing Gear',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GenericDisplayList<Gear>(
                                  items: gears,
                                  identity: _identitySection(false),
                                  listTitle: 'Fishing Gears',
                                  searchHint: 'Search Fishing Gear',
                                  sortOptions: const [
                                    SortOption(
                                        value: 'Name', label: 'Order by Name'),
                                    SortOption(
                                        value: 'Code', label: 'Order by Code'),
                                    SortOption(
                                        value: 'System',
                                        label: 'Order by System')
                                  ],
                                  itemBuilder: (item) =>
                                      listViewItem(item: item),
                                ),
                              ),
                            );
                          },
                        ),
                      if (faoAreas!.length > 1)
                        customButton(
                          label: 'Fao Major Areas',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GenericDisplayList<FaoMajorArea>(
                                  items: faoAreas,
                                  identity: _identitySection(false),
                                  listTitle: 'Fao Major Areas',
                                  searchHint: 'Search Fao Major Areas',
                                  sortOptions: const [
                                    SortOption(
                                        value: 'Name', label: 'Order by Name'),
                                    SortOption(
                                        value: 'Code', label: 'Order by Code'),
                                  ],
                                  itemBuilder: (item) =>
                                      listViewItem(item: item),
                                ),
                              ),
                            );
                          },
                        ),
                      if (flags!.length > 1)
                        customButton(
                          label: 'Flag States',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GenericDisplayList<FlagStates>(
                                  items: flags,
                                  identity: _identitySection(false),
                                  listTitle: 'Flag States',
                                  searchHint: 'Search Flag State',
                                  sortOptions: const [
                                    SortOption(
                                        value: 'Name', label: 'Order by Name'),
                                    SortOption(
                                        value: 'Code', label: 'Order by Code'),
                                  ],
                                  itemBuilder: (item) =>
                                      listViewItem(item: item),
                                ),
                              ),
                            );
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

  // else if (_showCatches)
  //   SizedBox(
  //     height: MediaQuery.of(context).size.height * 0.5,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         listTitle(title: 'Catches'),
  //         const SizedBox(height: 5),
  //         Expanded(
  //           child: _displayList(
  //               searchHint: 'Search Catch',
  //               listDisplay:
  //                   _stockDataList(stockData: "catches"),
  //               displayDropDown: true,
  //               forStockData: true),
  //         ),
  //       ],
  //     ),
  //   )
  void dataInfoDialogDisplay() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffd9dcd6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: (isExistDataInfoFromAPI &&
                          _responseDataInfo?["result"]["catches"].length != 0)
                      ? () {
                          setState(() {
                            _showDetails = false;
                            _showOwnerList = false;
                            _showGearsList = false;
                            _showManagementUnitsList = false;
                            _showCatches = true;
                            _showLandings = false;
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
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
                  onPressed: (isExistDataInfoFromAPI &&
                          _responseDataInfo?["result"]["landings"].length != 0)
                      ? () {
                          setState(() {
                            _showDetails = false;
                            _showOwnerList = false;
                            _showGearsList = false;
                            _showManagementUnitsList = false;
                            _showCatches = false;
                            _showLandings = true;
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
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

  Widget _managementUnitsList() {
    if (_responseData == null ||
        _responseData!["result"] == null ||
        _responseData!["result"]["management_units"] == null ||
        _responseData!["result"]["management_units"].isEmpty) {
      return const Center(
        child: Text(
          'No management units available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    final List<dynamic> managementUnits =
        List.from(_responseData!["result"]["management_units"]);

    final filteredUnits = managementUnits
        .where((unit) =>
            _searchQuery.isEmpty ||
            (unit["management_unit_name"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (unit["management_unit_code"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (unit["management_unit_system"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();

    filteredUnits.sort((a, b) {
      int comparison = 0;
      if (_selectedOrder == 'Name') {
        comparison = a["management_unit_name"]
                ?.compareTo(b["management_unit_name"] ?? '') ??
            0;
      } else if (_selectedOrder == 'Code') {
        comparison = a["management_unit_code"]
                ?.compareTo(b["management_unit_code"] ?? '') ??
            0;
      } else if (_selectedOrder == 'System') {
        comparison = a["management_unit_system"]
                ?.compareTo(b["management_unit_system"] ?? '') ??
            0;
      }
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: filteredUnits.isEmpty
          ? const Center(
              child: Text(
                'No matching management units found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: filteredUnits.length,
              itemBuilder: (context, index) {
                final unit = filteredUnits[index];
                return listViewItem(
                    name: unit["management_unit_name"] ?? "",
                    system: unit["management_unit_system"] ?? "",
                    code: unit["management_unit_code"] ?? "");
              },
            ),
    );
  }

  Widget _stockDataList({required String stockData}) {
    if (isExistDataInfoFromAPI &&
        _responseDataInfo?["result"][stockData].length == 0) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    final List<dynamic> list =
        List.from(_responseDataInfo!["result"][stockData]);

    final filteredData = list
        .where((data) =>
            _searchQuery.isEmpty ||
            (data["value"]?.toString().contains(_searchQuery) ?? false) ||
            (data["unit"]?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false) ||
            (data["type"]?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false) ||
            (data["db_source"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (data["reporting_year"]?.toString().contains(_searchQuery) ??
                false) ||
            (data["reference_year"]?.toString().contains(_searchQuery) ??
                false))
        .toList();

    filteredData.sort((a, b) {
      int comparison = 0;
      if (_selectedOrderStockData == 'Value') {
        comparison = (a["value"]?.compareTo(b["value"] ?? '') ?? 0);
      } else if (_selectedOrderStockData == 'Unit') {
        comparison = (a["unit"]?.compareTo(b["unit"] ?? '') ?? 0);
      } else if (_selectedOrderStockData == 'Type') {
        comparison = (a["type"]?.compareTo(b["type"] ?? 0) ?? 0);
      } else if (_selectedOrderStockData == 'Data Owner') {
        comparison = (a["db_source"]?.compareTo(b["db_source"] ?? '') ?? 0);
      } else if (_selectedOrderStockData == 'Rep. Year') {
        comparison =
            (a["reporting_year"]?.compareTo(b["reporting_year"] ?? '') ?? 0);
      } else if (_selectedOrderStockData == 'Ref. Year') {
        comparison =
            (a["reference_year"]?.compareTo(b["reference_year"] ?? '') ?? 0);
      }
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: filteredData.isEmpty
          ? const Center(
              child: Text(
                'No matching records found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final data = filteredData[index];
                return listViewItemStockData(
                  data["value"]?.toString() ?? "",
                  data["unit"] ?? "",
                  data["type"] ?? "",
                  data["db_source"] ?? "",
                  data["reporting_year"]?.toString() ?? "",
                  data["reference_year"]?.toString() ?? "",
                );
              },
            ),
    );
  }
}
