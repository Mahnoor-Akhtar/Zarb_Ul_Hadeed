import 'package:shared_preferences/shared_preferences.dart';

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

  Future<List<String>> getAdmins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('customAdmins') ?? [];
  }

  Future<void> addAdmin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('customAdmins') ?? [];
    final usernameLower = username.trim().toLowerCase();
    if (!list.contains(usernameLower)) {
      list.add(usernameLower);
      await prefs.setStringList('customAdmins', list);
    }
  }

  Future<void> removeAdmin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('customAdmins') ?? [];
    final usernameLower = username.trim().toLowerCase();
    if (list.contains(usernameLower)) {
      list.remove(usernameLower);
      await prefs.setStringList('customAdmins', list);
    }
  }

  String? get username => _username;
  String? get role => _role;
  bool get isLoggedIn => _isLoggedIn;
}
