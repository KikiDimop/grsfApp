import 'package:flutter/material.dart';
import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/models/areasForStock.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/fisheryOwner.dart';
import 'package:grsfApp/models/fishingGear.dart';
import 'package:grsfApp/models/global.dart';
import 'package:grsfApp/models/speciesForStock.dart';
import 'package:grsfApp/models/stockOwner.dart';
// import 'package:path/path.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
  required double iconSize,
}) {
  return IconButton(
    onPressed: onPressed,
    icon: (assetPath.isEmpty)
        ? Icon(
            icon,
            color: const Color(0xff16425B),
            size: iconSize,
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
          dataDisplay(label: 'Data Owner', value: source),
          dataDisplay(label: 'Type', value: type),
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

Widget dataList<T>({
  required List<T>? items,
  required String searchQuery,
  required String sortField,
  required String sortOrder,
  required Widget Function({required T item}) listViewItem,
}) {
  // Helper function to extract fields based on item type
  Map<String, String> getFields(T? item) {
    String name = 'No Name';
    String system = 'No System';
    String code = 'No Code';

    if (item != null) {
      if (item is AreasForFishery) {
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
        system = '';
        code = '';
      }
    }

    return {'name': name, 'system': system, 'code': code};
  }

  if (items == null) {
    return const Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Color(0xffd9dcd6)),
      ),
    );
  }

  // Filter items based on search query
  final filteredItems = items.where((item) {
    final fields = getFields(item);
    return searchQuery.isEmpty ||
        fields['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
        fields['code']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
        fields['system']!.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();

  // Sort items based on sortField and sortOrder
  filteredItems.sort((a, b) {
    final fieldsA = getFields(a);
    final fieldsB = getFields(b);
    int comparison = 0;
    if (sortField == 'Name') {
      comparison = fieldsA['name']!.compareTo(fieldsB['name']!);
    } else if (sortField == 'Code') {
      comparison = fieldsA['code']!.compareTo(fieldsB['code']!);
    } else if (sortField == 'System') {
      comparison = fieldsA['system']!.compareTo(fieldsB['system']!);
    }
    return sortOrder == 'asc' ? comparison : -comparison;
  });

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 5),
    padding: const EdgeInsets.all(10),
    child: filteredItems.isEmpty
        ? const Center(
            child: Text(
              'No data found',
              style: TextStyle(color: Color(0xffd9dcd6)),
            ),
          )
        : ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
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

Padding listTitle({required String title}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xffd9dcd6),
      ),
    ),
  );
}

Widget textField(String label, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xff16425B),
          ),
        ),
      ),
      TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xff16425B)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xffd9dcd6).withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          suffixIcon: GestureDetector(
            onTap: () {
              controller.clear();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Icon(
                Icons.cancel,
                color: Color(0xff16425B),
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff16425B)),
          ),
        ),
      ),
    ],
  );
}
