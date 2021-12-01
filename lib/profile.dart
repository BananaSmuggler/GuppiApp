import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper/Helper.dart';
import 'models/User.dart';
import 'services/UserDBHelper.dart';

class ProfilePage extends StatefulWidget {
  final userDbHelper = UserDBHelper();
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userNameController = new TextEditingController();
  var localUser = '';
  var oldUsername = '';
  var _location;
  bool savingUserState = false;

  readLocal() async {
    final prefs = await SharedPreferences.getInstance();
    localUser = prefs.getString(Helper.sharedPrefUserName) ?? '';
    setState(() {});
  }

  Future<bool> _saveUser(userName) async {
    if (userName.isNotEmpty) {
      User localUser = User(userName, 'online', '', '');
      bool flag = await widget.userDbHelper.saveUser(localUser);
      if (!flag) {
        Helper.displaySnackBar('User Name already Taken', context);
        return false;
      }
      return flag;
    }
    return false;
  }

  _handleSetUserName() async {
    // get the username: send it to the database & save it locally: SharePreference
    String tempUserName = _userNameController.text;
    if (tempUserName.isNotEmpty) {
      setState(() {
        savingUserState = true;
      });
      if (this.oldUsername.isNotEmpty && oldUsername != tempUserName) {
        Helper.deleteUserLocally();
        widget.userDbHelper.deleteUser(oldUsername);
      }
      if (oldUsername != tempUserName) {
        // Save it to Firebase only if not Present
        bool userSaved = await _saveUser(tempUserName);
        if (userSaved) {
          Helper.saveUserLocally(tempUserName); // Saves Locally
          // Clear the text field
          _userNameController.clear();
          // Close the KeyBoard
          FocusScope.of(context).requestFocus(FocusNode());
          this.localUser = tempUserName;
          this.savingUserState = false;
          setState(() {});
        }
      } else {
        setState(() {
          localUser = oldUsername;
          oldUsername = '';
        });
      }
      setState(() {
        savingUserState = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Getting the username Saved Locally
    readLocal();
  }

  @override
  void dispose() {
    super.dispose();
    _userNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: this.localUser.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Your Username is set to: $localUser'),
                      ElevatedButton(
                          onPressed: _handleSetNewUserName,
                          child: Text('Set New Username'))
                    ],
                  )
                : Column(children: <Widget>[
                    TextFormField(
                        controller: _userNameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter your username')),
                    DropdownButton<String>(
                      hint: Text("Select a School"),
                      value: _location,
                      items: <String>['CPP'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _location = newValue!;
                        });
                      },
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed:
                              savingUserState ? null : _handleSetUserName,
                          child: savingUserState
                              ? CircularProgressIndicator()
                              : Text(
                                  'Set Username',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                )),
                    )
                  ]),
          ),
        ));
  }

  void _handleSetNewUserName() {
    this._userNameController.text = localUser;
    oldUsername = localUser;
    setState(() {
      localUser = '';
    });
  }
}
