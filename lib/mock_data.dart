class MockDataManager {
  static final MockDataManager _instance = MockDataManager._internal();

  factory MockDataManager() {
    return _instance;
  }

  MockDataManager._internal();

  String? _username;
  String? _role;
  bool _isLoggedIn = false;

  void login(String username, String role) {
    _username = username;
    _role = role;
    _isLoggedIn = true;
  }

  void logout() {
    _username = null;
    _role = null;
    _isLoggedIn = false;
  }

  String? get username => _username;
  String? get role => _role;
  bool get isLoggedIn => _isLoggedIn;
}
