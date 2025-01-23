
<p align="center">
  <a href="https://pub.dev/packages/tarsier_mysql_storage">
    <img height="260" src="https://raw.githubusercontent.com/marianz-bonfire/tarsier_mysql_storage/master/assets/logo.png">
  </a>
  <h1 align="center">Tarsier MySQL Storage</h1>
</p>

<p align="center">
  <a href="https://pub.dev/packages/tarsier_mysql_storage">
    <img src="https://img.shields.io/pub/v/tarsier_mysql_storage?label=pub.dev&labelColor=333940&logo=dart">
  </a>
  <a href="https://pub.dev/packages/tarsier_mysql_storage/score">
    <img src="https://img.shields.io/pub/points/tarsier_mysql_storage?color=2E8B57&label=pub%20points">
  </a>
  <a href="https://github.com/marianz-bonfire/tarsier_mysql_storage/actions/workflows/dart.yml">
    <img src="https://github.com/marianz-bonfire/tarsier_mysql_storage/actions/workflows/dart.yml/badge.svg">
  </a>
  <a href="https://tarsier-marianz.blogspot.com">
    <img src="https://img.shields.io/static/v1?label=website&message=tarsier-marianz&labelColor=135d34&logo=blogger&logoColor=white&color=fd3a13">
  </a>
</p>

<p align="center">
  <a href="https://pub.dev/documentation/tarsier_mysql_storage/latest/">Documentation</a> •
  <a href="https://github.com/marianz-bonfire/tarsier_mysql_storage/issues">Issues</a> •
  <a href="https://github.com/marianz-bonfire/tarsier_mysql_storage/tree/master/example">Example</a> •
  <a href="https://github.com/marianz-bonfire/tarsier_mysql_storage/blob/master/LICENSE">License</a> •
  <a href="https://pub.dev/packages/tarsier_mysql_storage">Pub.dev</a>
</p>


A simple and flexible library for managing MySQL databases (*using mysql_client package*) in Dart and Flutter applications. It simplifies database operations with reusable abstractions for tables and models, making it easy to build scalable and maintainable applications.

## ✨ Features

- **Easy Database Management**: Initialize and manage MySQL databases effortlessly.
- **Dynamic Tables**: Define table schemas dynamically with support for CRUD operations.
- **Model Mapping**: Seamlessly map database rows to model objects.
- **Cross-Platform**:  Works seamlessly in Dart and Flutter environments.
- **MySQL database** integration using the `mysql_client` package.
- **Dynamic table** management with `BaseTable`.
- **Automated table creation** and schema management.
- **CRUD operations** with reusable query generation.
- Clear table and reset auto-increment support.

## 🚀 Getting Started

Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  tarsier_mysql_storage: ^1.0.2
```
Run the following command:
```bash
flutter pub get
```


## 📒 Usage
- ### Define a Model
  💡Using this package is similar with [tarsier_local_storage](https://pub.dev/packages/tarsier_local_storage) package.

Create a class that extends `BaseTableModel` to represent a database entity:
```dart
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

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

  static const String tableName = 'users';

  static Map<String, String> get schema => {
        'id': 'INT AUTO_INCREMENT PRIMARY KEY',
        'name': 'VARCHAR(255)  NOT NULL',
        'email': 'VARCHAR(255)  NOT NULL',
        'created_at': 'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP',
      };
}
```
- ### Define a Table
Create a table class by extending BaseTable:
```dart
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

import 'user_model.dart';

