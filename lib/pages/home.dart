import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/pages/areas.dart';
import 'package:grsfApp/pages/fisheries.dart';
import 'package:grsfApp/pages/fishing_gears.dart';
import 'package:grsfApp/pages/species.dart';
import 'package:grsfApp/pages/stocks.dart';
import 'package:grsfApp/pages/sync.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _databaseInfo = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    setState(() => _isLoading = true);

    try {
      // This will trigger database creation/recreation logic
      await DatabaseService.instance.database;
      await _loadDatabaseInfo();
    } catch (e) {
      debugPrint('Error initializing database: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDatabaseInfo() async {
    final info = await DatabaseService.instance.getDatabaseInfo();
    setState(() => _databaseInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 25.0, left: 25.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: const Color(0xffd9dcd6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        height: 70,
                        width: 362,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/grsf.jpg',
                              height: 50.0,
                              width: 50.0,
                            ),
                            const SizedBox(width: 12.0),
                            const Text(
                              'Welcome to\nGRSF Mobile App',
                              style: TextStyle(
                                color: Color(0xffd9dcd6),
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xffd9dcd6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            buildImageButton(context, 'assets/icons/area.png',
                                'Areas', const Areas()),
                            buildImageButton(
                                context,
                                'assets/icons/species.png',
                                'Species',
                                const DisplaySpecies()),
                            buildImageButton(
                                context,
                                'assets/icons/fisheries.png',
                                'Fisheries',
                                Fisheries(search: SearchFishery())),
                            buildImageButton(
                                context,
                                'assets/icons/stocks.png',
                                'Stocks',
                                Stocks(
                                    search: SearchStock(),
                                    forSpecies: false,
                                    timeseries: '',
                                    refYear: '')),
                            buildImageButton(context, 'assets/icons/gear.png',
                                'Fishing Gear', const FishingGears()),
                            buildImageButton(context, 'assets/icons/sync.png',
                                'Sync Data', const UpdateDataScreen()),
                          ],
                        ),
                      ),
                      Text(
                        _databaseInfo,
                        style: const TextStyle(color: Color(0xffd9dcd6),fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildImageButton(BuildContext context, String imagePath, String title,
      Widget destinationPage) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 70.0, right: 70.0, top: 20.0, bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffd9dcd6),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 12.0),
              Image.asset(
                imagePath,
                height: 30.0,
                width: 30.0,
              ),
              const SizedBox(width: 12.0),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff16425B),
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIconButton(BuildContext context, IconData icon, String title,
      Widget destinationPage) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 70.0, right: 70.0, top: 20.0, bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffd9dcd6),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 12.0),
              Icon(
                icon,
                size: 30.0,
                color: const Color(0xff16425B),
              ),
              const SizedBox(width: 12.0),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff16425B),
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}