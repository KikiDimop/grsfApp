import 'package:flutter/material.dart';

class SearchFishery extends StatefulWidget {
  const SearchFishery({super.key});

  @override
  State<SearchFishery> createState() => _SearchFisheryState();
}

class _SearchFisheryState extends State<SearchFishery> {
  final _formKey = GlobalKey<FormState>();

  final _speciesCodeController = TextEditingController();
  final _speciesNameController = TextEditingController();

  String? _selectedSpeciesSystem;

  final List<String> _speciesSystemOptions = [
    'System 1',
    'System 2',
    'System 3',
    'System 4',
  ];

  void _clearField(TextEditingController controller) {
    controller.clear();
  }

  /*void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      // Collect the data and process it
      print('Form Submitted');
      print('Species System: $_selectedSpeciesSystem');
      print('Species Code: ${_speciesCodeController.text}');
      print('Species Name: ${_speciesNameController.text}');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        backgroundColor: const Color(0xff16425B),
        foregroundColor: const Color(0xffd9dcd6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(),
                      ),
                      const SizedBox(width: 3.0),
                      Expanded(
                        child: _buildTextField(
                          'Species Code',
                          _speciesCodeController,
                        ),
                      ),
                    ],
                  ),
                  _buildTextField('Species Name', _speciesNameController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Species System',
          border: OutlineInputBorder(),
        ),
        value: _selectedSpeciesSystem,
        onChanged: (String? newValue) {
          setState(() {
            _selectedSpeciesSystem = newValue;
          });
        },
        items: _speciesSystemOptions.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a system';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _clearField(controller),
          ),
        ],
      ),
    );
  }
}
