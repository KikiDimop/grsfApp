import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grsfApp/models/area.dart';
import 'package:grsfApp/models/areasForFishery.dart';
import 'package:grsfApp/models/areasForStock.dart';
import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/fishery.dart';
import 'package:grsfApp/models/fisheryOwner.dart';
import 'package:grsfApp/models/fishingGear.dart';
import 'package:grsfApp/models/species.dart';
import 'package:grsfApp/models/speciesForStock.dart';
import 'package:grsfApp/models/stock.dart';
import 'package:grsfApp/models/stockOwner.dart';
import 'package:grsfApp/services/csv_service.dart';
import 'package:grsfApp/services/database_service.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const String urlStockPng =
    'https://www.fao.org/fishery/geoserver/wms?service=WMS&version=1.1.0&request=GetMap&layers=grsf%3Agrsf_resource_polygons,fifao:UN_CONTINENT2&bbox=-180.0%2C-60.0%2C180.0%2C90.0&width=768&height=330&srs=EPSG%3A4326&styles=&format=image%2Fpng&cql_filter=uuid=%27';
const String urlStockPngEnding = ' %27;INCLUDE';

class SearchStock {
  final String selectedSpeciesSystem,
      speciesCode,
      speciesName,
      selectedAreaSystem,
      areaCode,
      areaName,
      selectedFAOMajorArea,
      selectedResourceType,
      selectedResourceStatus;

  SearchStock(
      {this.selectedSpeciesSystem = '',
      this.speciesCode = '',
      this.speciesName = '',
      this.selectedAreaSystem = '',
      this.areaCode = '',
      this.areaName = '',
      this.selectedFAOMajorArea = '',
      this.selectedResourceType = '',
      this.selectedResourceStatus = ''});
}

class SearchStockForSpecies {
  final String speciesName;

  SearchStockForSpecies(this.speciesName);
}

class SearchFisheryForSpecies {
  final String speciesName;

  SearchFisheryForSpecies(this.speciesName);
}

class SearchFishery {
  final String selectedSpeciesSystem,
      speciesCode,
      speciesName,
      selectedAreaSystem,
      areaCode,
      areaName,
      selectedGearSystem,
      gearCode,
      gearName,
      selectedFAOMajorArea,
      selectedResourceType,
      selectedResourceStatus,
      flagCode;

  SearchFishery(
      {this.selectedSpeciesSystem = '',
      this.speciesCode = '',
      this.speciesName = '',
      this.selectedAreaSystem = '',
      this.areaCode = '',
      this.areaName = '',
      this.selectedGearSystem = '',
      this.gearCode = '',
      this.gearName = '',
      this.selectedFAOMajorArea = '',
      this.selectedResourceType = '',
      this.selectedResourceStatus = '',
      this.flagCode = ''});
}

Color getColor(String? status) {
  return status == 'pending'
      ? const Color(0xff5779A9)
      : status == 'approved'
          ? const Color(0xff138A36)
          : status == 'rejected'
              ? const Color(0xffB3001B)
              : const Color(0xffA9A9A9);
}

Future<void> openSourceLink(String link) async {
  final Uri url = Uri.parse(link);

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

void showFullText(BuildContext context, String title, String value) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffd9dcd6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff16425B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xff16425B),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff16425B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showMap(BuildContext context, String title, String uuid) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffd9dcd6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff16425B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xff16425B),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Image.network('$urlStockPng$uuid$urlStockPngEnding'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> sourceLink(
  List<String> sourceUrls,
  BuildContext context,
) async {
  if (sourceUrls.length == 1) {
    openSourceLink(sourceUrls[0]);
  } else {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffd9dcd6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sourceUrls.map((url) {
                String siteName = Uri.parse(url).host.replaceAll("www.", "");
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () => openSourceLink(url),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff16425B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      siteName,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xffd9dcd6)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xff16425B)),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> updateTable<T>({
  required String urlCsv,
  required String tableName,
  required T Function(Map<String, dynamic>) fromMap,
}) async {
  try {
    // Download and process CSV data
    await CsvService.downloadCsvData(urlCsv);
    List<Map<String, dynamic>> csvData = await CsvService.loadCsvData(
      'data/user/0/com.example.grsfApp/app_flutter/data.csv',
    );

    if (csvData.isNotEmpty) {
      // Update the grsfApp table
      await DatabaseService.instance.deleteAllRows(tableName);
      await DatabaseService.instance.batchInsertData(
        csvData.cast<Map<String, dynamic>>(),
        tableName,
      );
    }
  } catch (e) {
    throw Exception('Error updating $tableName: $e');
  }
}

Future<void> updateAllTables() async {
  try {
    // Update all tables sequentially (or parallelize if needed)
    await updateTable(
      urlCsv: Area.urlCsv,
      tableName: Area.tableName,
      fromMap: Area.fromMap,
    );
    await updateTable(
      urlCsv: Species.urlCsv,
      tableName: Species.tableName,
      fromMap: Species.fromMap,
    );
    await updateTable(
      urlCsv: Fishery.urlCsv,
      tableName: Fishery.tableName,
      fromMap: Fishery.fromMap,
    );
    await updateTable(
      urlCsv: AreasForFishery.urlCsv,
      tableName: 'AreasForFishery',
      fromMap: AreasForFishery.fromMap,
    );
    await updateTable(
      urlCsv: FisheryOwner.urlCsv,
      tableName: 'FisheryOwner',
      fromMap: FisheryOwner.fromMap,
    );
    await updateTable(
      urlCsv: Stock.urlCsv,
      tableName: Stock.tableName,
      fromMap: Stock.fromMap,
    );
    await updateTable(
      urlCsv: SpeciesForStock.urlCsv,
      tableName: 'SpeciesForStock',
      fromMap: SpeciesForStock.fromMap,
    );
    await updateTable(
      urlCsv: AreasForStock.urlCsv,
      tableName: 'AreasForStock',
      fromMap: AreasForStock.fromMap,
    );
    await updateTable(
      urlCsv: StockOwner.urlCsv,
      tableName: 'StockOwner',
      fromMap: StockOwner.fromMap,
    );
    await updateTable(
      urlCsv: Gear.urlCsv,
      tableName: 'Gear',
      fromMap: Gear.fromMap,
    );
    await updateTable(
      urlCsv: FaoMajorArea.urlCsv,
      tableName: 'FaoMajorArea',
      fromMap: FaoMajorArea.fromMap,
    );

    debugPrint("All data updated successfully!");
  } catch (e) {
    debugPrint("Error updating tables: $e");
    rethrow;
  }
}

List<T> mergedata<T>(
    {required List<T>? datalist,
    required String? Function(T) getUuid,
    required Map<String, dynamic>? responsedata}) {
  List<String> apiIds = [];

  if (responsedata != null && responsedata['result'] != null) {
    apiIds = List<String>.from(responsedata['result']);
  }

  Set<String> apiIdSet = apiIds.toSet();
  List<T> filteredData = datalist!.where((item) {
    String? uuid = getUuid(item);
    return uuid != null && apiIdSet.contains(uuid);
  }).toList();
  return filteredData;
}

Future<Map<String, dynamic>?> getApiData(String link) async {
  try {
    final response = await http.get(Uri.parse(link));
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      return jsonDecode(decoded) as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    print('API Error: $e');
    return null;
  }
}
