import 'package:grsfApp/global.dart';
import 'package:grsfApp/pages/stocks.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/autocomplete.dart';
import 'package:grsfApp/widgets/global_ui.dart';

class Searchstocks extends StatefulWidget {
  const Searchstocks({super.key});

  @override
  State<Searchstocks> createState() => _SearchstocksState();
}

class _SearchstocksState extends State<Searchstocks> {
  List<String> speciesTypes = [];
  List<String> speciesCodes = [];
  List<String> speciesNames = [];

  List<String> areaTypes = [];
  List<String> areaCodes = [];
  List<String> areaNames = [];

  List<String> faoMajorAreas = [];
  List<String> resourceType = [];
  List<String> resourceStatus = [];

  List<String> refYears = [];

  List<String> timeseries = [
    'Abundance Level',
    'Abundance Level - Standard',
    'Biomass',
    'Catches',
    'FAO Stock Status Category',
    'Fishing Pressure',
    'Fishing Pressure - Standard',
    'Landed Volume',
    'Landings',
    'Methods',
    'Scientific Advice',
    'State and Trend'
  ];

  @override
  void initState() {
    super.initState();
    _loadDropdownLists();
  }

  Future<void> _loadDropdownLists() async {
    final dbService = DatabaseService.instance;
    //Get distinct data for search in table SpeciesForStock
    final List<String> fetchedSpeciesTypes =
        await dbService.getDistinct('species_type', 'SpeciesForStock');
    final List<String> fetchedSpeciesCodes =
        await dbService.getDistinct('species_code', 'SpeciesForStock');
    final List<String> fetchedSpeciesNames =
        await dbService.getDistinct('species_name', 'SpeciesForStock');
    //Get distinct data for search in table AreasForStock
    final List<String> fetchedAreaTypes =
        await dbService.getDistinct('area_type', 'AreasForStock');
    final List<String> fetchedAreaCodes =
        await dbService.getDistinct('area_code', 'AreasForStock');
    final List<String> fetchedAreaNames =
        await dbService.getDistinct('area_name', 'AreasForStock');
    //Get distinct data for search in table FaoMajorArea
    final List<String> fetchedFAOMajorAreas =
        await dbService.getDistinct('fao_major_area_concat', 'FaoMajorArea');
    //Get distinct data for search in table Stock
    final List<String> fetchedResourceType =
        await dbService.getDistinct('type', 'Stock');
    final List<String> fetchedResourceStatus =
        await dbService.getDistinct('status', 'Stock');

    setState(() {
      speciesTypes = fetchedSpeciesTypes;
      speciesCodes = fetchedSpeciesCodes;
      speciesNames = fetchedSpeciesNames;

      areaTypes = fetchedAreaTypes;
      areaCodes = fetchedAreaCodes;
      areaNames = fetchedAreaNames;
      faoMajorAreas = fetchedFAOMajorAreas;

      resourceType = fetchedResourceType;
      resourceStatus = fetchedResourceStatus;
    });
  }

  String spType = '';
  String spCode = '';
  String spName = '';

  String aType = '';
  String aCode = '';
  String aName = '';
  String faoMajArea = '';

  String rType = '';
  String rStatus = '';

  String timeserie = '';

  TextEditingController refYear = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        title: const Text('Search Stock'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _speciesSection(),
            const SizedBox(height: 5),
            _areaSection(),
            const SizedBox(height: 5),
            _resourceSection(),
            const SizedBox(height: 5),
            _timeseriesSection(),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget _speciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Species',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffd9dcd6),
                ),
              ),
              const Spacer(),
              searchButton()
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffd9dcd6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomAutocomplete(
                      suggestions: speciesTypes,
                      labelText: 'Species Type',
                      hintText: '',
                      onSelected: (String selection) {
                        spType = selection;
                      },
                      onCleared: () {
                        spType = '';
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomAutocomplete(
                      suggestions: speciesCodes,
                      labelText: 'Species Code',
                      hintText: '',
                      onSelected: (String selection) {
                        spCode = selection;
                      },
                      onCleared: () {
                        spCode = '';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomAutocomplete(
                suggestions: speciesNames,
                labelText: 'Scientific Name',
                hintText: '',
                onSelected: (String selection) {
                  spName = selection;
                },
                onCleared: () {
                  spName = '';
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  ElevatedButton searchButton() {
    return ElevatedButton(
      onPressed: () {
        final searchStock = SearchStock(
          selectedSpeciesSystem: spType,
          speciesCode: spCode,
          speciesName: spName,
          selectedAreaSystem: aType,
          areaCode: aCode,
          areaName: aName,
          selectedFAOMajorArea: faoMajArea,
          selectedResourceType: rType,
          selectedResourceStatus: rStatus,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Stocks(
                search: searchStock,
                forSpecies: false,
                timeseries: timeserie,
                refYear: refYear.text),
          ),
          (route) => route.isFirst,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffd9dcd6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text(
        'Search',
        style: TextStyle(
            fontSize: 14,
            color: Color(0xff16425B),
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _areaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Area',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffd9dcd6),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffd9dcd6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomAutocomplete(
                      suggestions: areaTypes,
                      labelText: 'Area Type',
                      hintText: '',
                      onSelected: (String selection) {
                        aType = selection;
                      },
                      onCleared: () {
                        aType = '';
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomAutocomplete(
                      suggestions: areaCodes,
                      labelText: 'Area Code',
                      hintText: '',
                      onSelected: (String selection) {
                        aCode = selection;
                      },
                      onCleared: () {
                        aCode = '';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomAutocomplete(
                suggestions: areaNames,
                labelText: 'Area Name',
                hintText: '',
                onSelected: (String selection) {
                  aName = selection;
                },
                onCleared: () {
                  aName = '';
                },
              ),
              const SizedBox(height: 8),
              CustomAutocomplete(
                suggestions: faoMajorAreas,
                labelText: 'Fao Major Area',
                hintText: '',
                onSelected: (String selection) {
                  faoMajArea = selection;
                },
                onCleared: () {
                  faoMajArea = '';
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Resource',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffd9dcd6),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffd9dcd6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomAutocomplete(
                      suggestions: resourceType,
                      labelText: 'Resource Type',
                      hintText: '',
                      onSelected: (String selection) {
                        rType = selection;
                      },
                      onCleared: () {
                        rType = '';
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomAutocomplete(
                      suggestions: resourceStatus,
                      labelText: 'Resource Status',
                      hintText: '',
                      onSelected: (String selection) {
                        rStatus = selection;
                      },
                      onCleared: () {
                        rStatus = '';
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeseriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Time Dependent Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffd9dcd6),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffd9dcd6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomAutocomplete(
                      suggestions: timeseries,
                      labelText: 'Timeserie',
                      hintText: '',
                      onSelected: (String selection) {
                        timeserie = selection;
                      },
                      onCleared: () {
                        timeserie = '';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              textField("Reference Year", refYear),
            ],
          ),
        ),
      ],
    );
  }
}