class UserTable extends BaseTable<User> {
  UserTable()
      : super(
          tableName: User.tableName,
          schema: User.schema,
          fromMap: (map) => User.fromMap(map),
          toMap: (user) => user.toMap(),
        );
}
```
- ### Initialize the Database
Initialize the database and pass the table definitions:
```dart
void main() async {
  // Initialize the database and tables
  await TarsierMySQLStorage.init(
    MySQLConfig(
      host: 'localhost',
      port: 3306,
      userName: 'root',
      password: 'password',
      databaseName: 'tarsier_mysql_storage',
    ),
    tables: [
      UserTable(),
      RoleTable(),
    ],
  );
  // Ensure the table exists
  // But, not necessary to call this `createTable` because creation
  // of tables is called on `init` function
  //await userTable.createTable(db);

  final userTable = UserTable();
  // Insert a user
  final userId = await userTable.createObject(
    User(name: 'John Doe', email: 'john@gmail.com', createdAt: DateTime.now()),
  );
  print('Inserted user with ID: $userId');

  // Fetch all users
  final users = await userTable.all();
  for (var user in users) {
    print('User: ${user.name}, Password: ${user.email}');
  }

  // Update a user
  await userTable.updateObject(
      userId.toInt(), // id to be updated
      User(name: 'Sam Doe', email: 'sam@gmail.com', createdAt: DateTime.now()),
  );

  // Check if a user exists
  final exists = await userTable.exists({'name': 'Juan Dela Cruz'});
  print('User exists: $exists');
}
```
NOTE: Above code uses `createObject` and `updateObject` that inserts a model object into the database. But there is an alternative way on inserting/updating data using a raw map of data into the database.
<details>
  <summary> Key Differences Between `createObject` and `create`, `updateObject` and `update`.</summary>
  
| **Function**         | **Purpose**                                                                                   | **When to Use**                                                                                     |
|-----------------------|-----------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| `createObject`        | Inserts a model object into the database.                                                    | Use when working with strongly typed model classes.                                                |
| `create`              | Inserts a raw map of data into the database.                                                 | Use when working with dynamic or non-typed data, or when data comes directly from an API or user.   |
| `updateObject`        | Updates a database row using a model object.                                                 | Use when you have a complete, strongly typed object with the updated data.                         |
| `update`              | Updates a database row using a raw map.                                                      | Use when you have dynamic or partial data, or don't want to rely on model objects.                 |

</details>

- ### Backup the Database
The `backup` function saves the current database structure and data to a `.sql` file. You can optionally include database-level commands like `DROP DATABASE`, `CREATE DATABASE`, and `USE`.

Additionally, the `onProgress` callback provides updates about the current step, total steps, and a message describing the ongoing process.

```dart
  final storage = TarsierMySQLStorage();

  await storage.backup(
    'backup.sql',
    includeDatabaseStructure: true, // Include database DROP, CREATE, and USE commands
    onProgress: (currentStep, totalSteps, message) {
      final percentage = (currentStep / totalSteps * 100).toStringAsFixed(1);
      print('$message ($currentStep / $totalSteps, $percentage%)');
    },
  );
```

- ### Restore the Database
The `restore` function restores a previously backed-up database from a `.sql` file. The `onProgress` callback provides updates about the current step, total steps, and the statement being executed.

```dart
  final storage = TarsierMySQLStorage();

  await storage.restore(
    'backup.sql',
    onProgress: (currentStep, totalSteps, message) {
      final percentage = (currentStep / totalSteps * 100).toStringAsFixed(1);
      print('$message ($currentStep / $totalSteps, $percentage%)');
    },
  );
```
On backup and restore operations with `onProgress` callback has its benefits;
  - `Real-Time Feedback`: Keeps the user informed about the progress of long-running operations.
  - `Error Localization`: If an error occurs during the operation, the progress updates make it easier to identify the problematic step or SQL statement.
  - `Enhanced User Experience`: Ideal for integrating with a UI (e.g., showing progress bars or logs in a Flutter app).

## 📸 Example Screenshots

|       Home Screen         |          Notes Screen           |   Users Screen         |   Products  Screen         |   Categories Screen         |
| :------------------------: | :--------------------------------: | :--------------------------: | :--------------------------: | :--------------------------: |
| ![Home Screen][home-image] | ![Notes Screen][notes-image] | ![Users Screen][users-image] | ![Products Screen][products-image] | ![Categories Screen][categories-image] |

[home-image]: https://raw.githubusercontent.com/marianz-bonfire/tarsier_mysql_storage/master/assets/home.png
[notes-image]: https://raw.githubusercontent.com/marianz-bonfire/tarsier_mysql_storage/master/assets/notes.png
[users-image]: https://raw.githubusercontent.com/marianz-bonfire/tarsier_mysql_storage/master/assets/users.png
[products-image]: https://raw.githubusercontent.com/marianz-bonfire/tarsier_mysql_storage/master/assets/products.png
[categories-image]: https://raw.githubusercontent.com/marianz-bonfire/tarsier_mysql_storage/master/assets/categories.png



## 🎖️ License
This project is licensed under the [MIT License](https://mit-license.org/). See the LICENSE file for details.
## 🐞 Contributing
Contributions are welcome! Please submit a pull request or file an issue for any bugs or feature requests
on [GitHub](https://github.com/marianz-bonfire/tarsier_mysql_storage).