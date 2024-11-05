class UserIdManager {
  static String? _userId;

  static String? get userId => _userId;

  static void setUserId(String id) {
    _userId = id;
  }

  String? getUserId() {
    print('ID del usuario: $_userId');
    return _userId;
  }
}
