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
          species_code TEXT,
          species_code_type TEXT,
          species_name TEXT,
          total_occurrences TEXT,
          stock_occurrences TEXT,
          fishery_occurrences TEXT
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
      },
    );
  }


  Future<List<T>> readAll<T>({
    required String tableName,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      final db = await database;
      final result = await db.query(tableName);

      int count = await getRecordCount(tableName);
      print('Number of records in $tableName: $count');

      return result.map((json) => fromMap(json)).toList();
    } catch (e) {
      print("Error in readAll for table $tableName: $e");
      return [];
    }
  }

    //Batch processing with transaction
  Future<void> batchInsertData(List<Map<String, dynamic>> data, tableName) async {
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
}
