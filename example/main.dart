import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

Future<void> main() async {
  // Initialize the database and tables
  await TarsierMySQLStorage.init(
    MySQLConfig(
      host: 'localhost',
      port: 3306,
      userName: 'root',
      password: 'bonfire',
      databaseName: 'tarsier_mysql_storage',
    ),
    tables: [
      UserTable(),
      RoleTable(),
      // Add more table class that extends BaseTable
    ],
  );

  final userTable = UserTable();

  // Insert a user
  final userId = await userTable.createObject(
    User(name: 'John Doe', email: 'john@gmail.com', createdAt: DateTime.now()),
  );
  print('Inserted user with ID: $userId');

  // Fetch all users
  final users = await userTable.all();
  for (var user in users) {
    print('User: ${user.id}, ${user.name}, Password: ${user.email}');
  }

  // Update a user
  await userTable.updateObject(
    userId.toInt(),
    User(name: 'Sam Doe', email: 'sam@gmail.com', createdAt: DateTime.now()),
  );

  // Check if a user exists
  final exists = await userTable.exists({'name': 'Juan Dela Cruz'});
  print('User exists: $exists');

  final storage = TarsierMySQLStorage();

  // Backup the database to a file
  await storage.backup(
    'backup.sql',
    onProgress: (currentStep, totalSteps, message) {
      final percentage = (currentStep / totalSteps * 100).toStringAsFixed(1);
      print('$message ($currentStep / $totalSteps, $percentage%)');
    },
  );

  // Restore .sql file into database
  await storage.restore(
    'backup.sql',
    onProgress: (currentStep, totalSteps, message) {
      final percentage = (currentStep / totalSteps * 100).toStringAsFixed(1);
      print('$message ($currentStep / $totalSteps, $percentage%)');
    },
  );

  final userss = await userTable.all();
  for (var user in userss) {
    print('User: ${user.id}, ${user.name}, Password: ${user.email}');
  }
}

class UserTable extends BaseTable<User> {
  UserTable()
      : super(
          tableName: User.tableName,
          schema: User.schema,
          fromMap: (map) => User.fromMap(map),
          toMap: (user) => user.toMap(),
        );
}

class RoleTable extends BaseTable<Role> {
  RoleTable()
      : super(
          tableName: Role.tableName,
          schema: Role.schema,
          fromMap: (map) => Role.fromMap(map),
          toMap: (user) => user.toMap(),
        );
}

class User extends BaseTableModel {
  final int? id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: int.parse(map['id']),
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static const String tableName = 'users';

  static Map<String, String> get schema => {
        'id': 'INT AUTO_INCREMENT PRIMARY KEY',
        'name': 'VARCHAR(255)  NOT NULL',
        'email': 'VARCHAR(255)  NOT NULL',
        'created_at': 'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP',
      };
}

class Role extends BaseTableModel {
  final int? id;
  final String name;
  final String email;
  final DateTime createdAt;

  Role({
    this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static const String tableName = 'roles';

  static Map<String, String> get schema => {
        'id': 'int auto_increment primary key',
        'name': 'varchar(255)  not null',
        'email': 'varchar(255)  not null',
        'created_at': 'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP',
      };
}
