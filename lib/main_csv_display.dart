import 'package:database/services/csv_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Data Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CsvDataPage(),
    );
  }
}

class CsvDataPage extends StatefulWidget {
  const CsvDataPage({super.key});

  @override
  _CsvDataPageState createState() => _CsvDataPageState();
}

class _CsvDataPageState extends State<CsvDataPage> {
  List<List<dynamic>> _csvData = [];
  

  @override
  void initState() {
    super.initState();
    _loadCsv(); // Load CSV data on initialization
  }

  Future<void> _loadCsv() async {
    // Call the loadCsvData method from the service
    List<List<dynamic>> data = await CsvService.loadCsvData1('assets/fisheries.csv');
    setState(() {
      _csvData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Data Viewer'),
      ),
      body: _csvData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _csvData.length,
              itemBuilder: (context, index) {
                // Display each row
                final row = _csvData[index];
                return ListTile(
                  title: Text(row[1].toString()), // Display 'grsf_name'
                  subtitle: Text('UUID: ${row[0]}'), // Display 'uuid'
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCsv, // Reload CSV data on button press
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
