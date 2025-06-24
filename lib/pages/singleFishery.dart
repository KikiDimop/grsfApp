import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/fishery.dart';
import 'package:grsfApp/models/fisheryOwner.dart';
import 'package:grsfApp/models/fishingGear.dart';
import 'package:grsfApp/models/flag.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchDataFromAPI();
    _fetchDataInfoFromAPI();
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
      print('Error fetching API data: $e');
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
      print('Error fetching API data: $e');
    }
  }

  bool _showDetails = true;
  bool _showAreasList = false;
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
            if (_showAreasList ||
                _showOwnerList ||
                _showManagementUnitsList ||
                _showCatches ||
                _showLandings ||
                _showFaoMajorAreaList ||
                _showFlagStatesList) {
              setState(() {
                _showDetails = true;
                _showAreasList = false;
                _showOwnerList = false;
                _showManagementUnitsList = false;
                _showCatches = false;
                _showLandings = false;
                _showFaoMajorAreaList = false;
                _showFlagStatesList = false;
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
                      _identitySection(context),
                      const SizedBox(height: 5),
                      if (_showDetails)
                        _detailsSection(context)
                      else if (_showAreasList)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listTitle(title: 'Assessment Areas'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                  searchHint: 'Search Area',
                                  listDisplay: _areasList(),
                                  displayDropDown: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showOwnerList)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listTitle(title: 'Owners'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                  searchHint: 'Search Owner',
                                  listDisplay: _ownersList(),
                                  displayDropDown: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showGearsList)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listTitle(title: 'Fishing Gears'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                  searchHint: 'Search Fishing Gears',
                                  listDisplay: _gearsList(),
                                  displayDropDown: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showManagementUnitsList)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listTitle(title: 'Management Units'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                  searchHint: 'Search Management Unit',
                                  listDisplay: _managementUnitsList(),
                                  displayDropDown: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showCatches)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listTitle(title: 'Catches'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                  searchHint: 'Search Catch',
                                  listDisplay: _catchesList(),
                                  displayDropDown: false,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showLandings)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listTitle(title: 'Landings'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                  searchHint: 'Search Landing',
                                  listDisplay: _landingsList(),
                                  displayDropDown: false,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showFaoMajorAreaList)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listTitle(title: 'Fao Major Areas'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                  searchHint: 'Search Fao Major Area',
                                  listDisplay: _faoMajorAreaList(),
                                  displayDropDown: false,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showFlagStatesList)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _listTitle(title: 'Flag States'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                  searchHint: 'Search flag state',
                                  listDisplay: _flagStatesList(),
                                  displayDropDown: false,
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
      {required String searchHint,
      required Widget listDisplay,
      required bool displayDropDown}) {
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
            Column(
              children: [
                _searchField(hint: searchHint),
                if (displayDropDown) _orderByDropdown(),
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
                  if (!isExistDataFromAPI)
                    statusDisplay(widget.fishery.status ?? '')
                  else
                    statusDisplay(_responseData!["result"]["status"]),
                  if (!isExistDataFromAPI)
                    _truncatedDisplay(
                        'Short Name', widget.fishery.shortName ?? '', 35)
                  else
                    _truncatedDisplay('Short Name',
                        _responseData!["result"]["short_name"], 35),
                  if (!isExistDataFromAPI)
                    _truncatedDisplay(
                        'Semantic ID', widget.fishery.grsfSemanticID ?? '', 35)
                  else
                    _truncatedDisplay('Semantic ID',
                        _responseData!["result"]["semantic_id"], 35),
                  if (!isExistDataFromAPI)
                    _truncatedDisplay(
                        'Semantic Title', widget.fishery.grsfName ?? '', 35)
                  else
                    _truncatedDisplay('Semantic Title',
                        _responseData!["result"]["semantic_title"], 35),
                  if (!isExistDataFromAPI)
                    _truncatedDisplay('UUID', widget.fishery.uuid ?? '', 35)
                  else
                    _truncatedDisplay(
                        'UUID', _responseData!["result"]["uuid"], 35),
                  _truncatedDisplay('Type', widget.fishery.type ?? '', 35),
                  if (isExistDataFromAPI)
                    Align(
                      alignment: Alignment.centerRight,
                      child: _iconButton(
                        icon: Icons.link,
                        onPressed: () => _openSourceLink(
                            _responseData!["result"]["source_urls"][0] ?? ''),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openSourceLink(String link) async {
    final Uri url = Uri.parse(link);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _iconButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: const Color(0xff16425B),
        size: 24,
      ),
      splashRadius: 24,
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
                          displayTitle('Species'),
                          if (!isExistDataFromAPI)
                            displayRow(
                                'Code     : ', widget.fishery.speciesCode ?? '')
                          else
                            displayRow(
                                'Code     : ',
                                _responseData!["result"]["species"]
                                        ["species_code"] ??
                                    ''),
                          if (!isExistDataFromAPI)
                            displayRow(
                                'System : ', widget.fishery.speciesType ?? '')
                          else
                            displayRow(
                                'System : ',
                                _responseData!["result"]["species"]
                                        ["species_type"] ??
                                    ''),
                          if (!isExistDataFromAPI)
                            displayRowWithIcon(
                                'Name    : ',
                                widget.fishery.speciesName ?? '',
                                () => _openSourceLink(
                                    'https://images.google.com/search?tbm=isch&q=${widget.fishery.speciesName ?? ''}'),
                                Icons.image)
                          else
                            displayRowWithIcon(
                                'Name    : ',
                                _responseData!["result"]["species"]
                                        ["species_name"] ??
                                    '',
                                () => _openSourceLink(
                                    'https://images.google.com/search?tbm=isch&q=${_responseData!["result"]["species"]["species_name"] ?? ''}'),
                                Icons.image),
                        ]),
                  ),
                  if (areas!.length == 1) _buildAreaDetails(areas!.first),
                  if (owners!.length == 1) _buildOwnerDetails(owners!.first),
                  if (gears!.length == 1) _buildGearDetails(gears!.first),
                  if (faoAreas!.length == 1)
                    _buildFaoMajorAreaDetails(faoAreas!.first),
                  simpleDisplay('Management Authority',
                      widget.fishery.managementEntities ?? '-'),
                  if (isExistDataFromAPI && flags!.length == 1)
                    displayFlagState(),
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
                              _showManagementUnitsList = false;
                              _showFaoMajorAreaList = false;
                              _showFlagStatesList = false;
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
                              _showManagementUnitsList = false;
                              _showFaoMajorAreaList = false;
                              _showFlagStatesList = false;
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
                              _showGearsList = true;
                              _showManagementUnitsList = false;
                              _showFaoMajorAreaList = false;
                              _showFlagStatesList = false;
                            });
                          },
                        ),
                      if (faoAreas!.length > 1)
                        _button(
                          label: 'FAO Major Areas',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = false;
                              _showGearsList = false;
                              _showManagementUnitsList = false;
                              _showFaoMajorAreaList = true;
                              _showFlagStatesList = false;
                            });
                          },
                        ),
                      if (flags!.length > 1)
                        _button(
                          label: 'Flag States',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = false;
                              _showGearsList = false;
                              _showManagementUnitsList = false;
                              _showFaoMajorAreaList = false;
                              _showFlagStatesList = true;
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

  Widget _buildFaoMajorAreaDetails(FaoMajorArea faoMajorArea) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fao Major Area',
            style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
          ),
          displayRow('Code     : ', faoMajorArea.faoMajorAreaCode ?? ''),
          displayRow('Name    : ', faoMajorArea.faoMajorAreaName ?? ''),
        ],
      ),
    );
  }

  Widget displayManagmentAuthority() {
    if (_responseData!["result"]["management_units"].length == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            displayTitle('Management Authority'),
            displayRow(
              'Code     : ',
              _responseData!["result"]["management_units"][0]
                      ["management_unit_code"] ??
                  '',
            ),
            displayRow(
              'System : ',
              _responseData!["result"]["management_units"][0]
                      ["management_unit_system"] ??
                  '',
            ),
            displayRow(
              'Name    : ',
              _responseData!["result"]["management_units"][0]
                      ["management_unit_name"] ??
                  '',
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Padding displayFlagState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          displayTitle('Flag State'),
          displayRow(
            'Code     : ',
            _responseData!["result"]["flag_states"]["flag_state_code"] ?? '',
          ),
          displayRow(
            'System : ',
            _responseData!["result"]["flag_states"]["flag_state_type"] ?? '',
          ),
          displayRow(
            'Name    : ',
            _responseData!["result"]["flag_states"]["flag_state_name"] ?? '',
          ),
        ],
      ),
    );
  }

  Padding displayAssessmentAreas() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          displayTitle('Assessment Areas'),
          displayRow(
            'Code     : ',
            _responseData!["result"]["assessment_areas"]
                    ["assessment_area_code"] ??
                '',
          ),
          displayRow(
            'System : ',
            _responseData!["result"]["assessment_areas"]
                    ["assessment_area_type"] ??
                '',
          ),
          displayRow(
            'Name    : ',
            _responseData!["result"]["assessment_areas"]
                    ["assessment_area_name"] ??
                '',
          ),
        ],
      ),
    );
  }

  Text displayTitle(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, color: Color(0xff16425B)),
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
          // displayRow('Name    : ', gear.fishingGearName ?? ''),
          displayRowWithIcon(
              'Name    : ',
              gear.fishingGearName ?? '',
              () => _openSourceLink(
                  'https://images.google.com/search?tbm=isch&q=${gear.fishingGearName ?? ''}'),
              Icons.image)
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
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xff16425B),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget displayRowWithIcon(
      String label, String value, VoidCallback onIconPressed, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xff16425B),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: onIconPressed,
              child: Icon(
                icon,
                color: const Color(0xff16425B),
                size: 20,
              ),
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

  Align statusDisplay(String status) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        status,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: getColor(status),
        ),
      ),
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
                  onPressed: (isExistDataInfoFromAPI &&
                          _responseDataInfo?["result"]["catches"].length != 0)
                      ? () {
                          setState(() {
                            _showDetails = false;
                            _showAreasList = false;
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
                            _showAreasList = false;
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
    } else if (item is FaoMajorArea) {
      code = item.faoMajorAreaCode ?? 'No Code';
      name = item.faoMajorAreaName ?? 'No Name';
      system = item.faoMajorAreaConcat ?? 'No System';
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

  Widget _listViewItemManagementUnit(String name, String system, String code) {
    if (name == '' && system == '' && code == '') return SizedBox.shrink();
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
            if (system.isNotEmpty && code.isNotEmpty)
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
                return _listViewItemManagementUnit(
                    unit["management_unit_name"] ?? "",
                    unit["management_unit_system"] ?? "",
                    unit["management_unit_code"] ?? "");
              },
            ),
    );
  }

  Widget _catchesList() {
    if (isExistDataInfoFromAPI &&
        _responseDataInfo?["result"]["catches"].length == 0) {
      return const Center(
        child: Text(
          'No catch data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    final List<dynamic> catches =
        List.from(_responseDataInfo!["result"]["catches"]);

    final filteredCatches = catches
        .where((catchData) =>
            _searchQuery.isEmpty ||
            (catchData["value"]?.toString().contains(_searchQuery) ?? false) ||
            (catchData["unit"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (catchData["type"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (catchData["db_source"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (catchData["reporting_year"]?.toString().contains(_searchQuery) ??
                false) ||
            (catchData["reference_year"]?.toString().contains(_searchQuery) ??
                false))
        .toList();

    filteredCatches.sort((a, b) {
      int comparison = 0;
      if (_selectedOrder == 'Rep. Year') {
        comparison =
            (a["reporting_year"]?.compareTo(b["reporting_year"] ?? '') ?? 0);
      } else if (_selectedOrder == 'Value') {
        comparison = (a["value"]?.compareTo(b["value"] ?? 0) ?? 0);
      } else if (_selectedOrder == 'Ref. Year') {
        comparison =
            (a["reference_ear"]?.compareTo(b["reference_ear"] ?? '') ?? 0);
      }
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: filteredCatches.isEmpty
          ? const Center(
              child: Text(
                'No matching catch records found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: filteredCatches.length,
              itemBuilder: (context, index) {
                final catchData = filteredCatches[index];
                return _listViewItemCatch(
                  catchData["value"]?.toString() ?? "",
                  catchData["unit"] ?? "",
                  catchData["type"] ?? "",
                  catchData["db_source"] ?? "",
                  catchData["reporting_year"]?.toString() ?? "",
                  catchData["reference_year"]?.toString() ?? "",
                );
              },
            ),
    );
  }

  Widget _landingsList() {
    if (isExistDataInfoFromAPI &&
        _responseDataInfo?["result"]["landings"].length == 0) {
      return const Center(
        child: Text(
          'No landing data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    final List<dynamic> landings =
        List.from(_responseDataInfo!["result"]["landings"]);

    final filteredCatches = landings
        .where((landingData) =>
            _searchQuery.isEmpty ||
            (landingData["value"]?.toString().contains(_searchQuery) ??
                false) ||
            (landingData["unit"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (landingData["type"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (landingData["db_source"]
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (landingData["reporting_year"]?.toString().contains(_searchQuery) ??
                false) ||
            (landingData["reference_year"]?.toString().contains(_searchQuery) ??
                false))
        .toList();

    filteredCatches.sort((a, b) {
      int comparison = 0;
      if (_selectedOrder == 'Rep. Year') {
        comparison =
            (a["reporting_year"]?.compareTo(b["reporting_year"] ?? '') ?? 0);
      } else if (_selectedOrder == 'Value') {
        comparison = (a["value"]?.compareTo(b["value"] ?? 0) ?? 0);
      } else if (_selectedOrder == 'Ref. Year') {
        comparison =
            (a["reference_ear"]?.compareTo(b["reference_ear"] ?? '') ?? 0);
      }
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: filteredCatches.isEmpty
          ? const Center(
              child: Text(
                'No matching landing records found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: filteredCatches.length,
              itemBuilder: (context, index) {
                final landingData = filteredCatches[index];
                return _listViewItemCatch(
                  landingData["value"]?.toString() ?? "",
                  landingData["unit"] ?? "",
                  landingData["type"] ?? "",
                  landingData["db_source"] ?? "",
                  landingData["reporting_year"]?.toString() ?? "",
                  landingData["reference_year"]?.toString() ?? "",
                );
              },
            ),
    );
  }

  Widget _listViewItemCatch(String value, String unit, String type,
      String source, String reportingYear, String referenceYear) {
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
            // First Row: Value and Unit
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Value',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff16425B),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff16425B),
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
                const SizedBox(width: 8), // Spacing between Value and Unit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff16425B),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff16425B),
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Data Owner',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff16425B),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              source,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 8), // Spacing before Type
            // Type Section
            const Text(
              'Type',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff16425B),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              type,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reference Year',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff16425B),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        referenceYear,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff16425B),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reporting Year',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff16425B),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        reportingYear,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff16425B),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        maxLines: null,
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

  Widget _faoMajorAreaList() {
    if (faoAreas == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    faoAreas = faoAreas?.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: faoAreas!.isEmpty
          ? const Center(
              child: Text(
                'No areas found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: faoAreas!.length,
              itemBuilder: (context, index) {
                final item = faoAreas![index];
                return _listViewItem(item: item);
              },
            ),
    );
  }

  Widget _flagStatesList() {
    if (flags == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    flags = flags?.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: flags!.isEmpty
          ? const Center(
              child: Text(
                'No areas found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: flags!.length,
              itemBuilder: (context, index) {
                final item = flags![index];
                return _listViewItem(item: item);
              },
            ),
    );
  }
}
