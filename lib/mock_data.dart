import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MockDataManager {
  static final MockDataManager _instance = MockDataManager._internal();

  factory MockDataManager() {
    return _instance;
  }

  MockDataManager._internal();

  String? _username;
  String? _role;
  String? _adminArmyNo;
  bool _isLoggedIn = false;

  void login(String username, String role, {String? adminArmyNo}) {
    _username = username;
    _role = role;
    _adminArmyNo = adminArmyNo;
    _isLoggedIn = true;
  }

  void logout() {
    _username = null;
    _role = null;
    _adminArmyNo = null;
    _isLoggedIn = false;
  }

  String? get username => _username;
  String? get role => _role;
  String? get adminArmyNo => _adminArmyNo;
  bool get isLoggedIn => _isLoggedIn;

  Future<Map<String, dynamic>> getAdminAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('customAdminAccounts');
    if (str == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(str));
    } catch (e) {
      return {};
    }
  }

  Future<void> saveAdminAccounts(Map<String, dynamic> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customAdminAccounts', jsonEncode(accounts));
  }

  Future<void> saveAdmin(String armyNo, String username, String password) async {
    final accounts = await getAdminAccounts();
    accounts[armyNo] = {
      'username': username.trim(),
      'password': password,
    };
    await saveAdminAccounts(accounts);
  }

  Future<void> removeAdmin(String armyNo) async {
    final accounts = await getAdminAccounts();
    accounts.remove(armyNo);
    await saveAdminAccounts(accounts);
  }

  Future<List<String>> getAdminArmyNos() async {
    final accounts = await getAdminAccounts();
    return accounts.keys.toList();
  }

  // Deprecated list getter for compatibility
  Future<List<String>> getAdmins() async {
    final accounts = await getAdminAccounts();
    return accounts.values.map((v) => (v as Map)['username'].toString().toLowerCase()).toList();
  }
}