import 'package:flutter_example/models/product_model.dart';
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

class ProductTable extends BaseTable<Product> {
  ProductTable()
      : super(
          tableName: Product.tableName,
          schema: Product.schema,
          fromMap: (map) => Product.fromMap(map),
          toMap: (user) => user.toMap(),
        );
}
