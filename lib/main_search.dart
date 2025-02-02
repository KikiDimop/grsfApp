import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Fishing Gear',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchFishingGearPage(),
    );
  }
}

class SearchFishingGearPage extends StatefulWidget {
  const SearchFishingGearPage({super.key});

  @override
  _SearchFishingGearPageState createState() => _SearchFishingGearPageState();
}

class _SearchFishingGearPageState extends State<SearchFishingGearPage> {
  final _formKey = GlobalKey<FormState>();

  final _isscfgCodeController = TextEditingController();
  final _abbreviationController = TextEditingController();
  final _nameController = TextEditingController();
  final _groupCodeController = TextEditingController();
  final _groupNameController = TextEditingController();

  void _clearField(TextEditingController controller) {
    controller.clear();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      // Collect the data and process it
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Fishing Gear'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back navigation
          },
        ),
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
                  _buildTextField(
                      'ISSCFG Code', _isscfgCodeController),
                  _buildTextField(
                      'Abbreviation', _abbreviationController),
                  _buildTextField('Name', _nameController),
                  _buildTextField('Group Code', _groupCodeController),
                  _buildTextField('Group Name', _groupNameController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
          ),
        ),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
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
