import 'package:flutter_example/models/category_model.dart';
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

class CategoryTable extends BaseTable<Category> {
  CategoryTable()
      : super(
          tableName: Category.tableName,
          schema: Category.schema,
          fromMap: (map) => Category.fromMap(map),
          toMap: (user) => user.toMap(),
        );
}
