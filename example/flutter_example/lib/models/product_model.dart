import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

class Product extends BaseTableModel {
  int? id;
  String name;
  String description;
  double price;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: int.parse(map[ProductFields.id]),
      name: map[ProductFields.name] as String,
      description: map[ProductFields.description] as String,
      price: double.parse(map[ProductFields.price]),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ProductFields.id: id,
      ProductFields.name: name,
      ProductFields.description: description,
      ProductFields.price: price,
    };
  }

  static const String tableName = 'products';

  static Map<String, String> get schema => {
        ProductFields.id: 'INT AUTO_INCREMENT PRIMARY KEY',
        ProductFields.name: 'VARCHAR(100) NOT NULL',
        ProductFields.description: 'VARCHAR(255)',
        ProductFields.price: 'DECIMAL(20, 2)',
      };
}

class ProductFields {
  static final List<String> values = [id, name, description, price];

  static const String id = 'id';
  static const String name = 'name';
  static const String description = 'description';
  static const String price = 'price';
}
