import 'package:flutter/material.dart';
import 'package:roomiez_app/helper/Helper.dart';
import 'package:roomiez_app/profile.dart';
import 'package:roomiez_app/RandonChatPage.dart';
import 'package:roomiez_app/services/MessageDbHelper.dart';
import 'package:roomiez_app/services/UserDBHelper.dart';

import 'models/User.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final _userDBHelper = UserDBHelper();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 1;
  List<Widget> widgetOptions = <Widget>[
    RandomChatPage(),
    ProfilePage(),
  ];
  User? user;

  _getCurrentUser() async {
    //if Current User is null: get from DB
    if (user == null) {
      String localSavedUserName = await Helper.getLocalUserName();
      var tempUser = await widget._userDBHelper.getUserInfo(localSavedUserName);
      if (tempUser != null) {
        user = tempUser;
        setState(() {
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void onItemTap(int index){
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: WillPopScope(
        onWillPop: _handleBackButton,
        child: Center(
          child: widgetOptions.elementAt(selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.purple,

        items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.stream,),
            title: Text('Guppi', style: TextStyle(

            ))),
        BottomNavigationBarItem(
            icon: Icon(Icons.person,),
            title: Text('Profile', style: TextStyle(

            )))
        ],
        currentIndex: selectedIndex,
        onTap: onItemTap,
      ),
    );
  }


  Future<void> openCloseDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext cxt) {
          return AlertDialog(
            title: const Text("Close the chat?"),
            content: Text('Messages will be deleted.'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    // DO Noting
                    Navigator.pop(context, 'Cancel');
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    // Close the Current Chat: clear the User's Status, Delete all the Messages
                    Navigator.pop(context, 'Close');
                    // Delete the messages and the user
                    Helper.deleteUser();
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }

  Future<bool> _handleBackButton() {
    openCloseDialog();
    return Future.value(false);
  }

  @override
  void dispose() {
    super.dispose();
    widget._userDBHelper.deleteUser(user!.userName);
    Helper.deleteUserLocally();

  }
}