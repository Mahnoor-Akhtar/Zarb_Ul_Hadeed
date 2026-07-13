import 'package:flutter/foundation.dart';
import '../services/mock_data.dart';

/// ViewModel for the Manage Attributes screen.
/// Manages trades, ranks, and batteries lists with full CRUD.
/// Extracted from _ManageAttributesScreenState in manage_attributes_screen.dart.
class ManageAttributesViewModel extends ChangeNotifier {
  List<String> trades = [];
  List<String> ranks = [];
  List<String> batteries = [];
  bool isLoading = true;

  ManageAttributesViewModel() {
    loadAttributes();
  }

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadAttributes() async {
    isLoading = true;
    notifyListeners();

    trades = await MockDataManager().getTrades();
    ranks = await MockDataManager().getRanks();
    batteries = await MockDataManager().getBatteries();

    isLoading = false;
    notifyListeners();
  }

  // ── Save helpers ─────────────────────────────────────────────────────────

  Future<void> _saveTrades() async => MockDataManager().saveTrades(trades);
  Future<void> _saveRanks() async => MockDataManager().saveRanks(ranks);
  Future<void> _saveBatteries() async =>
      MockDataManager().saveBatteries(batteries);

  // ── Trade CRUD ───────────────────────────────────────────────────────────

  Future<void> addTrade(String value) async {
    trades.add(value);
    notifyListeners();
    await _saveTrades();
  }

  Future<void> editTrade(int index, String value) async {
    trades[index] = value;
    notifyListeners();
    await _saveTrades();
  }

  Future<void> deleteTrade(int index) async {
    trades.removeAt(index);
    notifyListeners();
    await _saveTrades();
  }

  // ── Rank CRUD ────────────────────────────────────────────────────────────

  Future<void> addRank({
    required String value,
    required String selectedType,
    String? selectedParent,
  }) async {
    final formattedVal = selectedType == 'Category' ? value : '  $value';

    if (selectedType == 'Category') {
      ranks.add(formattedVal);
    } else {
      if (selectedParent != null) {
        int insertIdx = ranks.indexOf(selectedParent);
        if (insertIdx != -1) {
          int i = insertIdx + 1;
          while (i < ranks.length && ranks[i].startsWith(' ')) {
            i++;
          }
          ranks.insert(i, formattedVal);
        } else {
          ranks.add(formattedVal);
        }
      } else {
        ranks.add(formattedVal);
      }
    }
    notifyListeners();
    await _saveRanks();
  }

  Future<void> editRank({
    required int index,
    required String value,
    required String selectedType,
    String? selectedParent,
  }) async {
    ranks.removeAt(index);

    final formattedVal = selectedType == 'Category' ? value : '  $value';

    if (selectedType == 'Category') {
      if (index < ranks.length) {
        ranks.insert(index, formattedVal);
      } else {
        ranks.add(formattedVal);
      }
    } else {
      if (selectedParent != null) {
        int insertIdx = ranks.indexOf(selectedParent);
        if (insertIdx != -1) {
          int i = insertIdx + 1;
          while (i < ranks.length && ranks[i].startsWith(' ')) {
            i++;
          }
          ranks.insert(i, formattedVal);
        } else {
          ranks.add(formattedVal);
        }
      } else {
        ranks.add(formattedVal);
      }
    }
    notifyListeners();
    await _saveRanks();
  }

  Future<void> deleteRank(int index) async {
    ranks.removeAt(index);
    notifyListeners();
    await _saveRanks();
  }

  // ── Battery CRUD ─────────────────────────────────────────────────────────

  Future<void> addBattery(String value) async {
    batteries.add(value);
    notifyListeners();
    await _saveBatteries();
  }

  Future<void> editBattery(int index, String value) async {
    batteries[index] = value;
    notifyListeners();
    await _saveBatteries();
  }

  Future<void> deleteBattery(int index) async {
    batteries.removeAt(index);
    notifyListeners();
    await _saveBatteries();
  }
}
