class User {
  String _userName;
  String _status;
  String _chattingWith;
  String _chatHistory;

  // Constructor to create new User Object
  User(this._userName, this._status, this._chattingWith, this._chatHistory);

  set chattingWith(String value) {
    _chattingWith = value;
  }

  set status(String value) {
    _status = value;
  }

  set userName(String value) {
    _userName = value;
  }

  set chatHistory(String value) {
    _chatHistory = value;
  }

  String get chattingWith {
    return _chattingWith;
  }

  String get status => _status;

  String get userName => _userName;

  String get chatHistory => _chatHistory;

  // Convert JSON to USER Object
  User.fromJSON(Map<dynamic, dynamic> json)
      : _userName = json['userName'] as String,
        _status = json['status'] as String,
        _chattingWith = json['chattingWith'] as String,
        _chatHistory = json['chatHistory'] as String;

  // From USER Object to JSON
  Map<dynamic, dynamic> toJSON() => <dynamic, dynamic> {
    'userName': _userName,
    'status': _status,
    'chattingWith': _chattingWith,
    'chatHistory': _chatHistory
  };

  @override
  String toString() {
    return 'User{_userName: $_userName, _status: $_status, _chattingWith: $_chattingWith}';
  }
}