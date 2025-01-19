/// Configuration class for MySQL database connection.
class MySQLConfig {
  /// The hostname or IP address of the MySQL server.
  final String host;

  /// The port of the MySQL server (default is usually 3306).
  final int port;

  /// The username to connect to the MySQL server.
  final String userName;

  /// The password to authenticate the MySQL user.
  final String password;

  /// The name of the database to connect to.
  final String databaseName;

  /// Constructor for `MySQLConfig`.
  ///
  /// Example:
  /// ```dart
  /// MySQLConfig(
  ///   host: 'localhost',
  ///   port: 3306,
  ///   userName: 'root',
  ///   password: 'your_password',
  ///   databaseName: 'your_database',
  /// );
  /// ```
  const MySQLConfig({
    required this.host,
    required this.port,
    required this.userName,
    required this.password,
    required this.databaseName,
  });
}
