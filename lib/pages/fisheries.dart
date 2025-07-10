import 'package:grsfApp/models/fishery.dart';
import 'package:grsfApp/global.dart';
import 'package:grsfApp/pages/search_fisheries.dart';
import 'package:grsfApp/pages/single_fishery.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:grsfApp/widgets/global_ui.dart';

class Fisheries extends StatefulWidget {
  final dynamic search;
  final String timeseries, refYear;

  const Fisheries(
      {super.key,
      required this.search,
      required this.timeseries,
      required this.refYear});

  @override
  State<Fisheries> createState() => _FisheriesState();
}

class _FisheriesState extends State<Fisheries> {
  List<Fishery>? fisheries;
  String _selectedOrder = 'Short Name';
  String _sortOrder = 'asc';
  bool isLoading = true;
  bool isLoading2 = false;
  String? error;
  Map<String, dynamic>? _responseData;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
    if (widget.timeseries.isNotEmpty) {
      isLoading2 = true;
      _fetchDataFromAPI().then((_) => _mergeAndFilterData());
    }
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        DatabaseService.instance
            .searchFishery(fields: widget.search, fromMap: Fishery.fromMap)
      ]);

      setState(() {
        fisheries = results[0];
        isLoading = false;
        if (fisheries?.isEmpty ?? true && widget.timeseries == '')
          _showNoResultsDialog();
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchDataFromAPI() async {
    String link =
        'https://isl.ics.forth.gr/grsf/grsf-api/resources/getfisherieswithtimeseries?timeseries=${widget.timeseries.replaceAll(' ', '%20')}';
    if (widget.refYear.isNotEmpty) link += '&reference_year=${widget.refYear}';
    final data = await getApiData(link);

    setState(() {
      _responseData = data;
      isLoading2 = false;
    });
  }

  Future<void> _showNoResultsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Results'),
          content: const Text(
              'No fisheries were found matching your search criteria.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _mergeAndFilterData() async {
    try {
      fisheries = mergedata(
              datalist: fisheries,
              getUuid: (fishery) => fishery.uuid,
              responsedata: _responseData)
          .cast<Fishery>();
      ;
      setState(() {
        isLoading2 = false;
        if (fisheries!.isEmpty) _showNoResultsDialog();
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading2 = false;
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
      body: (isLoading || isLoading2)
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text('Error: $error',
                      style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    _searchField(),
                    const SizedBox(
                      height: 5,
                    ),
                    _orderByDropdown(),
                    const SizedBox(height: 5),
                    Expanded(child: _results()),
                  ],
                ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
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
                fillColor: const Color(0xffd9dcd6).withOpacity(0.1),
                contentPadding: const EdgeInsets.all(15),
                hintText: 'Search Fisheries',
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
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: Color(0xffd9dcd6),
              size: 40,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Searchfisheries()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _results() {
    if (fisheries == null) {
      return const Center(
        child: Text(
          'Wait for the data to be loaded',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    final filteredFisheries = fisheries!.where((f) {
      final query = _searchQuery.toLowerCase();
      // Search all fields of the Fishery record
      return _searchQuery.isEmpty ||
          (f.uuid?.toLowerCase().contains(query) ?? false) ||
          (f.grsfName?.toLowerCase().contains(query) ?? false) ||
          (f.grsfSemanticID?.toLowerCase().contains(query) ?? false) ||
          (f.shortName?.toLowerCase().contains(query) ?? false) ||
          (f.type?.toLowerCase().contains(query) ?? false) ||
          (f.status?.toLowerCase().contains(query) ?? false) ||
          (f.traceabilityFlag?.toLowerCase().contains(query) ?? false) ||
          (f.speciesCode?.toLowerCase().contains(query) ?? false) ||
          (f.speciesName?.toLowerCase().contains(query) ?? false) ||
          (f.speciesType?.toLowerCase().contains(query) ?? false) ||
          (f.gearCode?.toLowerCase().contains(query) ?? false) ||
          (f.gearType?.toLowerCase().contains(query) ?? false) ||
          (f.flagCode?.toLowerCase().contains(query) ?? false) ||
          (f.managementEntities?.toLowerCase().contains(query) ?? false) ||
          (f.parentAreas?.toLowerCase().contains(query) ?? false) ||
          (f.firmsCode?.toLowerCase().contains(query) ?? false) ||
          (f.fishsourceCode?.toLowerCase().contains(query) ?? false) ||
          (f.questionnaireCode?.toLowerCase().contains(query) ?? false);
    }).toList();

    filteredFisheries.sort((a, b) {
      int comparison = 0;
      if (_selectedOrder == 'Short Name') {
        comparison = a.shortName?.compareTo(b.shortName ?? '') ?? 0;
      } else if (_selectedOrder == 'Semantic ID') {
        comparison = a.grsfSemanticID?.compareTo(b.grsfSemanticID ?? '') ?? 0;
      }
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffd9dcd6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: filteredFisheries.isEmpty
          ? const Center(
              child: Text(
                'No fisheries found',
                style: TextStyle(
                    color: Color(0xff16425B)), 
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredFisheries.length,
              itemBuilder: (context, index) =>
                  _listViewItem(item: filteredFisheries[index]),
            ),
    );
  }

  Widget _listViewItem({required Fishery item}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplaySingleFishery(fishery: item),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: getColor(item.status), // Border color
              width: 2.0, // Border width
            ),
          ),
          child: addItem(item),
        ),
      ),
    );
  }

  Column addItem(Fishery item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            item.status ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: getColor(item.status),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dataDisplay(
                label: 'Short Name', value: item.shortName ?? 'No Short Name'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dataDisplay(
                label: 'Semantic ID',
                value: item.grsfSemanticID ?? 'No Semantic ID'),
          ],
        ),
      ],
    );
  }

  Widget _orderByDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xffd9dcd6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  value: _selectedOrder,
                  onChanged: (value) =>
                      setState(() => _selectedOrder = value ?? 'Short Name'),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    offset: const Offset(0, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xff16425B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down,
                        color: Color(0xffd9dcd6), size: 30),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Short Name',
                        child: Text('Order by Short Name',
                            style: TextStyle(color: Color(0xffd9dcd6)))),
                    DropdownMenuItem(
                        value: 'Semantic ID',
                        child: Text('Order by Semantic ID',
                            style: TextStyle(color: Color(0xffd9dcd6)))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(
              _sortOrder == 'asc'
                  ? Icons.arrow_circle_up
                  : Icons.arrow_circle_down,
              color: const Color(0xffd9dcd6),
              size: 40,
            ),
            onPressed: () => setState(
                () => _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc'),
          ),
        ],
      ),
    );
  }
}
