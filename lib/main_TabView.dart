import 'package:database/models/area.dart';
import 'package:database/models/fishery.dart';
import 'package:database/models/fishingGear.dart';
import 'package:database/models/species.dart';
import 'package:database/models/stock.dart';
import 'package:database/services/csv_service.dart';
import 'package:database/services/database_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TabBarDemo());
}

class TabBarDemo extends StatelessWidget {
  const TabBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff16425B))
      ),
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xffD9DCD6),
            foregroundColor: const Color(0xff16425B),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Image.asset('assets/icons/area.png', width: 24, height: 24, color: const Color(0xff16425B),),
                ),
                Tab(
                  icon: Image.asset(
                    'assets/icons/species.png',
                    width: 24,
                    height: 24,
                    color: const Color(0xff16425B),
                    ),
                ),
                Tab(
                  icon: Image.asset(
                    'assets/icons/fisheries.png',
                    width: 24,
                    height: 24,
                    color: const Color(0xff16425B),
                    ),
                ),
                Tab(
                  icon: Image.asset(
                    'assets/icons/stocks.png',
                    width: 24,
                    height: 24,
                    color: const Color(0xff16425B),
                    ),
                ),
                Tab(
                  icon: Image.asset(
                    'assets/icons/gear.png',
                    width: 24,
                    height: 24,
                    color: const Color(0xff16425B),
                    ),
                ),

              ],
            ),
            title: const Text('GRSF Database DEMO'),
          ),
          body: TabBarView(
            children: [
              DataListScreen<Area>(
                fetchData: () => DatabaseService.instance.readAll(tableName: Area.tableName, fromMap: Area.fromMap),
                title: 'Areas',
                urlCsv: Area.urlCsv,
                tableName: Area.tableName,
                itemBuilder: (area) {
                  return ListTile(
                    title: Text(area.areaCode ?? 'No area code'),
                    subtitle: Text(area.areaName ?? 'No area name'),
                  );
                },
              ),
              DataListScreen<Species>(
                fetchData: () => DatabaseService.instance.readAll(tableName: Species.tableName, fromMap: Species.fromMap),
                title: 'Species',
                urlCsv: Species.urlCsv,
                tableName: Species.tableName,
                itemBuilder: (species) {
                  return ListTile(
                    title: Text(species.speciesCode ?? 'No code'),
                    subtitle: Text(species.speciesName ?? 'No Name'),
                  );
                },
              ),
              DataListScreen<Fishery>(
                fetchData: () => DatabaseService.instance.readAll(tableName: Fishery.tableName, fromMap: Fishery.fromMap),
                title: 'Fisheries',
                urlCsv: Fishery.urlCsv,
                tableName: Fishery.tableName,
                itemBuilder: (fishery) {
                  return ListTile(
                    title: Text(fishery.uuid ?? 'No UUID'),
                    subtitle: Text(fishery.grsfSemanticID ?? 'No Semantic ID'),
                  );
                },
              ),
              DataListScreen<Stock>(
                fetchData: () => DatabaseService.instance.readAll(tableName: Stock.tableName, fromMap: Stock.fromMap),
                title: 'Stocks',
                urlCsv: Stock.urlCsv,
                tableName: Stock.tableName,
                itemBuilder: (stock) {
                  return ListTile(
                    title: Text(stock.uuid ?? 'No UUID'),
                    subtitle: Text(stock.grsfSemanticID ?? 'No Semantic ID'),
                  );
                },
              ),
              DataListScreen<Gear>(
                fetchData: () => DatabaseService.instance.readAll(tableName: 'Gear', fromMap: Gear.fromMap),
                title: 'Fishing Gear',
                urlCsv: Gear.urlCsv,
                tableName: 'Gear',
                itemBuilder: (gear) {
                  return ListTile(
                    title: Text(gear.fishingGearCode ?? 'No code'),
                    subtitle: Text(gear.fishingGearName ?? 'No Name'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class DataListScreen<T> extends StatefulWidget {
  final Future<List<T>> Function() fetchData;
  final String title;
  final String urlCsv;
  final String tableName;
  final Widget Function(T) itemBuilder; // How to build each item's UI

  const DataListScreen({
    required this.fetchData,
    required this.title,
    required this.urlCsv,
    required this.tableName,
    required this.itemBuilder,
    super.key, 
  });

  @override
  _DataListScreenState<T> createState() => _DataListScreenState<T>();
}

class _DataListScreenState<T> extends State<DataListScreen<T>> {
  late Future<List<T>> _data;
  bool _isLoading = false;
  String _timeStart = '';
  String _timeEnd = '';

  @override
  void initState() {
    super.initState();
    _data = widget.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Color(0xff16425B)),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<T>>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data found.'));
              } else {
                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return widget.itemBuilder(item);
                  },
                );
              }
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
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
        _isLoading = true;
        _timeStart = TimeOfDay.now().toString();
      });

      await CsvService.downloadCsvData(widget.urlCsv);
      List<Map<String, dynamic>> csvData = await CsvService.loadCsvData(
        'data/user/0/com.example.database/app_flutter/data.csv',
      );

      if (csvData.isEmpty) {
        print('Empty CSV');
      } else {
        print('Found ${csvData.length} items');
        await DatabaseService.instance.deleteAllRows(widget.tableName);
        await DatabaseService.instance.batchInsertData(
          csvData.cast<Map<String, dynamic>>(),
          widget.tableName,
        );

        setState(() {
          _data = widget.fetchData();
          _isLoading = false;
          _timeEnd = TimeOfDay.now().toString();
          print('$_timeEnd - $_timeStart');
        });
      }
    } catch (e) {
      throw Exception('Error importing CSV: $e');
    }
  }
}
