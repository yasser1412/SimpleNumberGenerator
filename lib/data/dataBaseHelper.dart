import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:gptask/models/users.dart';

class DataBaseHelper {
  /// CREATE THE DATABASE
  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "users.db"),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, email TEXT, password TEXT NOT NULL)"
        );
      },
      version: 1,
    );
  }
  /// INSERT A NEW USER INTO THE DATABASE
  Future<int> insertUser(User user) async {
    final Database db = await initDB();
    return db.insert("users", user.toMap());
  }
  /// RETRIEVE ALL USERS DATA FROM DATABASE
  Future<List<User>> retrieveUsers() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.query('users');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }
  /// DELETE A USER USING I'TS ID
  Future<void> deleteUser (int id) async {
    final db = await initDB();
    await db.delete(
      'users',
      where: "id = ?",
      whereArgs: [id],
    );
  }
  /// CHECKS VALIDATION OF USERNAME AND PASSWORD OF A USER
  Future<User> selectUser(User user) async {
    final String tableUser = "users";
    final String columnUserName = "username";
    final String columnPassword = "password";
    final String columnEmail = "email";
    final dbClient = await initDB();
    List<Map> maps = await dbClient.query(
        tableUser,
        columns: [columnUserName, columnPassword, columnEmail],
        where: "$columnUserName = ? and $columnPassword = ?",
        whereArgs: [user.username, user.password],
        );
    if (maps.isNotEmpty) {
      return User(username: maps[0]["username"], password: maps[0]["password"], email: maps[0]["email"] );
    }
    else {
      return User(username: "none", email: "none", password: "none");
    }
  }
  /// UPDATE USER INFO
  Future<int> updateUser(User user) async {
    final Database db = await initDB();
    return await db.update(
      "users",
      user.toMap(), 
      where: "id = ?", 
      whereArgs: [user.id],
      );
  }
}