import 'package:flutter/material.dart';
import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/models/areasForStock.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/fisheryOwner.dart';
import 'package:grsfApp/models/fishingGear.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/models/speciesForStock.dart';
import 'package:grsfApp/models/stockOwner.dart';
import 'package:path/path.dart';

Widget dataDisplay({required String label, required String value}) {
  if (value.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff16425B),
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff16425B),
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
          maxLines: null,
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  } else {
    return const SizedBox.shrink();
  }
}

Widget dataDetailsDisplay(
    {required String label,
    required String code,
    required String system,
    required String name,
    required bool withIcon,
    VoidCallback? onIconPressed,
    IconData? icon}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff16425B),
          fontWeight: FontWeight.normal,
        ),
      ),
      if (code.isNotEmpty)
        Text(
          'Code     : $code',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff16425B),
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
          maxLines: null,
        ),
      if (system.isNotEmpty)
        Text(
          'System : $system',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff16425B),
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
          maxLines: null,
        ),
      if (name.isNotEmpty)
        Row(
          children: [
            Text(
              'Name    : $name',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
              maxLines: null,
            ),
            const Spacer(),
            if (withIcon)
              InkWell(
                onTap: onIconPressed,
                child: Icon(
                  icon,
                  color: const Color(0xff16425B),
                  size: 25,
                ),
              ),
          ],
        ),
      const SizedBox(
        height: 5,
      )
    ],
  );
}

Widget customButton({
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

Align statusDisplay(String status) {
  return Align(
    alignment: Alignment.centerRight,
    child: Text(
      status,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: getColor(status),
      ),
    ),
  );
}

Widget iButton({
  required VoidCallback onPressed,
  required IconData? icon,
  required String assetPath,
}) {
  return IconButton(
    onPressed: onPressed,
    icon: (assetPath.isEmpty)
        ? Icon(
            icon,
            color: const Color(0xff16425B),
            size: 24,
          )
        : Image.asset(
            assetPath,
            width: 24,
            height: 24,
            color: const Color(0xff16425B), // Optional: Apply color overlay
          ),
    splashRadius: 24,
  );
}

Widget listViewItemStockData(String value, String unit, String type,
    String source, String reportingYear, String referenceYear) {
  return Card(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: dataDisplay(label: 'Value', value: value)),
              const SizedBox(width: 8),
              Expanded(child: dataDisplay(label: 'Unit', value: unit)),
            ],
          ),
          const SizedBox(height: 8),
          dataDisplay(label: 'Data Owner', value: source),
          const SizedBox(height: 8), // Spacing before Type
          dataDisplay(label: 'Type', value: type),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: dataDisplay(
                      label: 'Reference Year', value: referenceYear)),
              const SizedBox(width: 8),
              Expanded(
                  child: dataDisplay(
                      label: 'Reporting Year', value: reportingYear)),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget dataList<T>({required List<T>? items}) {
  if (items == null) {
    return const Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Color(0xffd9dcd6)),
      ),
    );
  }

  items = items.toList();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 5),
    padding: const EdgeInsets.all(10),
    child: items.isEmpty
        ? const Center(
            child: Text(
              'No data found',
              style: TextStyle(color: Color(0xffd9dcd6)),
            ),
          )
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items?[index];
              return listViewItem(item: item);
            },
          ),
  );
}

Widget listViewItem({
  dynamic item,
  String name = '',
  String system = '',
  String code = '',
}) {
  if (item != null) {
    if (item is AreasForFishery) {
      print('here');
      name = item.areaName ?? 'No Name';
      system = item.areaType ?? 'No System';
      code = item.areaCode ?? 'No Code';
    } else if (item is FisheryOwner) {
      name = item.owner ?? 'No Name';
      system = '';
      code = '';
    } else if (item is Gear) {
      name = item.fishingGearName ?? 'No Name';
      system = item.fishingGearType ?? 'No System';
      code = item.fishingGearId ?? 'No ID';
    } else if (item is FaoMajorArea) {
      code = item.faoMajorAreaCode ?? 'No Code';
      name = item.faoMajorAreaName ?? 'No Name';
      system = item.faoMajorAreaConcat ?? 'No System';
    } else if (item is SpeciesForStock) {
      name = item.speciesName ?? 'No Name';
      system = item.speciesType ?? 'No System';
      code = item.speciesCode ?? 'No Code';
    } else if (item is AreasForStock) {
      name = item.areaName ?? 'No Name';
      system = item.areaType ?? 'No System';
      code = item.areaCode ?? 'No Code';
    } else if (item is StockOwner) {
      name = item.owner ?? 'No Name';
    }
  }

  if (name.isEmpty && system.isEmpty && code.isEmpty) {
    return const SizedBox.shrink();
  }

  return Card(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dataDisplay(label: 'Name', value: name),
          const SizedBox(height: 1),
          if (system.isNotEmpty && code.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: dataDisplay(label: 'Code', value: code)),
                const SizedBox(width: 8),
                Expanded(child: dataDisplay(label: 'System', value: system)),
              ],
            ),
        ],
      ),
    ),
  );
}

Widget truncatedDisplay(
    BuildContext context, String title, String value, int maxLength) {
  if (value.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xff16425B)),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                value.length > maxLength
                    ? '${value.substring(0, maxLength)}...'
                    : value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff16425B),
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
            ),
            if (value.length > maxLength)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  onTap: () => showFullText(context, title, value),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Color(0xff16425B),
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
