import 'package:flutter_example/models/user_model.dart';
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

class UserTable extends BaseTable<User> {
  UserTable()
      : super(
          tableName: User.tableName,
          schema: User.schema,
          fromMap: (map) => User.fromMap(map),
          toMap: (user) => user.toMap(),
        );
}
