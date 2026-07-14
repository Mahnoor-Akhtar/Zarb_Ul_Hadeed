import 'package:flutter/foundation.dart';
import '../services/personnel_data_manager.dart';

/// ViewModel for the Edit Assignment screen.
/// Manages category/subcategory/sub-subcategory selection and date state.
/// Extracted from _EditAssignmentScreenState in edit_assignment_screen.dart.
class EditAssignmentViewModel extends ChangeNotifier {
  final PersonnelDataManager _dataManager = PersonnelDataManager();
  final Map<String, String> person;

  late String _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSubSubcategory;
  late DateTime _startDate;
  DateTime? _endDate;
  String? _destination;

  List<String> _categories = [];
  List<String> _subcategories = [];
  List<String> _subSubcategories = [];

  // ── Getters ─────────────────────────────────────────────────────────────

  String get selectedCategory => _selectedCategory;
  String? get selectedSubcategory => _selectedSubcategory;
  String? get selectedSubSubcategory => _selectedSubSubcategory;
  DateTime get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get destination => _destination;
  List<String> get categories => _categories;
  List<String> get subcategories => _subcategories;
  List<String> get subSubcategories => _subSubcategories;

  // ── Constructor ──────────────────────────────────────────────────────────

  EditAssignmentViewModel({required this.person}) {
    _init();
  }

  void _init() {
    final armyNo = person['armyNo'] ?? '';
    final currentStatus = _dataManager.getStatus(armyNo);

    _selectedCategory = currentStatus.category;
    _selectedSubcategory = currentStatus.subcategory;
    _selectedSubSubcategory = currentStatus.subSubcategory;
    _destination = currentStatus.destination;

    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    final initialEndDate = currentStatus.endDate;
    _endDate = initialEndDate != null
        ? DateTime(initialEndDate.year, initialEndDate.month, initialEndDate.day)
        : null;

    _categories = _dataManager.categoryHierarchy.keys.toList();
    _updateDropdownLists(initial: true);
  }

  // ── Dropdown list management ─────────────────────────────────────────────

  void _updateDropdownLists({bool initial = false}) {
    final categoryData = _dataManager.categoryHierarchy[_selectedCategory];

    if (categoryData == null) {
      _subcategories = [];
      if (!initial) {
        _selectedSubcategory = null;
        _selectedSubSubcategory = null;
      }
      _subSubcategories = [];
    } else if (categoryData is List<String>) {
      _subcategories = categoryData;
      if (!initial ||
          (_selectedSubcategory != null &&
              !_subcategories.contains(_selectedSubcategory))) {
        _selectedSubcategory = _subcategories.first;
        _selectedSubSubcategory = null;
      }
      _subSubcategories = [];
    } else if (categoryData is Map<String, List<String>>) {
      _subcategories = categoryData.keys.toList();
      if (!initial ||
          (_selectedSubcategory != null &&
              !_subcategories.contains(_selectedSubcategory))) {
        _selectedSubcategory = _subcategories.first;
      }
      final subSubData = categoryData[_selectedSubcategory];
      if (subSubData != null) {
        _subSubcategories = subSubData;
        if (!initial ||
            (_selectedSubSubcategory != null &&
                !_subSubcategories.contains(_selectedSubSubcategory))) {
          _selectedSubSubcategory = _subSubcategories.first;
        }
      } else {
        _subSubcategories = [];
        _selectedSubSubcategory = null;
      }
    }
  }

  // ── Setters ──────────────────────────────────────────────────────────────

  void setCategory(String category) {
    _selectedCategory = category;
    _updateDropdownLists();
    notifyListeners();
  }

  void setSubcategory(String subcategory) {
    _selectedSubcategory = subcategory;
    _updateDropdownLists();
    notifyListeners();
  }

  void setSubSubcategory(String subSubcategory) {
    _selectedSubSubcategory = subSubcategory;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    if (_endDate != null && _endDate!.isBefore(_startDate)) {
      _endDate = _startDate.add(const Duration(days: 7));
    }
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  void setDestination(String? destination) {
    _destination = destination;
    notifyListeners();
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  void saveAssignment() {
    final armyNo = person['armyNo'] ?? '';
    final newStatus = PersonStatus(
      category: _selectedCategory,
      subcategory: _selectedSubcategory,
      subSubcategory: _selectedSubSubcategory,
      startDate: _startDate,
      endDate: _endDate,
      destination: _destination,
    );
    _dataManager.updateStatus(armyNo, newStatus);
  }

  // ── Utility ──────────────────────────────────────────────────────────────

  String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}
