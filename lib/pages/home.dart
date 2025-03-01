import 'package:grsfApp/pages/areas.dart';
import 'package:grsfApp/pages/fishingGears.dart';
import 'package:grsfApp/pages/searchFisheries.dart';
import 'package:grsfApp/pages/searchStocks.dart';
import 'package:grsfApp/pages/species.dart';
import 'package:grsfApp/pages/sync.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  get n => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      body: Center(
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
                      buildImageButton(context, 'assets/icons/species.png',
                          'Species', const DisplaySpecies()),
                      buildImageButton(context, 'assets/icons/fisheries.png',
                          'Fisheries', const Searchfisheries()),
                      buildImageButton(context, 'assets/icons/stocks.png',
                          'Stocks', const Searchstocks()),
                      buildImageButton(context, 'assets/icons/gear.png',
                          'Fishing Gear', const FishingGears()),
                      buildImageButton(context, 'assets/icons/sync.png',
                          'Sync Data', const UpdateDataScreen()),
                    ],
                  ),
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
}
