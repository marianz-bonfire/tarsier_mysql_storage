import 'package:flutter_example/models/note_model.dart';
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

class NoteTable extends BaseTable<Note> {
  NoteTable()
      : super(
          tableName: Note.tableName,
          schema: Note.schema,
          fromMap: (map) => Note.fromMap(map),
          toMap: (user) => user.toMap(),
        );
}
