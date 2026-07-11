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

  Future<List<Map<String, dynamic>>> getCommandGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('commandGroup');
    if (str != null) {
      try {
        final List decoded = jsonDecode(str);
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        // Fallback
      }
    }
    
    // Initialize default group of 12 members
    final List<Map<String, dynamic>> defaultGroup = [];
    defaultGroup.add({"slotId": 1, "role": "superadmin", "armyNo": null, "username": "", "password": ""});
    for (int i = 2; i <= 5; i++) {
      defaultGroup.add({"slotId": i, "role": "admin", "armyNo": null, "username": "", "password": ""});
    }
    for (int i = 6; i <= 12; i++) {
      defaultGroup.add({"slotId": i, "role": "user", "armyNo": null, "username": "", "password": ""});
    }
    
    await saveCommandGroup(defaultGroup);
    return defaultGroup;
  }

  Future<void> saveCommandGroup(List<Map<String, dynamic>> group) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('commandGroup', jsonEncode(group));
  }

  Future<void> assignSlot(int slotId, String armyNo, String username, String password) async {
    final group = await getCommandGroup();
    for (var slot in group) {
      if (slot['slotId'] == slotId) {
        slot['armyNo'] = armyNo;
        slot['username'] = username.trim();
        slot['password'] = password;
        break;
      }
    }
    await saveCommandGroup(group);
  }

  Future<void> clearSlot(int slotId) async {
    final group = await getCommandGroup();
    for (var slot in group) {
      if (slot['slotId'] == slotId) {
        slot['armyNo'] = null;
        slot['username'] = "";
        slot['password'] = "";
        break;
      }
    }
    await saveCommandGroup(group);
  }

  Future<void> updateCredentials(String armyNo, String username, String password) async {
    final group = await getCommandGroup();
    for (var slot in group) {
      if (slot['armyNo'] == armyNo) {
        slot['username'] = username.trim();
        slot['password'] = password;
        break;
      }
    }
    await saveCommandGroup(group);
  }

  // Deprecated backward compatibility methods
  Future<Map<String, dynamic>> getAdminAccounts() async {
    final group = await getCommandGroup();
    final Map<String, dynamic> result = {};
    for (var slot in group) {
      if (slot['armyNo'] != null) {
        result[slot['armyNo'] as String] = {
          'username': slot['username'],
          'password': slot['password'],
        };
      }
    }
    return result;
  }

  Future<List<String>> getAdminArmyNos() async {
    final group = await getCommandGroup();
    return group
        .where((s) => s['armyNo'] != null)
        .map((s) => s['armyNo'] as String)
        .toList();
  }

  Future<List<String>> getAdmins() async {
    final group = await getCommandGroup();
    return group
        .where((s) => s['armyNo'] != null)
        .map((s) => s['username'].toString().toLowerCase())
        .toList();
  }
}