import 'package:grsfApp/models/area.dart';
import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/models/areasForStock.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/fishery.dart';
import 'package:grsfApp/models/fisheryOwner.dart';
import 'package:grsfApp/models/fishingGear.dart';
import 'package:grsfApp/models/species.dart';
import 'package:grsfApp/models/speciesForStock.dart';
import 'package:grsfApp/models/stock.dart';
import 'package:grsfApp/models/stockOwner.dart';
import 'package:grsfApp/services/csv_service.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:flutter/material.dart';

class UpdateDataScreen extends StatefulWidget {
  const UpdateDataScreen({super.key});

  @override
  State<UpdateDataScreen> createState() => _UpdateDataScreenState();
}

class _UpdateDataScreenState extends State<UpdateDataScreen> {
  bool _isLoading = false;
  final stopwatch = Stopwatch()..start();
  String _statusMessage = "Press the button to update all data.";

  // A helper function to update a single table
  Future<void> _updateTable<T>({
    required String urlCsv,
    required String tableName,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      // Download and process CSV data
      await CsvService.downloadCsvData(urlCsv);
      List<Map<String, dynamic>> csvData = await CsvService.loadCsvData(
        'data/user/0/com.example.grsfApp/app_flutter/data.csv',
      );

      if (csvData.isNotEmpty) {
        // Update the grsfApp table
        await DatabaseService.instance.deleteAllRows(tableName);
        await DatabaseService.instance.batchInsertData(
          csvData.cast<Map<String, dynamic>>(),
          tableName,
        );
      }
    } catch (e) {
      throw Exception('Error updating $tableName: $e');
    }
  }

  Future<void> _updateAllTables() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Updating data...";
    });

    try {
      // Update all tables sequentially (or parallelize if needed)
      await _updateTable(
        urlCsv: Area.urlCsv,
        tableName: Area.tableName,
        fromMap: Area.fromMap,
      );
      await _updateTable(
        urlCsv: Species.urlCsv,
        tableName: Species.tableName,
        fromMap: Species.fromMap,
      );
      await _updateTable(
        urlCsv: Fishery.urlCsv,
        tableName: Fishery.tableName,
        fromMap: Fishery.fromMap,
      );
      await _updateTable(
        urlCsv: AreasForFishery.urlCsv,
        tableName: 'AreasForFishery',
        fromMap: AreasForFishery.fromMap,
      );
      await _updateTable(
        urlCsv: FisheryOwner.urlCsv,
        tableName: 'FisheryOwner',
        fromMap: FisheryOwner.fromMap,
      );
      await _updateTable(
        urlCsv: Stock.urlCsv,
        tableName: Stock.tableName,
        fromMap: Stock.fromMap,
      );
      await _updateTable(
        urlCsv: SpeciesForStock.urlCsv,
        tableName: 'SpeciesForStock',
        fromMap: SpeciesForStock.fromMap,
      );
      await _updateTable(
        urlCsv: AreasForStock.urlCsv,
        tableName: 'AreasForStock',
        fromMap: AreasForStock.fromMap,
      );
      await _updateTable(
        urlCsv: StockOwner.urlCsv,
        tableName: 'StockOwner',
        fromMap: StockOwner.fromMap,
      );
      await _updateTable(
        urlCsv: Gear.urlCsv,
        tableName: 'Gear',
        fromMap: Gear.fromMap,
      );
      await _updateTable(
        urlCsv: FaoMajorArea.urlCsv,
        tableName: 'FaoMajorArea',
        fromMap: FaoMajorArea.fromMap,
      );

      setState(() {
        _statusMessage = "All data updated successfully!";
      });
    } catch (e) {
      setState(() {
        _statusMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        stopwatch.stop();
        final neededTime = stopwatch.elapsed;
        print('Needed Time : ${neededTime.inSeconds} seconds');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update All Tables'),
        backgroundColor: const Color(0xff16425B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: (){
            Navigator.popUntil(context, (route) => route.isFirst);
          }, icon: const Icon(Icons.home_filled),),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _updateAllTables,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff16425B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text("Update All Data"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
