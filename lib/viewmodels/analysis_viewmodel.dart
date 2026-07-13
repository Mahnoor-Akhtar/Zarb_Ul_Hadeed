import 'package:flutter/foundation.dart';

/// ViewModel for the Analysis tab.
/// Manages analysis mode selection and analysis filter state.
/// Extracted from _DashboardScreenState in dashboard_screen.dart.
class AnalysisViewModel extends ChangeNotifier {
  String _analysisMode = 'Rank'; // Default to Rank Analysis
  String _analysisFilterBattery = 'All';
  String _analysisFilterTrade = 'All';
  String _analysisFilterRank = 'All';

  // ── Getters ─────────────────────────────────────────────────────────────

  String get analysisMode => _analysisMode;
  String get analysisFilterBattery => _analysisFilterBattery;
  String get analysisFilterTrade => _analysisFilterTrade;
  String get analysisFilterRank => _analysisFilterRank;

  // ── Setters ──────────────────────────────────────────────────────────────

  void setAnalysisMode(String mode) {
    _analysisMode = mode;
    notifyListeners();
  }

  void setAnalysisFilterBattery(String battery) {
    _analysisFilterBattery = battery;
    notifyListeners();
  }

  void setAnalysisFilterTrade(String trade) {
    _analysisFilterTrade = trade;
    notifyListeners();
  }

  void setAnalysisFilterRank(String rank) {
    _analysisFilterRank = rank;
    notifyListeners();
  }

  void resetFilters() {
    _analysisFilterBattery = 'All';
    _analysisFilterTrade = 'All';
    _analysisFilterRank = 'All';
    notifyListeners();
  }
}
