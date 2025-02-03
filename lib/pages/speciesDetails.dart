import 'package:database/models/species.dart';
import 'package:flutter/material.dart';

class SpeciesDetailsScreen extends StatelessWidget {
  final Species species;

  const SpeciesDetailsScreen({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        title: Text(species.scientificName),
        backgroundColor: const Color(0xff16425B),
        foregroundColor: const Color(0xffd9dcd6),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(

        ),
      ),
    );
  }
}
