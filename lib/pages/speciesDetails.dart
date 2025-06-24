import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/pages/fisheries.dart';
import 'package:grsfApp/pages/stocks.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/models/species.dart';

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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home_filled),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildExpandableCard(
                title: "Codes",
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow('ASFIS ID', species.asfisId),
                    _buildRow('Aphia ID', species.aphiaId),
                    _buildRow('FishBase ID', species.fishbaseId),
                    _buildRow('TSN ID', species.tsnId),
                    _buildRow('GBIF ID', species.gbifId),
                    _buildRow('Taxonomic ID', species.taxonomicId),
                    _buildRow('IUCN ID', species.iucnId),
                    _buildRow(
                        'IUCN Characterization', species.iucnCharacterization),
                  ],
                ),
                isExpanded: true),
            const SizedBox(height: 16),
            if (species.commonNames != null &&
                species.commonNames!.trim().isNotEmpty)
              _buildExpandableCard(
                  title: "Common Names",
                  content: _buildCommonNamesList(species.commonNames!),
                  isExpanded: false),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    SearchStockForSpecies searchStock =
                        SearchStockForSpecies(species.scientificName);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Stocks(
                          search: searchStock,
                          forSpecies: true,
                          timeseries: '',
                          refYear: '',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffd9dcd6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Related Stocks',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff16425B),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    SearchFishery searchFishery = SearchFishery(
                        'All',
                        '',
                        species.scientificName,
                        'All',
                        '',
                        '',
                        'All',
                        '',
                        '',
                        'All',
                        'All',
                        'All',
                        '');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Fisheries(
                          search: searchFishery,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffd9dcd6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Related Fisheries',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff16425B),
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard(
      {required String title,
      required Widget content,
      required bool isExpanded}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xffd9dcd6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Theme(
            data: ThemeData().copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: isExpanded,
              backgroundColor: const Color(0xffd9dcd6),
              collapsedBackgroundColor: const Color(0xffd9dcd6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              iconColor: const Color(0xff16425B),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff16425B),
                ),
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: content,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommonNamesList(String commonNames) {
    List<String> namesList =
        commonNames.split(';').map((e) => e.trim()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        namesList.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            "${index + 1}. ${namesList[index]}",
            style: const TextStyle(fontSize: 16, color: Color(0xff16425B)),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String left, String? right, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xff16425B),
            ),
          ),
          Text(
            right ?? "N/A",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xff16425B),
            ),
          ),
        ],
      ),
    );
  }
}
