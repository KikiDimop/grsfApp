import 'package:grsfApp/models/areasForStock.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/models/speciesForStock.dart';
import 'package:grsfApp/models/stock.dart';
import 'package:grsfApp/models/stockOwner.dart';
import 'package:grsfApp/pages/list_display.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/identity_card.dart';
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
      //debugPrint('Error fetching API data: $e');
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
      //debugPrint('Error fetching API data: $e');
    }
  }

  String stockDataTitle = '';
  String stockData = '';

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
                      _identitySection(),
                      const SizedBox(height: 5),
                      _detailsSection(context),
                      const SizedBox(height: 5),
                      if (isExistDataInfoFromAPI) _dataSection(context)
                    ],
                  ),
                ),
    );
  }

  Widget _identitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Stock Identity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffd9dcd6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (!isExistDataFromAPI)
                ? IdentityCard(
                    name: widget.stock.shortName ?? '',
                    id: widget.stock.grsfSemanticID ?? '',
                    title: widget.stock.grsfName ?? '',
                    uuid: widget.stock.uuid ?? '',
                    type: widget.stock.type ?? '',
                    status: widget.stock.status ?? '')
                : IdentityCard(
                    name: _responseData!["result"]["short_name"],
                    id: _responseData!["result"]["semantic_id"],
                    title: _responseData!["result"]["semantic_title"],
                    uuid: _responseData!["result"]["uuid"],
                    type: widget.stock.type ?? '',
                    status: _responseData!["result"]["status"],
                    url: _responseData!["result"]["source_urls"][0] ?? '',
                  )
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GenericDisplayList<SpeciesForStock>(
                                  items: species,
                                  identity: _identitySection(),
                                  listTitle: 'Species',
                                  searchHint: 'Search Species',
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
                      if (areas!.length > 1)
                        customButton(
                          label: 'Areas',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GenericDisplayList<AreasForStock>(
                                  items: areas,
                                  identity: _identitySection(),
                                  listTitle: 'Areas',
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
                                    GenericDisplayList<StockOwner>(
                                  items: owners,
                                  identity: _identitySection(),
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
                      if (faoAreas!.length > 1)
                        customButton(
                          label: 'FAO Major Areas',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GenericDisplayList<FaoMajorArea>(
                                  items: faoAreas,
                                  identity: _identitySection(),
                                  listTitle: 'Fao Major Areas',
                                  searchHint: 'Search Fao Major Area',
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericDisplayList(
          forStockData: true,
          items: const [],
          identity: _identitySection(),
          listTitle: stockDataTitle,
          searchHint: 'Search $stockDataTitle',
          sortOptions: const [
            SortOption(value: 'Value', label: 'Order by Value'),
            SortOption(value: 'Unit', label: 'Order by Unit'),
            SortOption(value: 'Data Owner', label: 'Order by Data Owner'),
            // SortOption(value: 'Type', label: 'Order by Type'),
            SortOption(value: 'Ref. Year', label: 'Order by Ref. Year'),
            SortOption(value: 'Rep. Year', label: 'Order by Rep. Year'),
          ],
          itemBuilder: (data) => listViewItemStockData(
            data["value"]?.toString() ?? "",
            data["unit"] ?? "",
            data["type"] ?? "",
            data["db_source"] ?? "",
            data["reporting_year"]?.toString() ?? "",
            data["reference_year"]?.toString() ?? "",
          ),
          stockdataList: List.from(_responseDataInfo!["result"][stockData]),
        ),
      ),
    );
  }

  Widget displayTimeseries() {
    if (!isExistDataInfoFromAPI || _responseDataInfo == null) {
      return const SizedBox.shrink();
    }

    final result = _responseDataInfo!["result"];
    List<Widget> buttons = [];

    // Helper method to create buttons conditionally
    void addButtonIfDataExists(String key, String label, String title) {
      if (result[key]?.isNotEmpty == true) {
        buttons.add(customButton(
          label: label,
          onPressed: () {
            stockDataTitle = title;
            stockData = key;
            display();
          },
        ));
      }
    }

    addButtonIfDataExists(
        'scientific_advices', 'scientific_advices', 'Scientific Advices');
    addButtonIfDataExists(
        'assessment_methods', 'assessment_methods', 'Assessment Methods');
    addButtonIfDataExists(
        'abundance_level', 'abundance_level', 'Abundance Level');
    addButtonIfDataExists('abundance_level_standard',
        'abundance_level_standard', 'Abundance Level Standard');
    addButtonIfDataExists(
        'fishing_pressure', 'fishing_pressure', 'Fishing Pressure');
    addButtonIfDataExists('fishing_pressure_standard',
        'fishing_pressure_standard', 'Fishing Pressure Standard');
    addButtonIfDataExists('catches', 'catches', 'Catches');
    addButtonIfDataExists('landings', 'landings', 'Landings');
    addButtonIfDataExists('landed_volumes', 'landed_volumes', 'Landed Volumes');
    addButtonIfDataExists('biomass', 'biomass', 'Biomass');

    return Column(children: buttons);
  }
}
