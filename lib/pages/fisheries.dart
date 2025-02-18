import 'package:database/models/fishery.dart';
import 'package:database/models/global.dart';
import 'package:database/pages/singleFishery.dart';
import 'package:database/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class Fisheries extends StatefulWidget {
  final SearchFishery search;

  const Fisheries({
    super.key,
    required this.search,
  });

  @override
  State<Fisheries> createState() => _FisheriesState();
}

class _FisheriesState extends State<Fisheries> {
  List<Fishery>? fisheries;
  String _selectedOrder = 'Short Name';
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
        DatabaseService.instance.searchFishery(
          fields: widget.search,
          fromMap: Fishery.fromMap,
        )
      ]);

      setState(() {
        fisheries = results[0];
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
          _orderByDropdown(),
          const SizedBox(height: 5),
          Expanded(child: _results()),
        ],
      ),
    );
  }

  Widget _results() {
    if (fisheries == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xffd9dcd6)),
        ),
      );
    }
    fisheries!.sort((a, b) {
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
        child: fisheries!.isEmpty
            ? const Center(
                child: Text(
                  'No fisheries found',
                  style: TextStyle(color: Color(0xffd9dcd6)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: fisheries!.length,
                itemBuilder: (context, index) =>
                    _listViewItem(item: fisheries![index]),
              ));
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
