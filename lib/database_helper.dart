import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {


  static DatabaseHelper instance=DatabaseHelper._privateConstructor();
  static Database _database;
  static final _dbName='wallpaperApp.db';
  static final _dbVersion=1;
  static final _tableName="searchHistory";
  static final columnId='_id';
  static final columnName='history';

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if(_database!=null)  return _database;
    _database=await initiateDatabase();
    return _database;
  }
  Future<Database> initiateDatabase()async {

    Directory directory=await getApplicationDocumentsDirectory();
    String path=join(directory.path,_dbName);
   return await openDatabase(path,version: _dbVersion,onCreate: _onCreate);

  }
  Future _onCreate(Database db,int version) {
    db.execute(
      '''
      CREATE TABLE $_tableName(
      $columnId INTEGER PRIMARY KEY,
      $columnName TEXT NOT NULL )
      '''
    );
  }
  Future<int> insert(Map<String,dynamic> row) async{
    Database db=await instance.database;
    return await db.insert(_tableName,row);
  }
  Future<int> delete(int id) async{
    Database db=await instance.database;
    return await db.delete(_tableName,where: "$columnId = ? ",whereArgs: [id]);
  }
  Future<List<Map<String,dynamic>>> getAllHistory() async{
    Database db=await instance.database;
    return await db.query(_tableName);
  }

}
