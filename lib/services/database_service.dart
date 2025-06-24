import 'package:grsfApp/models/faoMajorArea.dart';
import 'package:grsfApp/models/fishery.dart';
import 'package:grsfApp/models/stock.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grsf.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE Fishery (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT,
          grsf_name TEXT,
          grsf_semantic_id TEXT,
          short_name TEXT,
          type TEXT,
          status TEXT,
          traceability_flag TEXT,
          species_code TEXT,
          species_type TEXT, 
          species_name TEXT,
          gear_type TEXT,
          gear_code TEXT,
          flag_code TEXT,
          management_entities TEXT,
          parent_areas TEXT,
          firms_code TEXT,
          fishsource_code TEXT,
          FAO_SDG14_4_1_questionnaire_code TEXT
        )
        ''');
        print('Fishery table created');

        await db.execute('''
        CREATE TABLE AreasForFishery (     
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT,
          area_type TEXT NOT NULL,
          area_code TEXT NOT NULL,
          area_name TEXT
        )
        ''');
        print('AreasForFishery table created');

        await db.execute('''
        CREATE TABLE FisheryOwner (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT,
          owner TEXT,
          source_name TEXT
        )
        ''');
        print('FisheryOwner table created');

        await db.execute('''
        CREATE TABLE Stock (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT,
          grsf_name TEXT NOT NULL,
          grsf_semantic_id TEXT NOT NULL,
          short_name TEXT,
          type TEXT NOT NULL,
          status TEXT,
          parent_areas TEXT,
          sdg_flag INTEGER,
          jurisdictional_distribution TEXT,
          firms_code TEXT,
          ram_code TEXT,
          fishsource_code TEXT,
          FAO_SDG14_4_1_questionnaire_code TEXT
        )
        ''');
        print('Stock table created');

        await db.execute('''
        CREATE TABLE SpeciesForStock (     
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT,
          species_type TEXT NOT NULL,
          species_code TEXT NOT NULL,
          species_name TEXT
        )
        ''');
        print('SpeciesForStock table created');

        await db.execute('''
        CREATE TABLE AreasForStock (     
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT,
          area_type TEXT NOT NULL,
          area_code TEXT NOT NULL,
          area_name TEXT
        )
        ''');
        print('AreasForStock table created');

        await db.execute('''
        CREATE TABLE StockOwner (     
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT,
          owner TEXT NOT NULL,
          source_name TEXT NOT NULL
        )
        ''');
        print('StockOwner table created');

        await db.execute('''
          CREATE TABLE Gear (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fishing_gear_type TEXT,
            fishing_gear_id TEXT,
            fishing_gear_abbreviation TEXT,
            fishing_gear_name TEXT,
            fishing_gear_group_type TEXT,
            fishing_gear_group_id TEXT,
            fishing_gear_group_name TEXT
          )
        ''');
        print('Gear table created');

        await db.execute('''
          CREATE TABLE Species (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            scientific_name TEXT,
            asfis_id TEXT,
            aphia_id TEXT,
            fishbase_id TEXT,
            tsn_id TEXT,
            gbif_id TEXT,
            taxonomic_id TEXT,
            iucn_id TEXT,
            iucn_characterization TEXT,
            common_names TEXT
          )
        ''');
        print('Species table created');

        await db.execute('''
        CREATE TABLE Area (   
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          area_code TEXT,
          area_code_type TEXT,
          area_name TEXT,
          total_occurrences TEXT,
          stock_occurrences TEXT,
          fishery_occurrences TEXT
        )
        ''');
        print('Area table created');

        await db.execute('''
        CREATE TABLE FaoMajorArea (   
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fao_major_area_concat TEXT,
          fao_major_area_code TEXT,
          fao_major_area_name TEXT
        )
        ''');
        print('FaoMajorArea table created');
      },
    );
  }

  Future<List<T>> readAll<T>({
    required String tableName,
    String? where,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      final db = await database;
      final result = await db.query(tableName, where: where ?? '1=1');
      //print(result);
      return result.map((json) => fromMap(json)).toList();
    } catch (e) {
      print("Error in readAll for table $tableName: $e");
      return [];
    }
  }

  Future<List<FaoMajorArea>> getFaoMajorAreas(String codesString) async {
    try {
      final db = await database;
      List<String> codes = codesString.split(';').map((e) => e.trim()).toList();
      if (codes.isEmpty) return [];

      String placeholders = List.filled(codes.length, '?').join(', ');
      String sql = '''
        SELECT * 
        FROM ${FaoMajorArea.tableName}
        WHERE fao_major_area_concat IN ($placeholders)
      ''';

      List<Map<String, dynamic>> result = await db.rawQuery(sql, codes);

      return result.map((row) => FaoMajorArea.fromMap(row)).toList();
    } catch (e, stackTrace) {
      print('Error in getFaoMajorAreas: $e');
      print(stackTrace);
      return [];
    }
  }

  Future<List<T>> readAllColumns<T>({
    required String tableName,
    String? where,
    required T Function(Map<String, dynamic>) fromMap,
    List<String>? columns,
  }) async {
    try {
      final db = await database;
      final result =
          await db.query(tableName, columns: columns, where: where ?? '1=1');
      //print(result);
      return result.map((json) => fromMap(json)).toList();
    } catch (e) {
      print("Error in readAll for table $tableName: $e");
      return [];
    }
  }

  Future<void> batchInsertData(
      List<Map<String, dynamic>> data, tableName) async {
    final Database db = await database;

    await db.transaction((txn) async {
      var batch = txn.batch();

      for (var row in data) {
        batch.insert('$tableName', row);
      }

      await batch.commit(noResult: true);
    });
  }

  Future<int> delete(int id, String tableName) async {
    final db = await instance.database;

    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getRecordCount(tableName) async {
    try {
      final db = await instance.database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
      );
      return count ?? 0;
    } catch (e) {
      print('Error getting record count on $tableName: $e');
      return 0; // Return 0 on error
    }
  }

  Future<int> deleteAllRows(tableName) async {
    final db = await instance.database;
    return await db.delete('$tableName');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<List<String>> getDistinct(String field, String table) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT $field FROM $table WHERE $field IS NOT NULL');

    return result.map((row) => row[field] as String).toList();
  }

  Future<List<Stock>> searchStock(
      {dynamic fields,
      required Stock Function(Map<String, dynamic>) fromMap,
      required bool forSpecies}) async {
    final db = await instance.database;

    String query = ''' SELECT * FROM Stock ''';

    List<String> conditions = [];
    List<dynamic> parameters = [];
    if (!forSpecies) {
      query += ''' s
                LEFT JOIN AreasForStock a ON s.uuid = a.uuid
                LEFT JOIN SpeciesForStock sp ON s.uuid = sp.uuid
                WHERE 1=1 ''';

      if (fields?.selectedSpeciesSystem != null &&
          fields!.selectedSpeciesSystem.isNotEmpty) {
        conditions.add("sp.species_type LIKE ? ");
        parameters.add(fields?.selectedSpeciesSystem.replaceAll('All', '%'));
      }
      if (fields?.speciesCode != null && fields!.speciesCode.isNotEmpty) {
        conditions.add("sp.species_code LIKE ?");
        parameters.add(fields?.speciesCode);
      }
      if (fields?.speciesName != null && fields!.speciesName.isNotEmpty) {
        conditions.add("sp.species_name LIKE ?");
        parameters.add(fields?.speciesName);
      }
      if (fields?.selectedAreaSystem != null &&
          fields!.selectedAreaSystem.isNotEmpty) {
        conditions.add("a.area_type LIKE ?");
        parameters.add(fields?.selectedAreaSystem.replaceAll('All', '%'));
      }
      if (fields?.areaCode != null && fields!.areaCode.isNotEmpty) {
        conditions.add("a.area_code LIKE ?");
        parameters.add(fields?.areaCode);
      }
      if (fields?.areaName != null && fields!.areaName.isNotEmpty) {
        conditions.add("a.area_name LIKE ?");
        parameters.add(fields?.areaName);
      }
      if (fields?.selectedFAOMajorArea != null &&
          fields!.selectedFAOMajorArea.isNotEmpty) {
        conditions.add("s.parent_areas LIKE ?");
        parameters.add(
            '${'%' + fields.selectedFAOMajorArea.replaceAll('All', '%')}%');
      }
      if (fields?.selectedResourceType != null &&
          fields!.selectedResourceType.isNotEmpty) {
        conditions.add("s.type LIKE ?");
        parameters.add(fields?.selectedResourceType.replaceAll('All', '%'));
      }
      if (fields?.selectedResourceStatus != null &&
          fields!.selectedResourceStatus.isNotEmpty) {
        conditions.add("s.status LIKE ?");
        parameters.add(fields?.selectedResourceStatus.replaceAll('All', '%'));
      }

      if (conditions.isNotEmpty) {
        query += " AND ${conditions.join(" AND ")}";
      }
    } else {
      query += ''' WHERE uuid in (
        SELECT uuid FROM SpeciesForStock WHERE ''';

      if (fields.speciesName.isNotEmpty) {
        conditions.add("species_name = ?");
        parameters.add(fields.speciesName);
      }

      if (conditions.isNotEmpty) {
        query += " ${conditions.join(" ")} ) ";
      }
    }
    query += ' GROUP BY s.UUID';
    print(query);

    final result = await db.rawQuery(query, parameters);

    return result.map((json) => fromMap(json)).toList();
  }

  Future<List<Fishery>> searchFishery({
    dynamic fields,
    required Fishery Function(Map<String, dynamic>) fromMap,
  }) async {
    final db = await instance.database;

    List<String> conditions = [];
    List<dynamic> parameters = [];

    String query = ''' SELECT * FROM Fishery ''';

    query += ''' f
      LEFT JOIN AreasForFishery a ON f.uuid = a.uuid
      LEFT JOIN Gear g on f.gear_code = g.fishing_gear_id
      WHERE 1=1
      ''';
    if (fields.selectedAreaSystem.isNotEmpty) {
      conditions.add("a.area_type LIKE ?");
      parameters.add(fields.selectedAreaSystem.replaceAll('All', '%'));
    }
    if (fields.areaCode.isNotEmpty) {
      conditions.add("a.area_code LIKE ?");
      parameters.add(fields.areaCode);
    }
    if (fields.areaName.isNotEmpty) {
      conditions.add("a.area_name LIKE ?");
      parameters.add(fields.areaName);
    }
    if (fields.selectedSpeciesSystem.isNotEmpty) {
      conditions.add("f.species_type LIKE ?");
      parameters.add(fields.selectedSpeciesSystem);
    }
    if (fields.speciesCode.isNotEmpty) {
      conditions.add("f.species_code LIKE ?");
      parameters.add(fields.speciesCode);
    }
    if (fields.speciesName.isNotEmpty) {
      conditions.add("f.species_name LIKE ?");
      parameters.add(fields.speciesName);
    }
    if (fields.selectedGearSystem.isNotEmpty) {
      conditions.add("f.gear_type LIKE ?");
      parameters.add(fields.selectedGearSystem);
    }
    if (fields.gearCode.isNotEmpty) {
      conditions.add("f.gear_code LIKE ?");
      parameters.add(fields.gearCode);
    }
    if (fields.gearName.isNotEmpty) {
      conditions.add("g.fishing_gear_name LIKE ?");
      parameters.add(fields.gearName);
    }
    if (fields.selectedFAOMajorArea.isNotEmpty) {
      conditions.add("f.parent_areas LIKE ?");
      parameters.add('${'%' + fields.selectedFAOMajorArea}%');
    }
    if (fields.selectedResourceType.isNotEmpty) {
      conditions.add("f.type LIKE ?");
      parameters.add(fields.selectedResourceType);
    }
    if (fields.selectedResourceStatus.isNotEmpty) {
      conditions.add("f.status LIKE ?");
      parameters.add(fields.selectedResourceStatus);
    }

    if (fields.flagCode.isNotEmpty) {
      conditions.add("f.flag_code LIKE ?");
      parameters.add(fields.flagCode);
    }

    if (conditions.isNotEmpty) {
      query += " AND ${conditions.join(" AND ")}";
    }

    print(query);
    print(parameters);
    final result = await db.rawQuery(query, parameters);
    return result.map((json) => fromMap(json)).toList();
  }
}
