import 'package:database/services/database_service.dart';
import 'package:flutter/material.dart';

class Searchstocks extends StatefulWidget {
  const Searchstocks({super.key});

  @override
  State<Searchstocks> createState() => _SearchstocksState();
}

class _SearchstocksState extends State<Searchstocks> {
  TextEditingController speciesCodeController = TextEditingController();
  TextEditingController speciesNameController = TextEditingController();
  String? selectedSpeciesSystem;
  List<String> speciesTypes = [];

  @override
  void initState() {
    super.initState();
    _loadSpeciesTypes();
  }

  Future<void> _loadSpeciesTypes() async {
    final dbService = DatabaseService.instance;
    final List<String> fetchedSpeciesTypes = await dbService.getDistinctSpeciesTypes();

    setState(() {
      speciesTypes = fetchedSpeciesTypes;
      if (speciesTypes.isNotEmpty) {
        selectedSpeciesSystem = speciesTypes.first; // Default selection
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String speciesCode = speciesCodeController.text;
                String speciesName = speciesNameController.text;
                String speciesSystem = selectedSpeciesSystem ?? 'None';

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Search Results"),
                      content: Text(
                        "Species System: $speciesSystem\n"
                        "Species Code: $speciesCode\n"
                        "Species Name: $speciesName",
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xff16425B),
                backgroundColor: const Color(0xffd9dcd6),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
              child: const Text("Search"),
            ),
          ],
        ),
      ),
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
        const SizedBox(height: 16),
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
                    child: _inputField("Species System", isDropdown: true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _inputField("Species Code", controller: speciesCodeController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _inputField("Species Name", controller: speciesNameController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, {bool isDropdown = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xff16425B),
          ),
        ),
        const SizedBox(height: 4),
        isDropdown
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xffd9dcd6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xff16425B)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSpeciesSystem,
                    style: const TextStyle(
                      color: Color(0xff16425B), // Text color in the button
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    items: speciesTypes.map((species) {
                      return DropdownMenuItem<String>(
                        value: species,
                        child: Text(species),
                      );
                    }).toList(),
                    dropdownColor:
                        const Color(0xffd9dcd6),
                    onChanged: (value) {
                      setState(() {
                        selectedSpeciesSystem = value;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Color(0xffd9dcd6)), // Text color
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xffd9dcd6).withOpacity(0.1),
                    // contentPadding: const EdgeInsets.all(15),
                    // hintStyle: const TextStyle(
                    //   color: Color(0xffd9dcd6),
                    //   fontSize: 14,
                    // ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        controller?.clear();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.cancel,
                          color: Color(0xff16425B),
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff16425B)),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
