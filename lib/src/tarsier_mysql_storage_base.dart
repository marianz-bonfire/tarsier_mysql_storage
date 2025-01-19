import 'package:mysql_client/mysql_client.dart';
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

/// Singleton class for managing MySQL connections and automatic table creation
class TarsierMySQLStorage {
  TarsierMySQLStorage._privateConstructor();

  /// The singleton instance of `TarsierMySQLStorage`.
  static final TarsierMySQLStorage _instance =
      TarsierMySQLStorage._privateConstructor();

  /// Factory constructor to return the singleton instance.
  factory TarsierMySQLStorage() => _instance;

  /// The active MySQL connection instance.
  MySQLConnection? _database;

  /// Initializes the database connection and creates the provided tables.
  ///
  /// - [config]: The `MySQLConfig` object with connection details.
  /// - [tables]: A list of `BaseTable` instances to create tables automatically.
  ///
  /// Example:
  /// ```dart
  /// await TarsierMySQLStorage.init(
  ///   MySQLConfig(
  ///     host: 'localhost',
  ///     port: 3306,
  ///     userName: 'root',
  ///     password: 'your_password',
  ///     databaseName: 'your_database',
  ///   ),
  ///   tables: [UserTable(), RoleTable()],
  /// );
  /// ```
  static Future<void> init(
    MySQLConfig config, {
    required List<BaseTable> tables,
  }) async {
    // Initialize the database connection
    _instance._database = await MySQLConnection.createConnection(
      host: config.host,
      port: config.port,
      userName: config.userName,
      password: config.password,
      databaseName: config.databaseName,
    );
    await _instance._database!.connect();

    // Create all tables in the provided list
    for (var table in tables) {
      await table.createTable(_instance._database!);
    }
  }

  /// Returns the active MySQL connection.
  ///
  /// Throws an exception if the database has not been initialized.
  ///
  /// Example:
  /// ```dart
  /// final db = await TarsierMySQLStorage().database;
  /// ```
  Future<MySQLConnection> get database async {
    if (_database == null) {
      throw Exception(
          'Database not initialized. Call TarsierMySQLStorage.init first.');
    }
    return _database!;
  }

  /// Closes the active MySQL connection.
  ///
  /// Example:
  /// ```dart
  /// await TarsierMySQLStorage().close();
  /// ```
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
