import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/pages/stocks.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/dropdown.dart';
import 'package:grsfApp/widgets/global_ui.dart';

class Searchstocks extends StatefulWidget {
  const Searchstocks({super.key});

  @override
  State<Searchstocks> createState() => _SearchstocksState();
}

class _SearchstocksState extends State<Searchstocks> {
  TextEditingController speciesCodeController = TextEditingController();
  TextEditingController speciesNameController = TextEditingController();
  TextEditingController areaCodeController = TextEditingController();
  TextEditingController areaNameController = TextEditingController();
  TextEditingController refYear = TextEditingController();

  List<String> speciesTypes = [];
  List<String> areaTypes = [];
  List<String> faoMajorAreas = [];
  List<String> resourceType = [];
  List<String> resourceStatus = [];
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
    final List<String> fetchedSpeciesTypes =
        await dbService.getDistinct('species_type', 'SpeciesForStock');
    final List<String> fetchedAreaTypes =
        await dbService.getDistinct('area_type', 'AreasForStock');
    final List<String> fetchedFAOMajorAreas =
        await dbService.getDistinct('fao_major_area_concat', 'FaoMajorArea');
    final List<String> fetchedResourceType =
        await dbService.getDistinct('type', 'Stock');
    final List<String> fetchedResourceStatus =
        await dbService.getDistinct('status', 'Stock');

    setState(() {
      speciesTypes = fetchedSpeciesTypes;
      areaTypes = fetchedAreaTypes;
      faoMajorAreas = fetchedFAOMajorAreas;
      resourceType = fetchedResourceType;
      resourceStatus = fetchedResourceStatus;
    });
  }

  String speciesTypesController = '';
  String areaTypesController = '';
  String faoMajorAreaController = '';
  String resourceTypeController = '';
  String resourceStatusController = '';
  String timeseriesController = '';

  validateDropdown(
      {required List<String> list, required TextEditingController controller}) {
    final input = controller.text.trim();
    String? matchedItem;

    // Find a case-insensitive match
    for (var item in list) {
      if (item.toLowerCase() == input.toLowerCase()) {
        matchedItem = item;
        break;
      }
    }

    if (input.isNotEmpty && matchedItem == null) {
      setState(() {
        controller.clear();
      });
    } else if (input.isNotEmpty && matchedItem != null) {
      setState(() {
        controller.text = matchedItem!;
      });
    }
  }

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
                    child: DropdownWidget(
                      label: 'Species Type',
                      items: speciesTypes,
                      onSelected: (value) {
                        setState(() {
                          speciesTypesController = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: textField("Species Code", speciesCodeController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              textField("Scientific Name", speciesNameController),
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
          selectedSpeciesSystem: speciesTypesController,
          speciesCode: speciesCodeController.text,
          speciesName: speciesNameController.text,
          selectedAreaSystem: areaTypesController,
          areaCode: areaCodeController.text,
          areaName: areaNameController.text,
          selectedFAOMajorArea: faoMajorAreaController,
          selectedResourceType: resourceTypeController,
          selectedResourceStatus: resourceStatusController,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Stocks(
                search: searchStock,
                forSpecies: false,
                timeseries: timeseriesController,
                refYear: refYear.text),
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
                    child: DropdownWidget(
                      label: 'Area Type',
                      items: areaTypes,
                      onSelected: (value) {
                        setState(() {
                          areaTypesController = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: textField("Area Code", areaCodeController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              textField("Area Name", areaNameController),
              const SizedBox(height: 8),
              DropdownWidget(
                label: 'Fao Major Area',
                items: faoMajorAreas,
                onSelected: (value) {
                  setState(() {
                    faoMajorAreaController = value;
                  });
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
                    child: DropdownWidget(
                      label: 'Resource Type',
                      items: resourceType,
                      onSelected: (value) {
                        setState(() {
                          resourceTypeController = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownWidget(
                      label: 'Resource Status',
                      items: resourceStatus,
                      onSelected: (value) {
                        setState(() {
                          resourceStatusController = value;
                        });
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
                    child: DropdownWidget(
                      label: 'Timeserie',
                      items: timeseries,
                      onSelected: (value) {
                        setState(() {
                          timeseriesController = value;
                        });
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
