// Helper Class to Retrieve & Save Messages
import 'package:firebase_database/firebase_database.dart';
import 'package:roomiez_app/models/Message.dart';

class MessageDbHelper {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.reference().child('Messages');

  void saveMessage(Message msg, groupId) {
    _messagesRef.child(groupId).push().set(msg.toJSON());
  }

  void saveTempMessage(Message msg) {
    _messagesRef.push().set(msg.toJSON());
  }

  // Get Message Query
  Query getMessageQuery() {
    return _messagesRef;
  }

  void deleteAllMessages(String groupId) {
    _messagesRef.child(groupId).remove();
  }

  Query getGroupMessageQuery(String groupId) {
    return _messagesRef.child(groupId);
  }

}

/*
-- DataBase Structure--
   - Users -
     -- userID -- user1_user2
        -- USerObject {username, status, ...}
      -- userID2 --
        -- USerObject {username, status, ...}
   -- Messages --
      -- userID+peerID (groupId) {my side: myId+otherUserId} {other user side: otherUserID+myId}
         -- uniqueId --
            -- MessageObj {messageContent, MessageType, sentDate....}

 */