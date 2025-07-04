import 'package:grsfApp/models/areasForStock.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/models/speciesForStock.dart';
import 'package:grsfApp/models/stock.dart';
import 'package:grsfApp/models/stockOwner.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/global_ui.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplaySingleStock extends StatefulWidget {
  final Stock stock;
  const DisplaySingleStock({super.key, required this.stock});

  @override
  State<DisplaySingleStock> createState() => _DisplaySingleStockState();
}

class _DisplaySingleStockState extends State<DisplaySingleStock> {
  List<AreasForStock>? areas;
  List<StockOwner>? owners;
  List<FaoMajorArea>? faoAreas;
  List<SpeciesForStock>? species;
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
    _fetchData();
    _fetchDataFromAPI();
    _fetchDataInfoFromAPI();
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
        DatabaseService.instance
            .getFaoMajorAreas(widget.stock.parentAreas ?? '')
      ]);

      setState(() {
        areas = results[0] as List<AreasForStock>;
        owners = results[1] as List<StockOwner>;
        species = results[2] as List<SpeciesForStock>;
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
          'https://isl.ics.forth.gr/grsf/grsf-api/resources/getstockbasic?uuid=${widget.stock.uuid}&response_type=JSON'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _responseData = data;
          isLoading2 = false;
          isExistDataFromAPI = true;

          //Fill lists from api data
          final rawSpecies = _responseData!['result']['species'];
          final rawAreas = _responseData!['result']['assessment_areas'];

          final List<dynamic> speciesList =
              rawSpecies is List ? rawSpecies : [rawSpecies];
          final List<dynamic> areaList =
              rawAreas is List ? rawAreas : [rawAreas];

          species = speciesList
              .map((item) => SpeciesForStock.fromJson(item))
              .toList();
          areas = areaList.map((item) => AreasForStock.fromJson(item)).toList();
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
          'https://isl.ics.forth.gr/grsf/grsf-api/resources/getstock?uuid=${widget.stock.uuid}&response_type=JSON'));

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
  bool _showSpeciesList = false;
  bool _showOwnerList = false;
  bool _showFaoMajorAreaList = false;
  bool _showStockDataList = false;

  String stockDataTitle = '';
  String stockData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (_showAreasList ||
                _showSpeciesList ||
                _showOwnerList ||
                _showFaoMajorAreaList ||
                _showStockDataList) {
              setState(() {
                _showDetails = true;
                _showAreasList = false;
                _showSpeciesList = false;
                _showOwnerList = false;
                _showFaoMajorAreaList = false;
                _showStockDataList = false;
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
                              listTitle(title: 'Assessment Areas'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                    searchHint: 'Search Area',
                                    listDisplay: dataList<AreasForStock>(
                                        items: areas,
                                        searchQuery: _searchQuery,
                                        sortField: _selectedOrder,
                                        sortOrder: _sortOrder,
                                        listViewItem: ({required item}) =>
                                            listViewItem(
                                                item: item)), //_areasList(),
                                    displayDropDown: true,
                                    forStockData: false),
                              ),
                            ],
                          ),
                        )
                      else if (_showSpeciesList)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              listTitle(title: 'Species'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                    searchHint: 'Search Species',
                                    listDisplay: dataList<SpeciesForStock>(
                                        items: species,
                                        searchQuery: _searchQuery,
                                        sortField: _selectedOrder,
                                        sortOrder: _sortOrder,
                                        listViewItem: ({required item}) =>
                                            listViewItem(
                                                item: item)), //_speciesList(),
                                    displayDropDown: true,
                                    forStockData: false),
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
                              listTitle(title: 'Owners'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                    searchHint: 'Search Owner',
                                    listDisplay: dataList<StockOwner>(
                                        items: owners,
                                        searchQuery: _searchQuery,
                                        sortField: _selectedOrder,
                                        sortOrder: _sortOrder,
                                        listViewItem: ({required item}) =>
                                            listViewItem(
                                                item: item)), //_ownersList(),
                                    displayDropDown: false,
                                    forStockData: false),
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
                              listTitle(title: 'Fao Major Areas'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                    searchHint: 'Search Fao Major Area',
                                    listDisplay: dataList<FaoMajorArea>(
                                        items: faoAreas,
                                        searchQuery: _searchQuery,
                                        sortField: _selectedOrder,
                                        sortOrder: _sortOrder,
                                        listViewItem: ({required item}) =>
                                            listViewItem(
                                                item:
                                                    item)), //_faoMajorAreaList(),
                                    displayDropDown: true,
                                    forStockData: false),
                              ),
                            ],
                          ),
                        )
                      else if (_showStockDataList)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              listTitle(title: stockDataTitle),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                    searchHint: 'Search $stockDataTitle',
                                    listDisplay: _stockDataList(),
                                    displayDropDown: true,
                                    forStockData: true),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 5),
                      if (isExistDataInfoFromAPI && _showDetails)
                        _dataSection(context)
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
                  if (!isExistDataFromAPI)
                    statusDisplay(widget.stock.status ?? '')
                  else
                    statusDisplay(_responseData!["result"]["status"]),
                  if (!isExistDataFromAPI)
                    dataDisplay(
                        label: 'Short Name',
                        value: widget.stock.shortName ?? '')
                  else
                    dataDisplay(
                        label: 'Short Name',
                        value: _responseData!["result"]["short_name"]),
                  if (!isExistDataFromAPI)
                    dataDisplay(
                        label: 'Semantic ID',
                        value: widget.stock.grsfSemanticID ?? '')
                  else
                    dataDisplay(
                        label: 'Semantic ID',
                        value: _responseData!["result"]["semantic_id"]),
                  if (!isExistDataFromAPI)
                    dataDisplay(
                        label: 'Semantic Title',
                        value: widget.stock.grsfName ?? '')
                  else
                    dataDisplay(
                        label: 'Semantic Title',
                        value: _responseData!["result"]["semantic_title"]),
                  if (!isExistDataFromAPI)
                    dataDisplay(label: 'UUID', value: widget.stock.uuid ?? '')
                  else
                    dataDisplay(
                        label: 'UUID', value: _responseData!["result"]["uuid"]),
                  dataDisplay(label: 'Type', value: widget.stock.type ?? ''),
                  Row(
                    children: [
                      iButton(
                        assetPath: 'assets/icons/map.png',
                        onPressed: () =>
                            showMap(context, 'Map', widget.stock.uuid ?? ''),
                        icon: null,
                        iconSize: 24
                      ),
                      const Spacer(),
                      if (isExistDataFromAPI)
                        iButton(
                          icon: Icons.link,
                          onPressed: () => sourceLink(
                              List<String>.from(_responseData!["result"]
                                      ["source_urls"] ??
                                  []),
                              context),
                          assetPath: '',
                        iconSize: 24
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailsSection(BuildContext context) {
    if (areas == null ||
        owners == null ||
        species == null ||
        faoAreas == null) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (species!.length == 1)
                    //_buildSpeciesDetails(species!.first),
                    dataDetailsDisplay(
                        label: 'Species',
                        code: species!.first.speciesCode ?? '',
                        system: species!.first.speciesType ?? '',
                        name: species!.first.speciesName ?? '',
                        withIcon: true,
                        onIconPressed: () => openSourceLink(
                            'https://images.google.com/search?tbm=isch&q=${species!.first.speciesName ?? ''}'),
                        icon: Icons.image),
                  if (areas!.length == 1)
                    //_buildAreaDetails(areas!.first),
                    dataDetailsDisplay(
                        label: 'Assessment Area Details',
                        code: areas!.first.areaCode ?? '',
                        system: areas!.first.areaType ?? '',
                        name: areas!.first.areaName ?? '',
                        withIcon: false),
                  if (owners!.length == 1)
                    // _buildOwnerDetails(owners!.first),
                    dataDisplay(
                        label: 'Data Owner', value: owners!.first.owner ?? ''),
                  if (faoAreas!.length == 1)
                    //_buildFaoMajorAreaDetails(faoAreas!.first),
                    dataDetailsDisplay(
                        label: 'Fao Major Area',
                        code: faoAreas!.first.faoMajorAreaCode ?? '',
                        system: '',
                        name: faoAreas!.first.faoMajorAreaName ?? '',
                        withIcon: false),
                  Wrap(
                    spacing: 3,
                    runSpacing: 1,
                    alignment: WrapAlignment.start,
                    children: [
                      if (species!.length > 1)
                        customButton(
                          label: 'Species',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = false;
                              _showSpeciesList = true;
                              _showFaoMajorAreaList = false;
                            });
                          },
                        ),
                      if (areas!.length > 1)
                        customButton(
                          label: 'Areas',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = true;
                              _showOwnerList = false;
                              _showSpeciesList = false;
                              _showFaoMajorAreaList = false;
                            });
                          },
                        ),
                      if (owners!.length > 1)
                        customButton(
                          label: 'Owners',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = true;
                              _showSpeciesList = false;
                              _showFaoMajorAreaList = false;
                            });
                          },
                        ),
                      if (faoAreas!.length > 1)
                        customButton(
                          label: 'FAO Major Areas',
                          onPressed: () {
                            setState(() {
                              _showDetails = false;
                              _showAreasList = false;
                              _showOwnerList = false;
                              _showSpeciesList = false;
                              _showFaoMajorAreaList = true;
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

  Widget _dataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Stock Data',
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        displayTimeseries(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  void display() {
    setState(() {
      _showDetails = false;
      _showAreasList = false;
      _showOwnerList = false;
      _showSpeciesList = false;
      _showFaoMajorAreaList = false;
      _showStockDataList = true;
    });
  }

  Widget displayTimeseries() {
    return Column(
      children: [
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["scientific_advices"].length != 0)
          customButton(
              label: 'scientific_advices',
              onPressed: () {
                stockDataTitle = 'Scientific Advices';
                stockData = 'scientific_advices';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["assessment_methods"].length != 0)
          customButton(
              label: 'assessment_methods',
              onPressed: () {
                stockDataTitle = 'Assessment Methods';
                stockData = 'assessment_methods';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["abundance_level"].length != 0)
          customButton(
              label: 'abundance_level',
              onPressed: () {
                stockDataTitle = 'Abundance Level';
                stockData = 'abundance_level';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["abundance_level_standard"].length !=
                0)
          customButton(
              label: 'abundance_level_standard',
              onPressed: () {
                stockDataTitle = 'Abundance Level Standard';
                stockData = 'abundance_level_standard';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["fishing_pressure"].length != 0)
          customButton(
              label: 'fishing_pressure',
              onPressed: () {
                stockDataTitle = 'Fishing Pressure';
                stockData = 'fishing_pressure';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["fishing_pressure_standard"].length !=
                0)
          customButton(
              label: 'fishing_pressure_standard',
              onPressed: () {
                stockDataTitle = 'Fishing Pressure Standard';
                stockData = 'fishing_pressure_standard';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["catches"].length != 0)
          customButton(
              label: 'catches',
              onPressed: () {
                stockDataTitle = 'Catches';
                stockData = 'catches';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["landings"].length != 0)
          customButton(
              label: 'landings',
              onPressed: () {
                stockDataTitle = 'Landings';
                stockData = 'landings';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["landed_volumes"].length != 0)
          customButton(
              label: 'landed_volumes',
              onPressed: () {
                stockDataTitle = 'Landed Volumes';
                stockData = 'landed_volumes';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["biomass"].length != 0)
          customButton(
              label: 'biomass',
              onPressed: () {
                stockDataTitle = 'Biomas';
                stockData = 'biomass';
                display();
              }),
      ],
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

  Widget _stockDataList() {
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
                'No matching catch records found',
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
