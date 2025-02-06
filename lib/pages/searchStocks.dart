import 'package:database/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

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
  String? selectedSpeciesSystem;
  String? selectedAreaSystem;
  String? selectedFAOMajorArea;
  String? selectedResourceType;
  String? selectedResourceStatus;

  List<String> speciesTypes = [];
  List<String> areaTypes = [];
  List<String> faoMajorAreas = [];
  List<String> resourceType = [];
  List<String> resourceStatus = [];

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
        await dbService.getDistinct('parent_areas', 'Stock');
    final List<String> fetchedResourceType =
        await dbService.getDistinct('type', 'Stock');
    final List<String> fetchedResourceStatus =
        await dbService.getDistinct('status', 'Stock');

    setState(() {
      speciesTypes = fetchedSpeciesTypes;
      speciesTypes.add('All');
      if (speciesTypes.isNotEmpty) {
        selectedSpeciesSystem = speciesTypes.last;
      }

      areaTypes = fetchedAreaTypes;
      areaTypes.add('All');
      if (areaTypes.isNotEmpty) {
        selectedAreaSystem = areaTypes.last;
      }

      faoMajorAreas = fetchedFAOMajorAreas;
      faoMajorAreas.add('All');
      if (faoMajorAreas.isNotEmpty) {
        selectedFAOMajorArea = faoMajorAreas.last;
      }

      resourceType = fetchedResourceType;
      resourceType.add('All');
      if (resourceType.isNotEmpty) {
        selectedResourceType = resourceType.last;
      }

      resourceStatus = fetchedResourceStatus;
      resourceStatus.add('All');
      if (resourceStatus.isNotEmpty) {
        selectedResourceStatus = resourceStatus.last;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        title: const Text('Search Stock'),
        backgroundColor: const Color(0xff16425B),
        foregroundColor: const Color(0xffd9dcd6),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _speciesSection(),
            const SizedBox(height: 10),
            _areaSection(),
            const SizedBox(height: 10),
            _resourceSection(),
            const SizedBox(height: 10),
            _searchButton(context),

          ],
        ),
      ),
    );
  }

  ElevatedButton _searchButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {

        // Execute the search query
        final dbService = DatabaseService.instance;
        List<Map<String, dynamic>> searchResults = await dbService.searchStock(
          selectedSpeciesSystem: selectedSpeciesSystem,
          speciesCode: speciesCodeController.text,
          speciesName: speciesNameController.text,
          selectedAreaSystem: selectedAreaSystem,
          areaCode: areaCodeController.text,
          areaName: areaNameController.text,
          selectedFAOMajorArea: selectedFAOMajorArea,
          selectedResourceType: selectedResourceType,
          selectedResourceStatus: selectedResourceStatus,
        );

        print(searchResults.length.toString());

      },
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xff16425B),
        backgroundColor: const Color(0xffd9dcd6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      ),
      child: const Text("Search"),
    );
  }

  Widget _speciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Species',
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
                    child: _dropdownField(
                        'Species System', speciesTypes, selectedSpeciesSystem,
                        (value) {
                      setState(() {
                        selectedSpeciesSystem = value;
                      });
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _textField("Species Code", speciesCodeController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _textField("Species Name", speciesNameController),
            ],
          ),
        ),
      ],
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
                    child: _dropdownField(
                        'Area System', areaTypes, selectedAreaSystem, (value) {
                      setState(() {
                        selectedAreaSystem = value;
                      });
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _textField("Area Code", areaCodeController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _textField("Area Name", areaNameController),
              const SizedBox(height: 8),
              _dropdownField('FAO Major Area', faoMajorAreas, selectedFAOMajorArea,
                  (value) {
                setState(() {
                  selectedFAOMajorArea = value;
                });
              }),
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
                    child: _dropdownField(
                        'Resource Type', resourceType, selectedResourceType,
                        (value) {
                      setState(() {
                        selectedResourceType = value;
                      });
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _dropdownField(
                        'Resource Status', resourceStatus, selectedResourceStatus,
                        (value) {
                      setState(() {
                        selectedResourceStatus = value;
                      });
                    })
                  ),
                ],
              ),
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

  Widget _textField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xff16425B)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffd9dcd6).withOpacity(0.1),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            suffixIcon: GestureDetector(
              onTap: () {
                controller.clear();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(
                  Icons.cancel,
                  color: Color(0xff16425B),
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xff16425B)),
            ),
          ),
        ),
      ],
    );
  }
}
