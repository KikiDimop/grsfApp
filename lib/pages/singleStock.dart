import 'package:grsfApp/models/areasForStock.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/models/speciesForStock.dart';
import 'package:grsfApp/models/stock.dart';
import 'package:grsfApp/models/stockOwner.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
                              _listTitle(title: 'Assessment Areas'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                    searchHint: 'Search Area',
                                    listDisplay: _areasList(),
                                    displayDropDown: true),
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
                              _listTitle(title: 'Species'),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                    searchHint: 'Search Species',
                                    listDisplay: _speciesList(),
                                    displayDropDown: true),
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
                                    displayDropDown: false),
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
                                    displayDropDown: false),
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
                              _listTitle(title: stockDataTitle),
                              const SizedBox(height: 5),
                              Expanded(
                                child: _displayList(
                                    searchHint: 'Search $stockDataTitle',
                                    listDisplay: _StockDataList(),
                                    displayDropDown: false),
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
                    _truncatedDisplay(
                        'Short Name', widget.stock.shortName ?? '', 35)
                  else
                    _truncatedDisplay('Short Name',
                        _responseData!["result"]["short_name"], 35),
                  if (!isExistDataFromAPI)
                    _truncatedDisplay(
                        'Semantic ID', widget.stock.grsfSemanticID ?? '', 35)
                  else
                    _truncatedDisplay('Semantic ID',
                        _responseData!["result"]["semantic_id"], 35),
                  if (!isExistDataFromAPI)
                    _truncatedDisplay(
                        'Semantic Title', widget.stock.grsfName ?? '', 35)
                  else
                    _truncatedDisplay('Semantic Title',
                        _responseData!["result"]["semantic_title"], 35),
                  if (!isExistDataFromAPI)
                    _truncatedDisplay('UUID', widget.stock.uuid ?? '', 35)
                  else
                    _truncatedDisplay(
                        'UUID', _responseData!["result"]["uuid"], 35),
                  _truncatedDisplay('Type', widget.stock.type ?? '', 35),
                  Row(
                    children: [
                      _imageButton(
                        assetPath: 'assets/icons/map.png',
                        onPressed: () => _showMap(context, 'Map'),
                      ),
                      Spacer(),
                      if (isExistDataFromAPI)
                        _iconButton(
                          icon: Icons.link,
                          onPressed: () => _sourceLink(),
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

  Future<void> _sourceLink() async {
    List<String> sourceUrls =
        List<String>.from(_responseData!["result"]["source_urls"] ?? []);

    if (sourceUrls.length == 1) {
      _openSourceLink(sourceUrls[0]);
    } else {
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
                children: sourceUrls.map((url) {
                  String siteName = Uri.parse(url).host.replaceAll("www.", "");
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ElevatedButton(
                      onPressed: () => _openSourceLink(url),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff16425B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        siteName,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xffd9dcd6)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
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

  Future<void> _openSourceLink(String link) async {
    final Uri url = Uri.parse(link);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
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

  void _showMap(BuildContext context, String title) {
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
                  child: Image.network(
                      '$urlStockPng${widget.stock.uuid ?? ''}$urlStockPngEnding'),
                ),
              ],
            ),
          ),
        );
      },
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
                    _buildSpeciesDetails(species!.first),
                  if (areas!.length == 1) _buildAreaDetails(areas!.first),
                  if (owners!.length == 1) _buildOwnerDetails(owners!.first),
                  if (faoAreas!.length == 1)
                    _buildFaoMajorAreaDetails(faoAreas!.first),
                  Wrap(
                    spacing: 3,
                    runSpacing: 1,
                    alignment: WrapAlignment.start,
                    children: [
                      if (species!.length > 1)
                        _button(
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
                        _button(
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
                        _button(
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
                        _button(
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
                    padding: EdgeInsets.only(bottom: 4),
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
          _button(
              label: 'scientific_advices',
              onPressed: () {
                stockDataTitle = 'Scientific Advices';
                stockData = 'scientific_advices';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["assessment_methods"].length != 0)
          _button(
              label: 'assessment_methods',
              onPressed: () {
                stockDataTitle = 'Assessment Methods';
                stockData = 'assessment_methods';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["abundance_level"].length != 0)
          _button(
              label: 'abundance_level',
              onPressed: () {
                stockDataTitle = 'Abundance Level';
                stockData = 'abundance_level';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["abundance_level_standard"].length !=
                0)
          _button(
              label: 'abundance_level_standard',
              onPressed: () {
                stockDataTitle = 'Abundance Level Standard';
                stockData = 'abundance_level_standard';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["fishing_pressure"].length != 0)
          _button(
              label: 'fishing_pressure',
              onPressed: () {
                stockDataTitle = 'Fishing Pressure';
                stockData = 'fishing_pressure';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["fishing_pressure_standard"].length !=
                0)
          _button(
              label: 'fishing_pressure_standard',
              onPressed: () {
                stockDataTitle = 'Fishing Pressure Standard';
                stockData = 'fishing_pressure_standard';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["catches"].length != 0)
          _button(
              label: 'catches',
              onPressed: () {
                stockDataTitle = 'Catches';
                stockData = 'catches';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["landings"].length != 0)
          _button(
              label: 'landings',
              onPressed: () {
                stockDataTitle = 'Landings';
                stockData = 'landings';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["landed_volumes"].length != 0)
          _button(
              label: 'landed_volumes',
              onPressed: () {
                stockDataTitle = 'Landed Volumes';
                stockData = 'landed_volumes';
                display();
              }),
        if (isExistDataInfoFromAPI &&
            _responseDataInfo?["result"]["biomass"].length != 0)
          _button(
              label: 'biomass',
              onPressed: () {
                stockDataTitle = 'Biomas';
                stockData = 'biomass';
                display();
              }),
      ],
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

  Widget _imageButton({
    required VoidCallback onPressed,
    required String assetPath,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Image.asset(
        assetPath,
        width: 24,
        height: 24,
        color: const Color(0xff16425B), // Optional: Apply color overlay
      ),
      splashRadius: 24,
    );
  }

  Widget _iconButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: const Color(0xff16425B), // Icon color
        size: 24, // Icon size
      ),
      splashRadius: 24, // Adjusts the splash effect size
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
                final item = filteredSpecies[index];
                return _listViewItem(item: item);
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
                final item = owners![index];
                return _listViewItem(item: item);
              },
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

  Widget _StockDataList() {
    final List<dynamic> list =
        List.from(_responseDataInfo!["result"][stockData]);

    final filteredCatches = list
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
                final data = filteredCatches[index];
                return _listViewItemStockData(
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

  Widget _listViewItemStockData(String value, String unit, String type,
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
                const SizedBox(width: 16), // Spacing between Value and Unit
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
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
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
                const SizedBox(width: 16), // Spacing between Years
                Column(
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
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ],
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
          ],
        ),
      ),
    );
  }
}
