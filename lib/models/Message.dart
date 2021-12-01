class Message {
  String messageContent;
  String messageType;
  String senderId;
  String receiverId;
  DateTime sentDate;

  Message({required this.messageContent, required this.messageType, required this.senderId, required this.receiverId, required this.sentDate});

  // To Convert JSON to Message Object
  Message.fromJSON(Map<dynamic, dynamic> json)
    : messageContent = json['messageContent'] as String,
      messageType = json['messageType'] as String,
      senderId = json['senderId'] as String,
      receiverId = json['receiverId'] as String,
      sentDate = DateTime.parse(json['sentDate'] as String);

  // To Convert Message Object to JSON
  Map<dynamic, dynamic> toJSON() => <dynamic, dynamic> {
    'messageContent': messageContent,
    'messageType': messageType,
    'senderId': senderId,
    'receiverId': receiverId,
    'sentDate': sentDate.toString()
  };
}
