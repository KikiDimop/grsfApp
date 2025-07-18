import 'package:grsfApp/models/species.dart';
import 'package:grsfApp/pages/species_details.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DisplaySpecies extends StatefulWidget {
  const DisplaySpecies({super.key});

  @override
  State<DisplaySpecies> createState() => _DisplaySpeciesState();
}

class _DisplaySpeciesState extends State<DisplaySpecies> {
  List<Species>? species;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final String _selectedOrder = 'Name';
  String _sortOrder = 'asc';
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        DatabaseService.instance
            .readAll(tableName: 'Species', fromMap: Species.fromMap)
      ]);

      setState(() {
        species = results[0];
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
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
      body: Column(
        children: [
          _searchField(),
          const SizedBox(height: 5),
          Expanded(
            child: _results(),
          ),
        ],
      ),
    );
  }

  Widget _results() {
    if (species == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }
    // Filter by search query
    final filteredSpecies = species!.where((sp) {
      final query = _searchQuery.toLowerCase();

      return _searchQuery.isEmpty ||
          sp.scientificName.toLowerCase().contains(query) ||
          (sp.commonNames?.toLowerCase().contains(query) ?? false) ||
          (sp.aphiaId?.toLowerCase().contains(query) ?? false) ||
          (sp.asfisId?.toLowerCase().contains(query) ?? false) ||
          (sp.gbifId?.toLowerCase().contains(query) ?? false) ||
          (sp.iucnId?.toLowerCase().contains(query) ?? false) ||
          (sp.taxonomicId?.toLowerCase().contains(query) ?? false) ||
          (sp.tsnId?.toLowerCase().contains(query) ?? false) ||
          (sp.fishbaseId?.toLowerCase().contains(query) ?? false);
    }).toList();

    // Apply sorting logic based on selected order and sort order (asc/desc)
    filteredSpecies.sort((a, b) {
      int comparison = 0;
      if (_selectedOrder == 'Name') {
        comparison = a.scientificName.compareTo(b.scientificName);
      }

      // If descending, invert the comparison result
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffd9dcd6)..withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: filteredSpecies.isEmpty
          ? const Center(
              child: Text(
                'No species found',
                style: TextStyle(color: Color(0xffd9dcd6)),
              ),
            )
          : ListView.builder(
              itemCount: filteredSpecies.length,
              itemBuilder: (context, index) {
                final sp = filteredSpecies[index];
                return _listViewItem(
                  s: sp,
                );
              },
            ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Search Field (Expanded to take remaining space)
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Color(0xffd9dcd6)), // Text color
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xffd9dcd6).withAlpha(25),
                contentPadding: const EdgeInsets.all(15),
                hintText: 'Search Species',
                hintStyle: const TextStyle(
                  color: Color(0xffd9dcd6),
                  fontSize: 14,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.search,
                    color: Color(0xffd9dcd6),
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.cancel,
                      color: Color(0xffd9dcd6),
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Sorting Button (Now placed next to Search)
          IconButton(
            icon: Icon(
              _sortOrder == 'asc'
                  ? Icons.arrow_circle_up
                  : Icons.arrow_circle_down,
              color: const Color(0xffd9dcd6),
              size: 40,
            ),
            onPressed: () {
              setState(() {
                _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _listViewItem({required Species s}) {
    return GestureDetector(
      onTap: () {
        // Define what happens when the item is clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpeciesDetailsScreen(species: s),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffd9dcd6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scientific Name',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff16425B),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    s.scientificName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff16425B),
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 1),
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: () => _openSourceLink(
                    'https://images.google.com/search?tbm=isch&q=${s.scientificName}'),
                child: const Icon(
                  Icons.image,
                  color: Color(0xff16425B),
                  size: 30,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}


Future<void> _openSourceLink(String link) async {
  final Uri url = Uri.parse(link);

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}