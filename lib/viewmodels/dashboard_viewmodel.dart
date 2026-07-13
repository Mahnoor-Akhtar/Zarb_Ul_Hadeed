import 'package:flutter/foundation.dart';
import '../services/mock_data.dart';

/// ViewModel for the main dashboard: controls tab index, parade-state
/// search, expanded sections, FAB state, roll edit/delete mode, and
/// dynamically loaded attribute lists.
/// Extracted from _DashboardScreenState in dashboard_screen.dart.
class DashboardViewModel extends ChangeNotifier {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  final Set<String> _expandedSections = {};
  bool _isFabMenuOpen = false;
  bool _isRollFabMenuOpen = false;
  bool _isRollEditMode = false;
  bool _isRollDeleteMode = false;

  // Dynamic attribute lists — defaults match dashboard_screen.dart hard-coded fallbacks
  List<String> _tradesList = [
    'All', 'Gnr', 'TA', 'OCU', 'DMT', 'DSV', 'Svy',
    'Clk', 'Ck', 'Engr', 'N/A', 'LAD', 'NCB', 'S/W', 'Civ',
  ];
  List<String> _ranksList = [
    'All', 'Officers', '  Lt Col', '  Maj', '  Capt', '  Lt', '  2/Lt',
    'JCOs', '  SM', '  Sub', '  N/Sub',
    'Soldiers', '  Hav', '  Lhav', '  Nk', '  Lnk', '  Sep',
  ];
  List<String> _batteriesList = ['All', 'HQ Bty', 'P Bty', 'Q Bty', 'R Bty'];

  // ── Getters ─────────────────────────────────────────────────────────────

  int get selectedTabIndex => _selectedTabIndex;
  String get searchQuery => _searchQuery;
  Set<String> get expandedSections => _expandedSections;
  bool get isFabMenuOpen => _isFabMenuOpen;
  bool get isRollFabMenuOpen => _isRollFabMenuOpen;
  bool get isRollEditMode => _isRollEditMode;
  bool get isRollDeleteMode => _isRollDeleteMode;
  List<String> get tradesList => _tradesList;
  List<String> get ranksList => _ranksList;
  List<String> get batteriesList => _batteriesList;

  bool get canAccessEditTab {
    final role = MockDataManager().role;
    return role == 'Administrator' || role == 'Data Entry';
  }

  bool get canAccessFABs => MockDataManager().role == 'Administrator';

  // ── Initialisation ───────────────────────────────────────────────────────

  DashboardViewModel() {
    loadDynamicAttributes();
  }

  Future<void> loadDynamicAttributes() async {
    final trades = await MockDataManager().getTrades();
    final ranks = await MockDataManager().getRanks();
    final batteries = await MockDataManager().getBatteries();
    _tradesList = trades;
    _ranksList = ranks;
    _batteriesList = batteries;
    notifyListeners();
  }

  // ── Setters / Actions ────────────────────────────────────────────────────

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSection(String sectionName) {
    if (_expandedSections.contains(sectionName)) {
      _expandedSections.remove(sectionName);
    } else {
      _expandedSections.add(sectionName);
    }
    notifyListeners();
  }

  bool isSectionExpanded(String sectionName) =>
      _expandedSections.contains(sectionName);

  void setFabMenuOpen(bool open) {
    _isFabMenuOpen = open;
    notifyListeners();
  }

  void setRollFabMenuOpen(bool open) {
    _isRollFabMenuOpen = open;
    notifyListeners();
  }

  void setRollEditMode(bool enabled) {
    _isRollEditMode = enabled;
    if (enabled) _isRollDeleteMode = false;
    notifyListeners();
  }

  void setRollDeleteMode(bool enabled) {
    _isRollDeleteMode = enabled;
    if (enabled) _isRollEditMode = false;
    notifyListeners();
  }

  void refreshAttributes() {
    loadDynamicAttributes();
  }
}
