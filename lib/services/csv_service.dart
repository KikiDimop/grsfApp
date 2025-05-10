import 'dart:io';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CsvService {

  static Future<void> downloadCsvData(url) async {
    String filename = 'data.csv';
    String filePath = await downloadAndSaveCSV(url, filename);
    print('CSV saved to: $filePath');
  }


    static Future<List<Map<String, dynamic>>> loadCsvData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at path: $filePath');
      }

      final rawData = await file.readAsString();

      List<List<dynamic>> parsedData = const CsvToListConverter().convert(
        rawData,
        eol: '\n',
        shouldParseNumbers: true, // Automatically parse numbers
      );

      if (parsedData.isEmpty) {
        return [];
      }

      final headers = parsedData[0].map((header) => header.toString().trim()).toList();

      return parsedData.sublist(1).map((row) {
        Map<String, dynamic> rowMap = {};
        
        for (int i = 0; i < headers.length; i++) {
          if (i < row.length) {
            var value = row[i];
            
            if (value is String && value.trim().isEmpty) {
              value = null;
            }
            
            if (value is String && 
                ['na', 'n/a', 'null', 'undefined']
                    .contains(value.toLowerCase().trim())) {
              value = null;
            }

            rowMap[headers[i]] = value;
          } else {
            rowMap[headers[i]] = null;
          }
        }
        return rowMap;
      }).toList();

    } catch (e) {
      print('[loadCsvData] Error loading CSV: $e');
      rethrow;
    }
  }


  static Future<List<List<dynamic>>> loadCsvData1(String filePath) async {
    List<List<dynamic>> csvData = [];
    try {
      
      final file = File(filePath);
      if (await file.exists()) {
        final rawData = await file.readAsString();

        List<List<dynamic>> parsedData = const CsvToListConverter().convert(
          rawData,
          eol: '\n', 
        );

        csvData = parsedData.sublist(1);
      } else {
        throw Exception('File not found at path: $filePath');
      }

    } catch (e) {
      csvData = []; // Set an empty list on error
      throw Exception('[loadCsvData] Error loading CSV: $e');
    }
    return csvData;
  }


  static Future<String> downloadAndSaveCSV(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load CSV file. Status code: ${response.statusCode}');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      File file = File(filePath);
      
      await file.writeAsBytes(response.bodyBytes);
      
      return filePath;
    } catch (e) {
      throw Exception('Error downloading and saving CSV: $e');
    }
  }

  static Future<bool> csvFileExists(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      return File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  static Future<String> getCSVFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

}