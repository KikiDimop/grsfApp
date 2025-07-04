import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/pages/fisheries.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/dropdown.dart';
import 'package:grsfApp/widgets/global_ui.dart';

class Searchfisheries extends StatefulWidget {
  const Searchfisheries({super.key});

  @override
  State<Searchfisheries> createState() => _SearchfisheriesState();
}

class _SearchfisheriesState extends State<Searchfisheries> {
  TextEditingController speciesCodeController = TextEditingController();
  TextEditingController speciesNameController = TextEditingController();
  TextEditingController areaCodeController = TextEditingController();
  TextEditingController areaNameController = TextEditingController();
  TextEditingController gearCodeController = TextEditingController();
  TextEditingController gearNameController = TextEditingController();
  TextEditingController refYear = TextEditingController();

  List<String> speciesTypes = [];
  List<String> areaTypes = [];
  List<String> gearTypes = [];
  List<String> faoMajorAreas = [];
  List<String> resourceType = [];
  List<String> resourceStatus = [];
  List<String> flagCodes = [];
  List<String> timeseries = ['Catch', 'Landing'];

  @override
  void initState() {
    super.initState();
    _loadDropdownLists();
  }

  Future<void> _loadDropdownLists() async {
    final dbService = DatabaseService.instance;
    final List<String> fetchedSpeciesTypes =
        await dbService.getDistinct('species_type', 'Fishery');
    final List<String> fetchedAreaTypes =
        await dbService.getDistinct('area_type', 'AreasForFishery');
    final List<String> fetchedGearTypes =
        await dbService.getDistinct('gear_type', 'Fishery');
    final List<String> fetchedFAOMajorAreas =
        await dbService.getDistinct('fao_major_area_concat', 'FaoMajorArea');
    final List<String> fetchedResourceType =
        await dbService.getDistinct('type', 'Fishery');
    final List<String> fetchedResourceStatus =
        await dbService.getDistinct('status', 'Fishery');
    final List<String> fetchedFlagCodes =
        await dbService.getDistinct('flag_code', 'Fishery');

    setState(() {
      speciesTypes = fetchedSpeciesTypes;
      areaTypes = fetchedAreaTypes;
      gearTypes = fetchedGearTypes;
      faoMajorAreas = fetchedFAOMajorAreas;
      resourceType = fetchedResourceType;
      resourceStatus = fetchedResourceStatus;
      flagCodes = fetchedFlagCodes;
    });
  }

  String timeseriesController = '';
  String flagCodeController = '';
  String speciesSystemController = '';
  String areaSystemController = '';
  String faoMajorAreaController = '';
  String gearSystemController = '';
  String resourceTypeController = '';
  String resourceStatusController = '';

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
                    child: DropdownWidget(
                      label: 'Species Type',
                      items: speciesTypes,
                      onSelected: (value) {
                        setState(() {
                          speciesSystemController = value;
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
        SearchFishery searchFishery = SearchFishery(
          selectedSpeciesSystem: speciesSystemController,
          speciesCode: speciesCodeController.text,
          speciesName: speciesNameController.text,
          selectedAreaSystem: areaSystemController,
          areaCode: areaCodeController.text,
          areaName: areaNameController.text,
          selectedGearSystem: gearSystemController,
          gearCode: gearCodeController.text,
          gearName: gearNameController.text,
          selectedFAOMajorArea: faoMajorAreaController,
          selectedResourceType: resourceTypeController,
          selectedResourceStatus: resourceStatusController,
          flagCode: flagCodeController,
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
                      child: DropdownWidget(
                        label: 'Area Type',
                    items: areaTypes,
                    onSelected: (value) {
                      setState(() {
                        areaSystemController = value;
                      });
                    },
                  )),
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
                  })
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
                      child: DropdownWidget(
                        label: 'Fishing Gear Type',
                          items: gearTypes,
                          onSelected: (value) {
                            setState(() {
                              gearSystemController = value;
                            });
                          })),
                  const SizedBox(width: 16),
                  Expanded(
                    child: textField("Fishing Gear Code", gearCodeController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              textField("Fishing Gear Name", gearNameController),
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
                          })),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownWidget(
                      label: 'Resource Status',
                        items: resourceStatus,
                        onSelected: (value) {
                          setState(() {
                            resourceStatusController = value;
                          });
                        }),
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
          child: DropdownWidget(
            label: 'Flag Code',
              items: flagCodes,
              onSelected: (value) {
                setState(() {
                  flagCodeController = value;
                });
              }),
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
                        }),
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

  Widget _dropdownField(String label, List<String> items, String? selectedValue,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != '')
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff16425B),
              ),
            ),
          ),
        SizedBox(
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffd9dcd6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xff16425B)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  value: selectedValue,
                  style: const TextStyle(
                    color: Color(0xff16425B),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      color: const Color(0xffd9dcd6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: onChanged,
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down),
                  ),
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.only(right: 10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
