import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
class DBHelper {
  DBHelper._(); // Private constructor to prevent instantiation

  static final DBHelper instance = DBHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'realtimeGPS.db');
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL,
        speed REAL,
        timestamp TEXT
      )
    ''');
  }

  Future<void> insertLocation(double latitude, double longitude, double speed) async {
    final Database db = await database;
    await db.insert(
      'locations',
      {'latitude': latitude, 'longitude': longitude, 'speed': speed, 'timestamp': DateTime.now().toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final Database db = await database;
    return db.query('locations');
  }
  Future<void> clearTable(String table) async {
    final Database db = await database;
    await db.delete(table);
  }

  Future<File> exportToCSV(String table) async {
    final Database db = await database;
    List<Map<String, dynamic>> data = await db.query(table);

    final List<List<dynamic>> csvData = [data.first.keys.toList()]..addAll(data.map((e) => e.values.toList()));

    String csvContent = const ListToCsvConverter().convert(csvData);

    // Add dialog to select path
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

    String csvPath = '${appDocumentsDirectory.path}/location.csv';
    print(appDocumentsDirectory.path);
    //String csvPath = '${appDocumentsDirectory.path}/$table.csv';

    File csvFile = File(csvPath);
    var file = await csvFile.writeAsString(csvContent);
    if(await csvFile.exists()) {
      print('File exists at path: ${csvFile.path}');
    } else {
      print('File not created');
    }
    return file;
  }
}

Future<String?> getDirectoryPath() async {
  Directory? directory = await getExternalStorageDirectory();
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
    initialDirectory: directory?.path,
  );
  return selectedDirectory;
}
