import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:breeze/views/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}
