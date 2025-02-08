import 'package:database/models/areasForStock.dart';
import 'package:database/models/speciesForStock.dart';
import 'package:database/models/stock.dart';
import 'package:database/models/stockOwner.dart';
import 'package:database/services/database_service.dart';
import 'package:flutter/material.dart';

class DisplaySingleStock extends StatefulWidget{
  final Stock stock;
  const DisplaySingleStock({super.key, required this.stock});

  @override
  State<DisplaySingleStock> createState() => _DisplaySingleStockState();
}

class _DisplaySingleStockState extends State<DisplaySingleStock> {
  
  late Future<List<AreasForStock>> _areaForStock;
  late Future<List<SpeciesForStock>> _speciesForStock;
  late Future<List<StockOwner>> _stockOwner;

  @override
  void initState() {
    super.initState();

    String? whereStr = 'uuid = "${widget.stock.uuid}"';
    _areaForStock = DatabaseService.instance.readAll(tableName: 'AreasForStock', where : whereStr, fromMap: AreasForStock.fromMap);
    _speciesForStock = DatabaseService.instance.readAll(tableName: 'SpeciesForStock', where : whereStr, fromMap: SpeciesForStock.fromMap);
    _stockOwner = DatabaseService.instance.readAll(tableName: 'StockOwner', where : whereStr, fromMap: StockOwner.fromMap);
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        title: Text(widget.stock.shortName ?? 'N/A'),
        backgroundColor: const Color(0xff16425B),
        foregroundColor: const Color(0xffd9dcd6),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _identitySection(context),
          ],
        ),
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
                  simpleDisplay('Semantic ID', widget.stock.grsfSemanticID ?? ''),
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
