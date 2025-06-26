import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/pages/stocks.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/dropdown_text_field.dart';

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

  final TextEditingController speciesTypesController = TextEditingController();
  final TextEditingController areaTypesController = TextEditingController();
  final TextEditingController faoMajorAreaController = TextEditingController();
  final TextEditingController resourceTypeController = TextEditingController();
  final TextEditingController resourceStatusController =
      TextEditingController();
  final TextEditingController timeseriesController = TextEditingController();

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
  void dispose() {
    faoMajorAreaController.dispose();
    resourceTypeController.dispose();
    resourceStatusController.dispose();
    timeseriesController.dispose();
    speciesTypesController.dispose();
    areaTypesController.dispose();
    super.dispose();
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
                    child: DropdownTextField(
                      items: speciesTypes,
                      label: 'Species System',
                      controller: speciesTypesController,
                      onValidate: validateDropdown(
                          list: speciesTypes,
                          controller: speciesTypesController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _textField("Species Code", speciesCodeController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _textField("Scientific Name", speciesNameController),
            ],
          ),
        ),
      ],
    );
  }

  void validateAllDropdowns() {
    validateDropdown(list: speciesTypes, controller: speciesTypesController);
    validateDropdown(list: areaTypes, controller: areaTypesController);
    validateDropdown(list: faoMajorAreas, controller: faoMajorAreaController);
    validateDropdown(list: resourceType, controller: resourceTypeController);
    validateDropdown(
        list: resourceStatus, controller: resourceStatusController);
    validateDropdown(list: timeseries, controller: timeseriesController);
  }

  ElevatedButton searchButton() {
    return ElevatedButton(
      onPressed: () {
        validateAllDropdowns();
        SearchStock searchStock = SearchStock(
          speciesTypesController.text,
          speciesCodeController.text,
          speciesNameController.text,
          areaTypesController.text,
          areaCodeController.text,
          areaNameController.text,
          faoMajorAreaController.text,
          resourceTypeController.text,
          resourceStatusController.text,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Stocks(
                search: searchStock,
                forSpecies: false,
                timeseries: timeseriesController.text,
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
                    child: DropdownTextField(
                      items: areaTypes,
                      label: 'Area System',
                      controller: areaTypesController,
                      onValidate: validateDropdown(
                          list: areaTypes, controller: areaTypesController),
                    ),
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
              DropdownTextField(
                items: faoMajorAreas,
                label: 'FAO Major Area',
                controller: faoMajorAreaController,
                onValidate: validateDropdown(
                    list: faoMajorAreas, controller: faoMajorAreaController),
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
                    child: DropdownTextField(
                      items: resourceType,
                      label: 'Resource Type',
                      controller: resourceTypeController,
                      onValidate: validateDropdown(
                          list: resourceType,
                          controller: resourceTypeController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownTextField(
                      items: resourceStatus,
                      label: 'Resource Status',
                      controller: resourceStatusController,
                      onValidate: validateDropdown(
                          list: resourceStatus,
                          controller: resourceStatusController),
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
                    child: DropdownTextField(
                      items: timeseries,
                      label: 'Timeseries',
                      controller: timeseriesController,
                      onValidate: validateDropdown(
                          list: timeseries, controller: timeseriesController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _textField("Reference Year", refYear),
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
