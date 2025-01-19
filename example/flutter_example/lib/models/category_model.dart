import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

class Category extends BaseTableModel {
  int? id;
  String name;
  String description;
  int isActive;

  Category({
    this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: int.parse(map[CategoryFields.id]),
      name: map[CategoryFields.name] as String,
      description: map[CategoryFields.description] as String,
      isActive: int.parse(map[CategoryFields.isActive]),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      CategoryFields.id: id,
      CategoryFields.name: name,
      CategoryFields.description: description,
      CategoryFields.isActive: isActive,
    };
  }

  static const String tableName = 'categories';

  static Map<String, String> get schema => {
        CategoryFields.id: 'INT AUTO_INCREMENT PRIMARY KEY',
        CategoryFields.name: 'VARCHAR(100) NOT NULL',
        CategoryFields.description: 'VARCHAR(255)',
        CategoryFields.isActive: 'TINYINT(1) DEFAULT 1',
      };
}

class CategoryFields {
  static final List<String> values = [id, name, description, isActive];

  static const String id = 'id';
  static const String name = 'name';
  static const String description = 'description';
  static const String isActive = 'is_active';
}
