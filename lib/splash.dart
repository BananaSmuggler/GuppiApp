import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'home.dart';
import 'main.dart';

class Splash extends StatefulWidget {
  const Splash({ Key? key }) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    goHome();
  }

  goHome()async{
    await Future.delayed(Duration(milliseconds: 4000), () {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MyHomePage(title: 'RANDO',)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text('GUPPI', style: TextStyle(
          fontSize: 60,
          foreground: Paint()
            ..shader = ui.Gradient.linear( 
              const Offset(0, 55),
              const Offset(150, 20),
              <Color>[
                Colors.blue,
                Colors.purple,
              ],
            )
        ),
        )
      )
    ));
  }
}