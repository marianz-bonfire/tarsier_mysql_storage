import 'dart:io';

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
  MySQLConfig? _config;

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
    _instance._config = config;
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

  /// Backs up the database by exporting all tables into a `.sql` file.
  ///
  /// - [backupPath]: The file path where the backup will be saved.
  /// - [includeDatabaseStructure]: Whether to include database creation commands.
  /// - [onProgress]: A callback that provides progress updates in the form (currentStep, totalSteps, message).
  Future<void> backup(
    String backupPath, {
    bool includeDatabaseStructure = true,
    Function(int currentStep, int totalSteps, String message)? onProgress,
  }) async {
    final db = await database;
    final file = File(backupPath);

    // Retrieve database name from the config
    final databaseName = _config!.databaseName;

    final buffer = StringBuffer();
    int currentStep = 0;
    int totalSteps = 1; // Start with 1 for the final file writing step

    // Header information
    buffer
        .writeln('-- --------------------------------------------------------');
    buffer.writeln('-- Host:                         ${_config!.host}');
    buffer.writeln('-- TarsierMySQLStorage Version:  1.0.2');
    buffer
        .writeln('-- --------------------------------------------------------');
    buffer.writeln();

    final tablesResult = await db.execute('SHOW TABLES');
    final tableNames = tablesResult.rows.map((row) => row.colAt(0)).toList();

    totalSteps += tableNames.length * 2; // 2 steps per table: schema + data

    if (includeDatabaseStructure) {
      totalSteps += 1; // Adding 1 step for database structure
    }

    // Notify progress
    onProgress?.call(currentStep, totalSteps, 'Starting database backup...');

    if (includeDatabaseStructure) {
      buffer.writeln('-- Dumping database structure for $databaseName');
      buffer.writeln('DROP DATABASE IF EXISTS `$databaseName`;');
      buffer.writeln('CREATE DATABASE IF NOT EXISTS `$databaseName`;');
      buffer.writeln('USE `$databaseName`;');
      buffer.writeln();

      currentStep++;
      onProgress?.call(currentStep, totalSteps, 'Database structure included.');
    }

    for (var table in tableNames) {
      // Export table schema
      onProgress?.call(
          currentStep, totalSteps, 'Exporting table schema for: $table');

      final schemaResult = await db.execute('SHOW CREATE TABLE $table');
      final createTableSQL = schemaResult.rows.first.colAt(1);

      buffer.writeln('-- Table structure for `$table`');
      buffer.writeln('$createTableSQL;');
      buffer.writeln();
      currentStep++;

      // Export table data
      onProgress?.call(
          currentStep, totalSteps, 'Exporting table data for: $table');
      final rowsResult = await db.execute('SELECT * FROM $table');
      if (rowsResult.numOfRows > 0) {
        buffer.writeln('-- Dumping data for table `$table`');
        final columnNames =
            rowsResult.cols.map((col) => '`${col.name}`').join(', ');
        for (var row in rowsResult.rows) {
          final values = row
              .assoc()
              .values
              .map((value) =>
                  value == null ? 'NULL' : "'${value.replaceAll("'", "\\'")}'")
              .join(', ');
          buffer
              .writeln('INSERT INTO `$table` ($columnNames) VALUES ($values);');
        }
        buffer.writeln();
      }
      currentStep++;
      onProgress?.call(
          currentStep, totalSteps, 'Table $table exported successfully.');
    }

    // Write buffer to file
    onProgress?.call(currentStep, totalSteps, 'Writing backup to file...');
    await file.writeAsString(buffer.toString());
    currentStep++;
    onProgress?.call(currentStep, totalSteps, 'Database backup completed.');
  }

  /// Restores the database from a `.sql` file.
  ///
  /// - [backupPath]: The file path of the backup to restore from.
  /// - [onProgress]: A callback that provides progress updates in the form (currentStep, totalSteps, message).
  Future<void> restore(
    String backupPath, {
    Function(int currentStep, int totalSteps, String message)? onProgress,
  }) async {
    final db = await database;
    final file = File(backupPath);

    if (!file.existsSync()) {
      throw Exception('Backup file not found at $backupPath');
    }

    // Read the SQL file and split into statements
    onProgress?.call(0, 1, 'Reading backup file...');
    final sqlCommands = await file.readAsString();
    final statements =
        sqlCommands.split(';').where((stmt) => stmt.trim().isNotEmpty);

    // Determine total steps
    final totalSteps = statements.length;
    int currentStep = 0;

    // Execute each SQL statement
    for (var statement in statements) {
      currentStep++;
      onProgress?.call(currentStep, totalSteps,
          'Executing statement $currentStep of $totalSteps...');
      await db.execute(statement.trim());
    }

    // Final step: Completion
    onProgress?.call(totalSteps, totalSteps, 'Database restore completed.');
  }
}
