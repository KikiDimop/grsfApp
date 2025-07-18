import 'package:grsfApp/global.dart';
import 'package:grsfApp/models/stock.dart';
import 'package:grsfApp/pages/search_stocks.dart';
import 'package:grsfApp/pages/single_stock.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class Stocks extends StatefulWidget {
  final dynamic search;
  final bool forSpecies;
  final String timeseries, refYear;

  const Stocks(
      {super.key,
      required this.search,
      required this.forSpecies,
      required this.timeseries,
      required this.refYear});

  @override
  State<Stocks> createState() => _StocksState();
}

class _StocksState extends State<Stocks> {
  List<Stock>? stocks;
  String _selectedOrder = 'Short Name';
  String _sortOrder = 'asc';
  bool isLoading = true;
  bool isLoading2 = false;
  String? error;
  Map<String, dynamic>? _responseData;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
        DatabaseService.instance.searchStock(
          fields: widget.search,
          fromMap: Stock.fromMap,
          forSpecies: widget.forSpecies,
        )
      ]);

      setState(() {
        stocks = results[0];
        isLoading = false;
        if (stocks?.isEmpty ?? true && widget.timeseries == '') {
          _showNoResultsDialog();
        }
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
        'https://isl.ics.forth.gr/grsf/grsf-api/resources/getstockswithtimeseries?timeseries=${widget.timeseries.replaceAll(' ', '%20')}';
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
          content:
              const Text('No stocks were found matching your search criteria.'),
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
      stocks = mergedata(
              datalist: stocks,
              getUuid: (stock) => stock.uuid,
              responsedata: _responseData)
          .cast<Stock>();
      ;
      setState(() {
        isLoading2 = false;
        if (stocks!.isEmpty) _showNoResultsDialog();
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
                hintText: 'Search Stocks',
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
                MaterialPageRoute(builder: (context) => const Searchstocks()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _results() {
    if (stocks == null) {
      return const Center(
        child: Text(
          'Wait for the data to be loaded',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }

    final filteredStocks = stocks!.where((s) {
      final query = _searchQuery.toLowerCase();
      // Search all fields of the Stock record
      return _searchQuery.isEmpty ||
          (s.uuid?.toLowerCase().contains(query) ?? false) ||
          (s.grsfName?.toLowerCase().contains(query) ?? false) ||
          (s.grsfSemanticID?.toLowerCase().contains(query) ?? false) ||
          (s.shortName?.toLowerCase().contains(query) ?? false) ||
          (s.type?.toLowerCase().contains(query) ?? false) ||
          (s.status?.toLowerCase().contains(query) ?? false) ||
          (s.parentAreas?.toLowerCase().contains(query) ?? false) ||
          (s.sdgFlag?.toLowerCase().contains(query) ?? false) ||
          (s.jurisdictionalDistribution?.toLowerCase().contains(query) ??
              false) ||
          (s.firmsCode?.toLowerCase().contains(query) ?? false) ||
          (s.ramCode?.toLowerCase().contains(query) ?? false) ||
          (s.fishsourceCode?.toLowerCase().contains(query) ?? false) ||
          (s.questionnaireCode?.toLowerCase().contains(query) ?? false);
    }).toList();

    filteredStocks.sort((a, b) {
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
        child: filteredStocks.isEmpty
            ? const Center(
                child: Text(
                  'No stocks found',
                  style: TextStyle(color: Color(0xff16425B)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: filteredStocks.length,
                itemBuilder: (context, index) =>
                    _listViewItem(item: filteredStocks[index]),
              ));
  }

  Widget _listViewItem({required Stock item}) {
    return GestureDetector(
      onTap: () {
        // Define what happens when the item is clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplaySingleStock(stock: item),
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

  Column addItem(Stock item) {
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
            const Text(
              'Short Name',
              style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
            ),
            Text(
              item.shortName ?? 'No Short Name',
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff16425B),
                  fontWeight: FontWeight.bold),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semantic ID',
              style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
            ),
            Text(
              item.grsfSemanticID ?? 'No Semantic ID',
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff16425B),
                  fontWeight: FontWeight.bold),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
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
                color: const Color(0xffd9dcd6).withAlpha(25),
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
