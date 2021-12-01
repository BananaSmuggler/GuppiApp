// Helper Class to Save Retrieve Users
import 'package:firebase_database/firebase_database.dart';
import 'package:roomiez_app/main.dart';
import 'package:roomiez_app/models/User.dart';
import 'package:roomiez_app/splash.dart';

class UserDBHelper {
  final DatabaseReference _userDatabaseRef =
      FirebaseDatabase.instance.reference().child('Users');

  // Get all the User from the Database
  List<User> getAllUsers() {
    List<User> allUsers = [];
    _userDatabaseRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> getData = snapshot.value;
      getData.forEach((k, v) {
        User userValue = User.fromJSON(v);
        // if list does not contain: Add it
        if (!allUsers.contains(userValue)) {
          allUsers.add(userValue);
        }
      });
    });
    return allUsers;
  }

  Future<User?> getRandomUser(User currentUser) async {
    Map<dynamic, dynamic> jsonOutput = Map();
    User randomUser = new User('n/a', '', '', '');
    await _userDatabaseRef
        .orderByChild('status')
        .equalTo('online')
        .once()
        .then((value) => jsonOutput = value.value);
    print('UserDB: Got Online Users from DB..');
    print(jsonOutput);
    jsonOutput.forEach((key, value) {
      if (randomUser.userName == 'n/a' && key != currentUser.userName && currentUser.chatHistory != key) {
        randomUser = User.fromJSON(value);
      }
    });

    return randomUser;
  }

  // Save the User to the DB: use the User's Username to be the Key
  Future<bool> saveUser(User u) async {
    // Check if the userName is already Present:
    // if yes: return False
    final userData = await _userDatabaseRef.child(u.userName).once();
    if (userData.value == null) {
      _userDatabaseRef..child(u.userName).set(u.toJSON());
      return true;
    }
    return false;
  }

  // Delete the User From the Firebase
  void deleteUser(String userName) {
    _userDatabaseRef.child(userName).remove();
  }

  // Update the User in the Database
  void updateUser(User u) {
    _userDatabaseRef.update({u.userName: u.toJSON()});
  }

  getUserInfo(String userName) async {
    final result = await _userDatabaseRef.child(userName).once();
    if (result.value != null) return User.fromJSON(result.value);
    return null;
  }

  getDbReference() {
    return _userDatabaseRef;
  }

}
