// @dart=2.9
import 'dart:io' show Directory;
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

class DatabaseAccount {

  static final _databaseName = "AccountDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'my_chart';

  static final columnKey = 'key';
  static final columnClient = 'client';
  static final columnDay = 'day';
  static final columnMonth = 'month';
  static final columnYear = 'year';
  static final columnPrezzo = 'prezzo';

  // make this a singleton class
  DatabaseAccount._privateConstructor();
  static final DatabaseAccount instance = DatabaseAccount._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnKey INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnClient TEXT NOT NULL,
            $columnDay INTEGER NOT NULL,
            $columnMonth INTEGER NOT NULL,
            $columnYear INTEGER NOT NULL,
            $columnPrezzo REAL NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> getFromDate(int day,int month,int year) async {
    Database db = await instance.database;
    return await db.query(table,where: '$columnDay = ? AND $columnMonth = ? AND $columnYear = ?', whereArgs: [day,month,year]);
  }

  Future<List<Map<String, dynamic>>> getDay(int day) async {
    Database db = await instance.database;
    return await db.query(table,where: '$columnDay = ?', whereArgs: [day]);
  }

  Future<List<Map<String, dynamic>>> getMonth(int month) async {
    Database db = await instance.database;
    return await db.query(table,where: '$columnMonth = ?', whereArgs: [month]);
  }

  Future<List<Map<String, dynamic>>> getYear(int year) async {
    Database db = await instance.database;
    return await db.query(table,where: '$columnYear = ?', whereArgs: [year]);
  }

  Future<List<Map<String, dynamic>>> getClient(String client) async {
    Database db = await instance.database;
    return await db.query(table,where: '$columnClient = ?', whereArgs: [client]);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }
  
  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnKey];
    return await db.update(table, row, where: '$columnKey = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnKey = ?', whereArgs: [id]);
  }
}