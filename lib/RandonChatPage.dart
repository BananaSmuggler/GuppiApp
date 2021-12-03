import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:roomiez_app/services/MessageDbHelper.dart';
import 'package:roomiez_app/services/UserDBHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'helper/Helper.dart';
import 'home.dart';
import 'models/Message.dart';
import 'models/User.dart';

class RandomChatPage extends StatefulWidget with WidgetsBindingObserver {
  final userDbHelper = UserDBHelper();
  final helper = Helper();
  final _messageDbHelper = MessageDbHelper();
  _RandomChatPageState createState() => _RandomChatPageState();
}

class _RandomChatPageState extends State<RandomChatPage> {
  // Database Ref
  late DatabaseReference _dbRef;
  // Controller for textField
  final _textMessageController = TextEditingController();
  // Local Scroller
  final _scrollerController = ScrollController();
  String currentUserID = '';
  String groupId = '';

  late User user;
  late User peerUser;

  bool connected = false;
  String loadingStatus = 'Searching for a Random User';

  createGroupId(String a, String b) {
    // We check which username has higher precedence
    if (a.hashCode <= b.hashCode) {
      Helper.saveGroupIDLocally("$b\_$a");
      return "$b\_$a";
    }
    Helper.saveGroupIDLocally("$a\_$b");
    return "$a\_$b";
  }

  readLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(Helper.sharedPrefUserName) ?? '';
    if (username.isNotEmpty) {
      currentUserID = username;
      _getUserFromDB(username);
    }
    return username;
  }

  void _sendMessage() {
    if (_textMessageController.text.isNotEmpty && groupId.isNotEmpty && currentUserID.isNotEmpty && peerUser.userName != 'n/a') {
      final _message = Message(
          messageContent: _textMessageController.text.trim(),
          messageType: "sender",
          senderId: currentUserID,
          receiverId: peerUser.userName,
          sentDate: DateTime.now());
      widget._messageDbHelper.saveMessage(_message, groupId);
      _textMessageController.clear();
      setState(() {});
    }
  }

  void _searchRandomUser(User user) async {

    User? randomUser = await widget.userDbHelper.getRandomUser(user);

    if (randomUser!.userName != 'n/a') {
      // update the user status online
      this.user.chattingWith = randomUser.userName;
      updateUserStatus('busy', randomUser.userName);
      updatePeerUserStatus(randomUser.userName, 'busy', this.user.userName);
      connected = true;
      loadingStatus = 'Random User Found';
      peerUser = randomUser;
      groupId = createGroupId(this.user.userName, this.user.chattingWith);
      setState(() {});
    } else {
      setState(() {
        loadingStatus = 'Searching for fellow Guppi';
      });
    }
  }

  void getPeerUser(peerUserName) async {
    // get the peer user from DB
    final peer = await widget.userDbHelper.getUserInfo(peerUserName);
    if (peer != null) {
      peerUser = peer as User;
      setState(() {
      });
    }
  }

  void _getUserFromDB(String username) async {
    // Start listening to the User Status Changes
    _dbRef.child(username).onValue.listen((event) {
      var snapShot = event.snapshot;
      if (snapShot.value != null) {
        user = User.fromJSON(snapShot.value);
        if (user.chatHistory.isNotEmpty) {
          loadingStatus = 'Other User Disconnected';
          connected = false;
        }
        else if (user.userName.isNotEmpty && user.chattingWith.isNotEmpty) {
          getPeerUser(user.chattingWith);
          groupId = createGroupId(user.userName, user.chattingWith);
          connected = true;
        }
        setState(() {});
        if (user.userName.isNotEmpty &&
            user.status == 'online' &&
            user.chattingWith.isEmpty) {
          // start searching for random User
          _searchRandomUser(user);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.reference().child('Users');
    // Getting the username Saved Locally
    readLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          flexibleSpace: this.currentUserID.isEmpty
              ? SafeArea(child: Container())
              : SafeArea(
                  child: connected ? Container(
                    margin: EdgeInsets.only(bottom: 12.0, top: 1),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 18,
                          child: Center(
                            child: Text('${peerUser.userName[0]}'),
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                user.chattingWith,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                connected ? 'Online' : 'Offline',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(icon: const Icon(Icons.logout, size: 28, color: Colors.black54,),
                            onPressed: _handleSignOut),
                        )
                      ],
                    ),
                  ) : Container(),
                ),
        ),
        body: this.currentUserID.isEmpty
            ? Center(
                child: Text('Please Set the Username.'),
              )
            : connected
                ? Container(
                    child: Stack(
                      children: <Widget>[
                        FirebaseAnimatedList(
                          controller: _scrollerController,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          physics: BouncingScrollPhysics(),
                          query: widget._messageDbHelper
                              .getGroupMessageQuery(groupId),
                          itemBuilder: (context, DataSnapshot snapshot,
                              animation, index) {
                            if (snapshot.value != null) {
                              final _jsonValue = snapshot.value;
                              final _newMessage = Message.fromJSON(_jsonValue);
                              return Container(
                                  padding: EdgeInsets.only(
                                      left: 14, right: 14, top: 5, bottom: 5),
                                  child: Align(
                                      alignment:
                                          (_newMessage.senderId == currentUserID
                                              ? Alignment.topRight
                                              : Alignment.topLeft),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: (_newMessage.senderId ==
                                                  currentUserID
                                              ? Colors.purple[200]
                                              : Colors.grey.shade200),
                                        ),
                                        padding: EdgeInsets.all(13),
                                        child: Text(
                                          _newMessage.messageContent,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      )));
                            } else {
                              return Center(
                                child: Text('Start chatting...'),
                              );
                            }
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding:
                                EdgeInsets.only(left: 0, bottom: 10, top: 10),
                            height: 60,
                            width: double.infinity,
                            color: Colors.white,
                            child: Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {},
                                  child: FloatingActionButton(
                                    // height: 30,
                                    // width: 30,
                                    // decoration: BoxDecoration(
                                    //   color: Colors.purple,
                                    //   borderRadius: BorderRadius.circular(30),
                                    // ),
                                    onPressed: () {
                                      // Close the KeyBoard
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                    child: Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    backgroundColor: Colors.blue,
                                    elevation: 5,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _textMessageController,
                                    decoration: InputDecoration(
                                        hintText: "Write message...",
                                        hintStyle:
                                            TextStyle(color: Colors.black54),
                                        border: InputBorder.none),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                FloatingActionButton(
                                  onPressed: _sendMessage,
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  backgroundColor: Colors.blue,
                                  elevation: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Container(
                      height: 300,
                      width: 300,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(strokeWidth: 3.0),
                          SizedBox(width: 6.0,),
                          Text('$loadingStatus'),
                        ],
                      ),
                    ),
                  ));
  }

  @override
  void dispose() {
    super.dispose();
    _textMessageController.dispose();
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
                    // update current and peer user to Online and clear the chattingWith
                    if (connected) {
                      updateUserStatus('online', '');
                      updatePeerUserStatus(peerUser.userName, 'online', '');
                    }
                    // Delete the messages and the user
                    setState(() {
                      connected = false;
                      groupId = '';
                    });
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }

  Future<void> openChatDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext cxt) {
          return AlertDialog(
            title: const Text("Do you want to chat?"),
            content: Text('Random User has been matched!'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    // if they agree: Change the state, update the user status to busy and mark the chattingWith to the random user username
                    updateUserStatus('busy', peerUser.userName);
                    setState(() {
                      connected = false;
                    });
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    // if they disAgree: Change the state, update the user status to online and clear the chattingWith to blank
                    updateUserStatus('online', '');
                    setState(() {
                      connected = true;
                    });
                    exit(0);
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }

  void updateUserStatus(status, peerId) {
    // Updates current user
    widget.userDbHelper
        .updateUser(new User(this.currentUserID, status, peerId, ''));
  }

  void updatePeerUserStatus(peerId, status, userId) {
    // Updates current user
    widget.userDbHelper.updateUser(new User(peerId, status, userId, ''));
  }

  void _handleSignOut() {
    // Updates current user
    widget.userDbHelper
        .updateUser(new User(this.currentUserID, 'online', '', peerUser.userName));
    // Updates peer user
    widget.userDbHelper.updateUser(new User(peerUser.userName, 'online', '', currentUserID));
    widget._messageDbHelper.deleteAllMessages(groupId);
    Helper.deleteGroupIdLocally();
    peerUser = User('n/a', 'Not Connected', '', '');
    setState(() {
      connected = false;
      groupId = '';
    });
  }
}
