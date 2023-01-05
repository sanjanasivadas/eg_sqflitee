import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;


class SQLHelper {

  static Future<void> createTables(sql.Database database) async { //database or we can use db as the object for sql.Database
    await database.execute("""CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {  //here db is function when we call db it should return database
    return sql.openDatabase(
      'kindacode.db',       //databasename.db
       version: 1,      //database version  bydefault version is 1 or we can upgrade accordingly
       onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

//create new item(journal)
  static Future<int> createItem(String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'description': description};
    final id = await db.insert('items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

//read all items(journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: 'id');
  }

//read a single item by id
//the app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: 'id = ?', whereArgs: ['id'], limit: 1);
  }

//update an item by id
  static Future<int> updateitem(int id, String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

//delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}