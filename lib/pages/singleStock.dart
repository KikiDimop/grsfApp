import 'package:database/models/areasForStock.dart';
import 'package:database/models/speciesForStock.dart';
import 'package:database/models/stock.dart';
import 'package:database/models/stockOwner.dart';
import 'package:database/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DisplaySingleStock extends StatefulWidget {
  final Stock stock;
  const DisplaySingleStock({super.key, required this.stock});

  @override
  State<DisplaySingleStock> createState() => _DisplaySingleStockState();
}

class _DisplaySingleStockState extends State<DisplaySingleStock> {
  late Future<List<AreasForStock>> _areaForStock;
  late Future<List<SpeciesForStock>> _speciesForStock;
  late Future<List<StockOwner>> _stockOwner;
  String _selectedOrder = 'Name';
  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();

    String? whereStr = 'uuid = "${widget.stock.uuid}"';
    _areaForStock = DatabaseService.instance.readAll(
        tableName: 'AreasForStock',
        where: whereStr,
        fromMap: AreasForStock.fromMap);
    _speciesForStock = DatabaseService.instance.readAll(
        tableName: 'SpeciesForStock',
        where: whereStr,
        fromMap: SpeciesForStock.fromMap);
    _stockOwner = DatabaseService.instance.readAll(
        tableName: 'StockOwner', where: whereStr, fromMap: StockOwner.fromMap);
  }

  bool _showDetails = true;
  bool _showSpecies = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        //title: Text(widget.stock.shortName ?? 'N/A'),
        leading: IconButton(
          onPressed: () {
            if (!_showDetails) {
              setState(() {
                _showDetails = true;
                _showSpecies = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xff16425B),
        foregroundColor: const Color(0xffd9dcd6),
        actions: [
          IconButton(onPressed: (){
            Navigator.popUntil(context, (route) => route.isFirst);
          }, icon: const Icon(Icons.home_filled),),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5),
            _identitySection(context),
            const SizedBox(height: 5),
            if (_showDetails) _detailsSection(context),
            if (_showSpecies) _speciesSection(context),
          ],
        ),
      ),
    );
  }

  Column _speciesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Stock Species List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffd9dcd6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the white box
          children: [
            dropdown(context),
            const SizedBox(
              height: 15,
            )
          ],
        ),
      ],
    );
  }

  Container dropdown(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // Make it responsive
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffd9dcd6).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xffd9dcd6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        value: _selectedOrder,
                        onChanged: (value) {
                          setState(() {
                            _selectedOrder = value ?? 'Name';
                          });
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          offset: const Offset(
                              0, 8), // Ensures a consistent dropdown position
                          decoration: BoxDecoration(
                            color: Color(0xff16425B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down,
                              color: Color(0xffd9dcd6), size: 30),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Name',
                              child: Text(
                                'Order by Name',
                                style: TextStyle(color: Color(0xffd9dcd6)),
                              )),
                          DropdownMenuItem(
                              value: 'Code',
                              child: Text('Order by Code',
                                  style: TextStyle(color: Color(0xffd9dcd6)))),
                          DropdownMenuItem(
                              value: 'System',
                              child: Text('Order by System',
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
                  onPressed: () {
                    setState(() {
                      _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _identitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Stock Identity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffd9dcd6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the white box
          children: [
            Container(
              width:
                  MediaQuery.of(context).size.width * 0.9, // Make it responsive
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffd9dcd6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statusDisplay(),
                  simpleDisplay('Short Name', widget.stock.shortName ?? ''),
                  simpleDisplay(
                      'Semantic ID', widget.stock.grsfSemanticID ?? ''),
                  simpleDisplay('Semantic Title', widget.stock.grsfName ?? ''),
                  simpleDisplay('UUID', widget.stock.uuid ?? ''),
                  simpleDisplay('Type', widget.stock.type ?? ''),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Stock Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffd9dcd6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the white box
          children: [
            Container(
              width:
                  MediaQuery.of(context).size.width * 0.9, // Make it responsive
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffd9dcd6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  showDetails(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget showDetails() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_areaForStock, _stockOwner, _speciesForStock]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData ||
            snapshot.data![0] == null ||
            snapshot.data![1] == null) {
          return const Text('No data found');
        }

        List<AreasForStock> areas = snapshot.data![0] as List<AreasForStock>;
        List<StockOwner> owners = snapshot.data![1] as List<StockOwner>;
        List<SpeciesForStock> species =
            snapshot.data![2] as List<SpeciesForStock>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (species.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Species',
                      style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
                    ),
                    displayRow('Code     : ', species.first.speciesCode ?? ''),
                    displayRow('System : ', species.first.speciesType ?? ''),
                    displayRow('Name    : ', species.first.speciesName ?? ''),
                  ],
                ),
              ),
            if (areas.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment Area Details',
                      style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
                    ),
                    displayRow('Code     : ', areas.first.areaCode ?? ''),
                    displayRow('System : ', areas.first.areaType ?? ''),
                    displayRow('Name    : ', areas.first.areaName ?? ''),
                  ],
                ),
              ),
            if (owners.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Owner',
                      style: TextStyle(fontSize: 12, color: Color(0xff16425B)),
                    ),
                    Text(
                      owners.first.owner ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff16425B),
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                if (species.length > 1)
                  _button(
                    label: 'Species List',
                    onPressed: () {
                      setState(() {
                        _showDetails = !_showDetails;
                        _showSpecies = !_showSpecies;
                      });

                      //showDataList(context, 'Species List', species);
                    },
                  ),
                const SizedBox(
                  width: 5,
                ),
                if (areas.length > 1)
                  _button(
                    label: 'View Areas',
                    onPressed: () {
                      setState(() {
                        _showDetails = !_showDetails;
                        _showSpecies = !_showSpecies;
                      });
                      //showDataList(context, 'Assessment Areas', areas);
                    },
                  ),
                const SizedBox(
                  width: 5,
                ),
                if (owners.length > 1)
                  _button(
                    label: 'View Owners',
                    onPressed: () {
                      setState(() {
                        _showDetails = !_showDetails;
                        _showSpecies = !_showSpecies;
                      });
                      //showDataList(context, 'Data Owners', owners);
                    },
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showDataList(BuildContext context, String title, List<dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map((item) {
                // Extract the name of each item based on the type of object
                String displayName = '';
                if (item is SpeciesForStock) {
                  displayName = item.speciesName ?? 'No Name';
                } else if (item is AreasForStock) {
                  displayName = item.areaName ?? 'No Name';
                } else if (item is StockOwner) {
                  displayName = item.owner ?? 'No Name';
                }
                return Text(displayName);
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget displayRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2, // Adjusts width based on screen size
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xff16425B),
              ),
            ),
          ),
          const SizedBox(width: 5), // Spacing between label and value
          Expanded(
            flex: 4, // Allows value to take remaining space
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              softWrap: true, // Ensures text wraps properly
            ),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff16425B), // Dynamic background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded edges
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // Dynamic padding
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xffd9dcd6), // Dynamic text color
        ),
      ),
    );
  }

  Align statusDisplay() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        widget.stock.status ?? '',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: widget.stock.getColor(),
        ),
      ),
    );
  }

  Widget simpleDisplay(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4), // Spacing between items
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xff16425B)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xff16425B),
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
