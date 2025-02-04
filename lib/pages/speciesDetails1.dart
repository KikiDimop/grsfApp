import 'package:database/models/species.dart';
import 'package:flutter/material.dart';

class SpeciesDetailsScreen1 extends StatelessWidget {
  final Species species;

  const SpeciesDetailsScreen1({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        title: Text(species.scientificName),
        backgroundColor: const Color(0xff16425B),
        foregroundColor: const Color(0xffd9dcd6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Scientific Name', species.scientificName),
            _buildDetailRow('ASFIS ID', species.asfisId),
            _buildDetailRow('Aphia ID', species.aphiaId),
            _buildDetailRow('FishBase ID', species.fishbaseId),
            _buildDetailRow('TSN ID', species.tsnId),
            _buildDetailRow('GBIF ID', species.gbifId),
            _buildDetailRow('Taxonomic ID', species.taxonomicId),
            _buildDetailRow('IUCN ID', species.iucnId),
            _buildDetailRow('IUCN Characterization', species.iucnCharacterization),
            _buildDetailRow('Common Names', species.commonNames),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xffd9dcd6),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
