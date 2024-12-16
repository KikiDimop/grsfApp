import 'package:database/models/fishery.dart';
import 'package:database/services/csv_service.dart';
import 'package:database/services/database_service.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FisheryListScreen(),
    );
  }
}

class FisheryListScreen extends StatefulWidget {
  const FisheryListScreen({super.key});

  @override
  _FisheryListScreenState createState() => _FisheryListScreenState();
}

class _FisheryListScreenState extends State<FisheryListScreen> {
  late Future<List<Fishery>> _fisheries;
  bool _isLoading = false; // Add this flag to manage loading state
  String _timeStart = '';
  String _timeEnd = '';
  @override
  void initState() {
    super.initState();
    _fisheries = DatabaseService.instance.readAll(tableName: 'Fishery', fromMap: Fishery.fromMap,);
    print('readAllFisheries');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fisheries'),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Fishery>>(
            future: _fisheries,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No fisheries found.'));
              } else {
                final fisheries = snapshot.data!;
                return ListView.builder(
                  itemCount: fisheries.length,
                  itemBuilder: (context, index) {
                    final fishery = fisheries[index];
                    return ListTile(
                      title: Text(fishery.grsfName ?? 'No Name'),
                      subtitle: Text(fishery.type ?? 'No Type'),
                    );
                  },
                );
              }
            },
          ),
          if (_isLoading) // Show loading indicator if _isLoading is true
            const Center(child: CircularProgressIndicator())
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importCsv,
        child: const Icon(Icons.refresh),
      ),   
    );
  }

  
  void _importCsv() async {
    try {
      setState(() {
        _isLoading = true; // Start loading
        _timeStart = TimeOfDay.now().toString(); 
      });

      List<Map<String, dynamic>> csvData = [];

      await CsvService.downloadCsvData(Fishery.urlCsv);
      List<Map<String, dynamic>> data = await CsvService.loadCsvData('data/user/0/com.example.database/app_flutter/data.csv');
      csvData = data;

      if (csvData.isEmpty) {
        print('Empty CSV');
      } else {
        print('Found ${csvData.length} fisheries');
        await DatabaseService.instance.deleteAllRows('Fishery');
        await DatabaseService.instance.batchInsertData(csvData.cast<Map<String, dynamic>>(),'Fishery');

        // await DatabaseService.instance.deleteAllRows();
        // print('All $count rows deleted');
        // for (var row in csvData) {
        //   final newFishery = Fishery(
        //     uuid: row[0],
        //     grsfName: row[1],
        //     grsfSemanticID: row[2],
        //     shortName: row[3],
        //     type: row[4],
        //     status: row[5],
        //     traceabilityFlag: row[6],
        //     gearType: row[7],
        //     gearCode: row[8],
        //     flagCode: row[9],
        //     managementEntities: row[10],
        //     parentAreas: row[11],
        //     firmsCode: row[12],
        //     fishsourceCode: row[13],
        //   );

        //   await DatabaseService.instance.create(newFishery);
        // }

        setState(() {
          _fisheries = DatabaseService.instance.readAll(tableName: 'Fishery', fromMap: Fishery.fromMap);
          _isLoading = false; // Stop loading
          _timeEnd = TimeOfDay.now().toString(); 
          print('$_timeEnd - $_timeStart');
        });
      }
    } catch (e) {
      throw Exception('Error _importCsv : $e');
    }
    
  }

}
