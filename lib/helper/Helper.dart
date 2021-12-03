import 'package:flutter/material.dart';
import 'package:roomiez_app/models/User.dart';
import 'package:roomiez_app/services/MessageDbHelper.dart';
import 'package:roomiez_app/services/UserDBHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Helper {

  static String sharedPrefUserName = "LocalUserName";
  static String sharedPrefGroupId = "LocalGroupID";
  static String sharedPrefPeerUserName = "LocalPeerUserName";

  static displaySnackBar(msg, context) {
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  static Future<bool> saveUserLocally(username) async {
    // obtain the shared prefs
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPrefUserName, username);
  }

  static Future<bool> savePeerUserLocally(username) async {
    // obtain the shared prefs
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPrefPeerUserName, username);
  }

  static Future<bool> saveGroupIDLocally(groupId) async {
    // obtain the shared prefs
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPrefGroupId, groupId);
  }

  static Future<bool> deleteUserLocally() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove(sharedPrefUserName);
  }

  static Future<bool> deletePeerUserLocally() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove(sharedPrefPeerUserName);
  }

  static Future<bool> deleteGroupIdLocally() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove(sharedPrefGroupId);
  }

  static Future<String> getLocalGroupID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(sharedPrefGroupId) ?? '';
  }

  static Future<String> getLocalUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPrefUserName) ?? '';
  }

  static Future<String> getLocalPeerUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPrefPeerUserName) ?? '';
  }

  static deleteUser() async {
    // delete the User Locally and Database
    String username = await Helper.getLocalUserName();
    String peerUserName = await Helper.getLocalPeerUserName();
    String groupId = await Helper.getLocalGroupID();
    if (username.isNotEmpty) {
      UserDBHelper().deleteUser(username);
      UserDBHelper().updateUser(new User(peerUserName, 'online', '', username));
      MessageDbHelper().deleteAllMessages(groupId);
      Helper.deleteUserLocally();
      Helper.deletePeerUserLocally();
      Helper.deleteGroupIdLocally();
    }
  }

  static void clearFields() {
    deleteUserLocally();
    deletePeerUserLocally();
    deleteGroupIdLocally();
  }

}