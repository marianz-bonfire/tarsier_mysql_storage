import 'dart:async';

import 'package:mysql_client/mysql_client.dart';
import 'package:tarsier_mysql_storage/src/query_generator.dart';
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

/// Abstract class for defining a base table for database operations.
///
/// This class provides common CRUD (Create, Read, Update, Delete)
/// operations and a framework for creating dynamic tables in the database.
///
/// To use this class:
/// - Extend it and define a concrete implementation for your table.
/// - Implement the `fromMap` and `toMap` functions for converting objects to/from the database format.
///
/// Example:
/// ```dart
/// class UserTable extends BaseTable<User> {
///   UserTable()
///       : super(
///           tableName: User.tableName,
///           schema: User.schema,
///           fromMap: (map) => User.fromMap(map),
///           toMap: (user) => user.toMap(),
///         );
/// }
/// ```

abstract class BaseTable<T extends BaseTableModel> {
  /// The name of the table in the database.
  final String tableName;

  /// The schema of the table, where the key is the column name, and the value is its SQL type definition.
  final Map<String, String> schema;

  /// Function to convert a map from the database into a model object.
  final T Function(Map<String, dynamic>) fromMap;

  /// Function to convert a model object into a map for the database.
  final Map<String, dynamic> Function(T) toMap;

  /// Constructor for the `BaseTable`.
  ///
  /// - [tableName]: The name of the table in the database.
  /// - [schema]: A map defining the schema of the table.
  /// - [fromMap]: A function to map database rows to model objects.
  /// - [toMap]: A function to map model objects to database rows.
  BaseTable({
    required this.tableName,
    required this.schema,
    required this.fromMap,
    required this.toMap,
  });

  /// Creates the table in the database if it does not exist.
  ///
  /// This method dynamically generates the `CREATE TABLE` SQL
  /// based on the table schema and executes it.
  ///
  /// - [db]: The database instance.
  Future<void> createTable(MySQLConnection db) async {
    final columns = schema.entries.map((e) => '${e.key} ${e.value}').join(', ');
    final createTableSQL = 'CREATE TABLE IF NOT EXISTS $tableName ($columns)';
    await db.execute(createTableSQL);
  }

  /// Retrieves all rows from the table.
  ///
  /// Returns a list of model objects.
  Future<List<T>> all() async {
    final db = await getDatabase();
    var data = await db!.execute('SELECT * FROM $tableName');
    return data.rows.map((e) => fromMap(e.assoc())).toList();
  }

  /// Retrieves a single row by a specific column value.
  ///
  /// - [whereConditions]: The where clause in Map form.
  ///
  /// Returns the matching model object or `null` if no match is found.
  Future<T?> get(Map<String, dynamic> whereConditions) async {
    final db = await getDatabase();
    var result = await db!.execute(
      QueryGenerator.generateSelectQuery(tableName, whereConditions),
      whereConditions,
    );
    if (result.rows.isNotEmpty) {
      return fromMap(result.rows.first.assoc());
    }
    return null;
  }

  /// Inserts a model object into the database.
  ///
  /// - [data]: The model object to be inserted.
  ///
  /// Returns the ID of the inserted row.
  Future<BigInt> createObject(T data) async {
    return await create(toMap(data));
  }

  /// Inserts a map of data into the database.
  ///
  /// - [data]: A map representing the row to be inserted.
  ///
  /// Returns the ID of the inserted row.
  Future<BigInt> create(Map<String, dynamic> data) async {
    final db = await getDatabase();
    var result = await db!.execute(
      QueryGenerator.generateInsertQuery(tableName, data),
      data,
    );
    return result.lastInsertID;
  }

  /// Updates a row with a new model object.
  ///
  /// - [id]: The ID of the row to update.
  /// - [item]: The new data as a model object.
  ///
  /// Returns the number of rows affected.
  Future<BigInt> updateObject(int id, T item) async {
    return update(id, toMap(item));
  }

  /// Updates a row with new data.
  ///
  /// - [id]: The ID of the row to update.
  /// - [data]: A map of the new data.
  ///
  /// Returns the number of rows affected.
  Future<BigInt> update(int id, Map<String, dynamic> data) async {
    // Ensure 'id' key is present in the data map
    if (!data.containsKey('id') || (int.parse(data['id'] ?? '0') < 1)) {
      data['id'] = id;
    }

    final db = await getDatabase();
    var result = await db!.execute(
      QueryGenerator.generateUpdateQuery(tableName, data, "id"),
      data,
    );
    return result.affectedRows;
  }

  /// Deletes a row by its ID.
  ///
  /// - [id]: The ID of the row to delete.
  Future<BigInt> delete(int id) async {
    final db = await getDatabase();
    var result = await db!.execute(
        QueryGenerator.generateDeleteQuery(tableName, "id"), {"id": id});
    return result.affectedRows;
  }

  /// Checks if a row exists in the table.
  ///
  /// - [conditions]: A map where the key is the column name, and the value is the value to match.
  ///
  /// Returns `true` if a matching row exists, otherwise `false`.
  Future<bool> exists(Map<String, dynamic> conditions) async {
    var result = await get(conditions);

    return result != null;
  }

  /// Clears all rows from the table and resets the auto-increment value.
  Future<void> emptyTable() async {
    final db = await getDatabase();

    // Clear the table
    await db!.execute('DELETE FROM $tableName');

    // Reset the auto-increment value
    await db.execute('ALTER TABLE $tableName AUTO_INCREMENT = 1');
  }

  /// Retrieves the database instance from `TarsierMySQLStorage`.
  ///
  /// Returns the initialized [MySQLConnection] instance.
  Future<MySQLConnection?> getDatabase() async {
    return await TarsierMySQLStorage().database;
  }
}
