import 'dart:io';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CsvService {

  static Future<void> downloadCsvData(url) async {
    //String url = 'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Fuuid+%3Fgrsf_name+%3Fgrsf_semantic_id+%3Fshort_name+%3Ftype+%3Fstatus+%3Ftraceability_flag+%3Fgear_type+%3Fgear_code+%3Fflag_code+%3Fmanagement_entities+%3Fparent_areas+%3Ffirms_code+%3Ffishsource_code+%3Fsdg14_code+AS+%3FFAO_SDG14_4_1_questionnaire_code%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E%0D%0AFROM+%3Chttp%3A%2F%2Ffirms%3E%0D%0AFROM+%3Chttp%3A%2F%2Ffishsource%3E%0D%0AFROM+%3Chttp%3A%2F%2FuserProvided%3E%0D%0AWHERE%7B%0D%0A%09%3Frecord+a+crm%3ABC62_Capture_Activity.%0D%0A%09%3Frecord+crm%3Ahas_uuid+%3Fuuid.%0D%0A%09%3Frecord+rdfs%3Alabel+%3Fshort_name.%0D%0A%09%3Frecord+crm%3AP1_is_identified_by+%3Fgrsf_name_uri.%0D%0A%09%3Fgrsf_name_uri+a+crm%3AE41_Appellation.%0D%0A%09%3Fgrsf_name_uri+rdfs%3Alabel+%3Fgrsf_name.%0D%0A%09%3Frecord+crm%3AP1_is_identified_by+%3Fgrsf_semantic_id_uri.%0D%0A%09%3Fgrsf_semantic_id_uri+a+crm%3AE42_Identifier.%0D%0A%09%3Fgrsf_semantic_id_uri+rdfs%3Alabel+%3Fgrsf_semantic_id.%0D%0A%09%3Frecord+crm%3Ahas_status+%3Fstatus_uri.%0D%0A%09%3Fstatus_uri+rdfs%3Alabel+%3Fstatus.%0D%0A%09%3Frecord+crm%3Ahas_traceability_flag+%3Ftraceability_flag.%0D%0A%09%3Frecord+crm%3AP2_has_type+%3Ftype_uri.%0D%0A%09%3Ftype_uri+rdfs%3Alabel+%3Ftype.%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_source_record+%3Ffirms_source_record.%0D%0A%09%09%3Ffirms_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Ffirms%2Fsource%2Ffirms%3E.%0D%0A%09%09%3Ffirms_source_record+crm%3Ahas_original_code+%3Ffirms_code%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3AP125_used_object_of_type+%3Fgear_uri.%0D%0A%09%09%3Fgear_uri+crm%3Ahas_gear_code+%3Fgear_code.%0D%0A%09%09%3Fgear_uri+crm%3Ahas_gear_type+%3Fgear_type.%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_flag_state+%3Fflag_uri.%0D%0A%09%09%3Fflag_uri+crm%3Ahas_flag_code+%3Fflag_code.%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_management_entities_values+%3Fmanagement_entities.%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_source_record+%3Ffishsource_source_record.%0D%0A%09%09%3Ffishsource_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Ffishsource%2Fsource%2Ffishsource%3E.%0D%0A%09%09%3Ffishsource_source_record+crm%3Ahas_original_code+%3Ffishsource_code%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_source_record+%3Fsdg14_source_record.%0D%0A%09%09%3Fsdg14_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Fsdg_14_4_1%2Fsource%2Fsdg_14_4_1%3E.%0D%0A%09%09%3Fsdg14_source_record+crm%3Ahas_original_code+%3Fsdg14_code.%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3AO15_occupied_parent+%3Fparent_areas%0D%0A++++%7D%0D%0A%7D&format=text%2Fcsv&timeout=0';
    String filename = 'data.csv';
    String filePath = await downloadAndSaveCSV(url, filename);
    print('CSV saved to: $filePath');
  }


    static Future<List<Map<String, dynamic>>> loadCsvData(String filePath) async {
    try {
      // Read the CSV file from the local file system
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at path: $filePath');
      }

      final rawData = await file.readAsString();

      // Parse the CSV file
      List<List<dynamic>> parsedData = const CsvToListConverter().convert(
        rawData,
        eol: '\n',
        shouldParseNumbers: true, // Automatically parse numbers
      );

      // Ensure we have data
      if (parsedData.isEmpty) {
        return [];
      }

      // Get headers from the first row
      final headers = parsedData[0].map((header) => header.toString().trim()).toList();

      // Convert remaining rows to maps
      return parsedData.sublist(1).map((row) {
        Map<String, dynamic> rowMap = {};
        
        // Handle rows that might have fewer columns than headers
        for (int i = 0; i < headers.length; i++) {
          if (i < row.length) {
            // Clean and transform the data
            var value = row[i];
            
            // Convert empty strings to null
            if (value is String && value.trim().isEmpty) {
              value = null;
            }
            
            // Handle special cases like 'NA', 'N/A', etc.
            if (value is String && 
                ['na', 'n/a', 'null', 'undefined']
                    .contains(value.toLowerCase().trim())) {
              value = null;
            }

            rowMap[headers[i]] = value;
          } else {
            // Fill missing values with null
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
      // Read the CSV file from the local file system
      
      final file = File(filePath);
      if (await file.exists()) {
        final rawData = await file.readAsString();

        // Parse the CSV file
        List<List<dynamic>> parsedData = const CsvToListConverter().convert(
          rawData,
          eol: '\n', // Ensure rows are split correctly
        );

        // Remove the header row if needed
        csvData = parsedData.sublist(1);
      } else {
        throw Exception('File not found at path: $filePath');
      }

      // Load the CSV file from the assets

      //final rawData = await rootBundle.loadString(filePath);
      // Parse the CSV file, skipping the first row (header)
      // List<List<dynamic>> parsedData = const CsvToListConverter().convert(
      //   rawData,
      //   eol: '\n', // Ensure rows are split correctly
      // );
      // Remove the header row
      //csvData = parsedData.sublist(1);
    } catch (e) {
      csvData = []; // Set an empty list on error
      throw Exception('[loadCsvData] Error loading CSV: $e');
    }
    return csvData;
  }


  static Future<String> downloadAndSaveCSV(String url, String filename) async {
    try {
      // Make HTTP request to get the CSV data
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load CSV file. Status code: ${response.statusCode}');
      }

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      // Create the file
      File file = File(filePath);
      
      // Write the CSV data to the file
      //await file.writeAsString(response.body);
      await file.writeAsBytes(response.bodyBytes);
      
      return filePath;
    } catch (e) {
      throw Exception('Error downloading and saving CSV: $e');
    }
  }

  /// Checks if a CSV file exists at the given path
  static Future<bool> csvFileExists(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      return File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets the path for a CSV file
  static Future<String> getCSVFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

}