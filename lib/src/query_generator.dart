abstract class QueryGenerator {
  static String generateSelectQuery(
      String tableName, Map<String, dynamic> whereConditions) {
    final whereClause =
        whereConditions.keys.map((key) => "$key = :$key").join(" AND ");

    return "SELECT * FROM $tableName WHERE $whereClause";
  }

  static String generateInsertQuery(
      String tableName, Map<String, dynamic> values) {
    final keys = values.keys.map((key) => key).join(", ");
    final placeholders = values.keys.map((key) => ":$key").join(", ");

    return "INSERT INTO $tableName ($keys) VALUES ($placeholders)";
  }

  static String generateUpdateQuery(
      String tableName, Map<String, dynamic> values, String whereKey) {
    final setClause = values.keys
        .where((key) => key != whereKey)
        .map((key) => "$key = :$key")
        .join(", ");

    return "UPDATE $tableName SET $setClause WHERE $whereKey = :$whereKey";
  }

  static String generateDeleteQuery(String tableName, String whereKey) {
    return "DELETE FROM $tableName WHERE $whereKey = :$whereKey";
  }
}
