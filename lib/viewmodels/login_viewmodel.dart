import 'package:flutter/foundation.dart';
import '../services/mock_data.dart';

/// ViewModel for the login screen.
/// Extracts authentication logic from _LoginScreenState._handleLogin().
class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Attempts to log in with [username] and [password].
  /// Returns an error message string on failure, or null on success.
  /// On success also calls [MockDataManager().login()] to set session state.
  Future<String?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return 'Please enter both username and password.';
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final usernameLower = username.toLowerCase();
      final group = await MockDataManager().getCommandGroup();

      Map? matchedSlot;
      for (var slot in group) {
        if (slot['armyNo'] != null) {
          final accUsername = (slot['username'] as String).toLowerCase();
          if (accUsername == usernameLower) {
            matchedSlot = slot;
            break;
          }
        }
      }

      if (matchedSlot == null) {
        _isLoading = false;
        notifyListeners();
        return 'User "$username" is not registered in the command group.';
      }

      final accPassword = matchedSlot['password'] as String;
      if (password != accPassword) {
        _isLoading = false;
        notifyListeners();
        return 'Incorrect password.';
      }

      final slotRole = matchedSlot['role'] as String;
      String role;
      if (slotRole == 'superadmin') {
        role = 'Administrator';
      } else if (slotRole == 'admin') {
        role = 'Data Entry';
      } else {
        role = 'View-Only';
      }
      final adminArmyNo = matchedSlot['armyNo'] as String;

      MockDataManager().login(username, role, adminArmyNo: adminArmyNo);

      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
