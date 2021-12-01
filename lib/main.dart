// @dart=2.9
import 'package:flutter/material.dart';
import 'package:roomiez_app/AppLifeCycle.dart';
import 'package:roomiez_app/helper/Helper.dart';
import 'package:roomiez_app/services/UserDBHelper.dart';
import 'package:roomiez_app/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return AppLifeCycle(
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,

          // Define the default font family.
          fontFamily: 'Nexa',

          // Define the default `TextTheme`. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: const TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'hind'),
          ),
         // primarySwatch: Colors.purple,
        ),
        home: Splash(),
      ),
    );
  }
}
