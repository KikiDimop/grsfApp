import 'dart:ffi';

import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/fishery.dart';
import 'package:grsfApp/models/fisheryOwner.dart';
import 'package:grsfApp/models/fishingGear.dart';
import 'package:grsfApp/models/flag.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/pages/list_display.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/identity_card.dart';
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
                    ],
                  ),
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
                ? IdentityCard(
                    name: widget.fishery.shortName ?? '',
                    id: widget.fishery.grsfSemanticID ?? '',
                    title: widget.fishery.grsfName ?? '',
                    uuid: widget.fishery.uuid ?? '',
                    type: widget.fishery.type ?? '',
                    status: widget.fishery.status ?? '')
                : IdentityCard(
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
                                  stockdataList: const [],
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
                                  stockdataList: const [],
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
                                  stockdataList: const [],
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
                                  stockdataList: const [],
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
                                  stockdataList: const [],
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
                  onPressed: () {
                    (isExistDataInfoFromAPI &&
                            _responseDataInfo?["result"]["catches"].length != 0)
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenericDisplayList(
                                forStockData: true,
                                items: const [],
                                identity: _identitySection(false),
                                listTitle: 'Catches',
                                searchHint: 'Search Catch',
                                sortOptions: const [
                                  SortOption(
                                      value: 'Value', label: 'Order by Value'),
                                  SortOption(
                                      value: 'Unit', label: 'Order by Unit'),
                                  SortOption(
                                      value: 'Data Owner',
                                      label: 'Order by Data Owner'),
                                  // SortOption(value: 'Type', label: 'Order by Type'),
                                  SortOption(
                                      value: 'Ref. Year',
                                      label: 'Order by Ref. Year'),
                                  SortOption(
                                      value: 'Rep. Year',
                                      label: 'Order by Rep. Year'),
                                ],
                                itemBuilder: (data) => listViewItemStockData(
                                  data["value"]?.toString() ?? "",
                                  data["unit"] ?? "",
                                  data["type"] ?? "",
                                  data["db_source"] ?? "",
                                  data["reporting_year"]?.toString() ?? "",
                                  data["reference_year"]?.toString() ?? "",
                                ),
                                stockdataList: List.from(
                                    _responseDataInfo!["result"]['catches']),
                              ),
                            ),
                          )
                        : null;
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
                    (isExistDataInfoFromAPI &&
                            _responseDataInfo?["result"]["landings"].length !=
                                0)
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenericDisplayList(
                                forStockData: true,
                                items: const [],
                                identity: _identitySection(false),
                                listTitle: 'Landings',
                                searchHint: 'Search Landing',
                                sortOptions: const [
                                  SortOption(
                                      value: 'Value', label: 'Order by Value'),
                                  SortOption(
                                      value: 'Unit', label: 'Order by Unit'),
                                  SortOption(
                                      value: 'Data Owner',
                                      label: 'Order by Data Owner'),
                                  // SortOption(value: 'Type', label: 'Order by Type'),
                                  SortOption(
                                      value: 'Ref. Year',
                                      label: 'Order by Ref. Year'),
                                  SortOption(
                                      value: 'Rep. Year',
                                      label: 'Order by Rep. Year'),
                                ],
                                itemBuilder: (data) => listViewItemStockData(
                                  data["value"]?.toString() ?? "",
                                  data["unit"] ?? "",
                                  data["type"] ?? "",
                                  data["db_source"] ?? "",
                                  data["reporting_year"]?.toString() ?? "",
                                  data["reference_year"]?.toString() ?? "",
                                ),
                                stockdataList: List.from(
                                    _responseDataInfo!["result"]['landings']),
                              ),
                            ),
                          )
                        : null;
                  },
                  // onPressed: (isExistDataInfoFromAPI &&
                  //         _responseDataInfo?["result"]["landings"].length != 0)
                  //     ? () {
                  //         setState(() {
                  //           _showDetails = false;
                  //           _showManagementUnitsList = false;
                  //           _showCatches = false;
                  //           _showLandings = true;
                  //         });
                  //         Navigator.of(context).pop();
                  //       }
                  //     : null,
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
}
