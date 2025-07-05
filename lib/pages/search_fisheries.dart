import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/pages/fisheries.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/autocomplete.dart';
import 'package:grsfApp/widgets/global_ui.dart';

class Searchfisheries extends StatefulWidget {
  const Searchfisheries({super.key});

  @override
  State<Searchfisheries> createState() => _SearchfisheriesState();
}

class _SearchfisheriesState extends State<Searchfisheries> {
  List<String> speciesTypes = [];
  List<String> speciesCodes = [];
  List<String> speciesNames = [];

  List<String> areaTypes = [];
  List<String> areaCodes = [];
  List<String> areaNames = [];

  List<String> faoMajorAreas = [];

  List<String> gearTypes = [];
  List<String> gearCodes = [];
  List<String> gearNames = [];

  List<String> resourceType = [];
  List<String> resourceStatus = [];

  List<String> flagCodes = [];

  List<String> timeseries = ['Catch', 'Landing'];
  List<String> refYears = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownLists();
  }

  Future<void> _loadDropdownLists() async {
    final dbService = DatabaseService.instance;

    //Get distinct data for search in table Fishery
    final List<String> fetchedSpeciesTypes =
        await dbService.getDistinct('species_type', 'Fishery');
    final List<String> fetchedSpeciesCodes =
        await dbService.getDistinct('species_code', 'Fishery');
    final List<String> fetchedSpeciesNames =
        await dbService.getDistinct('species_name', 'Fishery');
    final List<String> fetchedGearTypes =
        await dbService.getDistinct('gear_type', 'Fishery');
    final List<String> fetchedGearCodes =
        await dbService.getDistinct('gear_code', 'Fishery');
    final List<String> fetchedResourceType =
        await dbService.getDistinct('type', 'Fishery');
    final List<String> fetchedResourceStatus =
        await dbService.getDistinct('status', 'Fishery');
    final List<String> fetchedFlagCodes =
        await dbService.getDistinct('flag_code', 'Fishery');

    //Get distinct data for search in table AreasForFishery
    final List<String> fetchedAreaTypes =
        await dbService.getDistinct('area_type', 'AreasForFishery');
    final List<String> fetchedAreaCodes =
        await dbService.getDistinct('area_code', 'AreasForFishery');
    final List<String> fetchedAreaNames =
        await dbService.getDistinct('area_name', 'AreasForFishery');

    //Get distinct data for search in table Gear
    final List<String> fetchedGearNames =
        await dbService.getDistinct('fishing_gear_name', 'Gear');

    //Get distinct data for search in table FaoMajorArea
    final List<String> fetchedFAOMajorAreas =
        await dbService.getDistinct('fao_major_area_concat', 'FaoMajorArea');

    setState(() {
      speciesTypes = fetchedSpeciesTypes;
      speciesCodes = fetchedSpeciesCodes;
      speciesNames = fetchedSpeciesNames;

      areaTypes = fetchedAreaTypes;
      areaCodes = fetchedAreaCodes;
      areaNames = fetchedAreaNames;
      faoMajorAreas = fetchedFAOMajorAreas;

      gearTypes = fetchedGearTypes;
      gearNames = fetchedGearNames;
      gearCodes = fetchedGearCodes;

      resourceType = fetchedResourceType;
      resourceStatus = fetchedResourceStatus;

      flagCodes = fetchedFlagCodes;
    });
  }

  String spType = '';
  String spCode = '';
  String spName = '';

  String aType = '';
  String aCode = '';
  String aName = '';
  String faoMajArea = '';

  String gType = '';
  String gCode = '';
  String gName = '';

  String flagCode = '';

  String rType = '';
  String rStatus = '';

  String timeserie = '';
  TextEditingController refYear = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        title: const Text('Search Fishery'),
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
            _fishingGearSection(),
            const SizedBox(
              height: 10,
            ),
            _flagSection(),
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
        SearchFishery searchFishery = SearchFishery(
          selectedSpeciesSystem: spType, //speciesSystemController,
          speciesCode: spCode, //speciesCodeController.text,
          speciesName: spName, //speciesNameController.text,
          selectedAreaSystem: aType,
          areaCode: aCode,
          areaName: aName,
          selectedGearSystem: gType,
          gearCode: gCode,
          gearName: gName,
          selectedFAOMajorArea: faoMajArea,
          selectedResourceType: rType,
          selectedResourceStatus: rStatus,
          flagCode: flagCode,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Fisheries(search: searchFishery),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffd9dcd6), // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded edges
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // Button padding
      ),
      child: const Text(
        'Search',
        style: TextStyle(
            fontSize: 14,
            color: Color(0xff16425B),
            fontWeight: FontWeight.bold // Text color
            ),
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

  Widget _fishingGearSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Fishing Gear',
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
                      suggestions: gearTypes,
                      labelText: 'Fishing Gear Type',
                      hintText: '',
                      onSelected: (String selection) {
                        gType = selection;
                      },
                      onCleared: () {
                        gType = '';
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomAutocomplete(
                      suggestions: gearCodes,
                      labelText: 'Fishing Gear Codes',
                      hintText: '',
                      onSelected: (String selection) {
                        gCode = selection;
                      },
                      onCleared: () {
                        gCode = '';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomAutocomplete(
                suggestions: gearNames,
                labelText: 'Fishing Gear Name',
                hintText: '',
                onSelected: (String selection) {
                  gName = selection;
                },
                onCleared: () {
                  gName = '';
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

  Widget _flagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Flag',
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
          child: CustomAutocomplete(
            suggestions: flagCodes,
            labelText: 'Flag Code',
            hintText: '',
            onSelected: (String selection) {
              flagCode = selection;
            },
            onCleared: () {
              flagCode = '';
            },
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
