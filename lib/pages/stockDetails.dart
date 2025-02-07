import 'package:database/models/stock.dart';
import 'package:flutter/material.dart';

class StockDetailsScreen extends StatelessWidget {
  final Stock stock;
  const StockDetailsScreen({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16425B),
      appBar: AppBar(
        title: Text(stock.shortName ?? 'N/A'),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      stock.status ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: stock.getColor(),
                      ),
                    ),
                  ),
                  simpleDisplay('Short Name', stock.shortName ?? '',
                      isBold: true),
                  simpleDisplay('Semantic ID', stock.grsfSemanticID ?? '',
                      isBold: true),
                  simpleDisplay('Semantic Title', 'N/A', isBold: true),
                  simpleDisplay('UUID', stock.uuid ?? '', isBold: true),
                  simpleDisplay('Type', stock.type ?? '', isBold: true),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget simpleDisplay(String title, String value, {bool isBold = false}) {
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
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
