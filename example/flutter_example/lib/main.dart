import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_example/common/env.dart';
import 'package:flutter_example/ui/screens/home_screen.dart';
import 'package:tarsier_mysql_storage/tarsier_mysql_storage.dart';

import 'tables/tables.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.init();

  await TarsierMySQLStorage.init(
      MySQLConfig(
        host: Env.dbHost ?? 'localhost',
        port: int.parse(Env.dbPort ?? '3306'),
        userName: Env.dbUsername!,
        password: Env.dbPassword!,
        databaseName: Env.dbDatabase!,
      ),
      tables: [
        UserTable(),
        NoteTable(),
        ProductTable(),
        CategoryTable(),
      ]);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
