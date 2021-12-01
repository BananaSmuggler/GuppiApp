import 'dart:async';
import 'package:flutter/material.dart';
import 'package:roomiez_app/helper/Helper.dart';

class AppLifeCycle extends StatefulWidget {
  const AppLifeCycle({Key? key, required this.child}) : super(key: key);

  final Widget child;
  @override
  _AppLifeCycleState createState() => _AppLifeCycleState();
}

class _AppLifeCycleState extends State<AppLifeCycle> with WidgetsBindingObserver {

  late Timer timer;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
     if  (timer.isActive) timer.cancel();
    }
    else if (state == AppLifecycleState.inactive) {
      timer = Timer(const Duration(minutes: 1), () {
        Helper.deleteUser();
      });
    }
    // print('AppLifeCycleState: $state');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
