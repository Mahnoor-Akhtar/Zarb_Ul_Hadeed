import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'personnel_data.dart';
import '../models/person_status.dart';
export '../models/person_status.dart'; // Re-export so existing imports of personnel_data_manager.dart still resolve PersonStatus


class PersonnelDataManager {
  static final PersonnelDataManager _instance = PersonnelDataManager._internal();

  factory PersonnelDataManager() {
    return _instance;
  }

  PersonnelDataManager._internal();

  late SharedPreferences _prefs;
  final Map<String, PersonStatus> _statuses = {};
  final Map<String, List<PersonStatus>> _history = {};
  bool _isInitialized = false;

  void init(SharedPreferences prefs) {
    if (_isInitialized) return;
    _prefs = prefs;
    _loadFromPrefs();
    _isInitialized = true;
  }

  void _loadFromPrefs() {
    // 1. load categoryHierarchy
    final catStr = _prefs.getString('categoryHierarchy');
    if (catStr != null) {
      try {
        categoryHierarchy = Map<String, dynamic>.from(jsonDecode(catStr));
      } catch (e) {
        _useDefaultCategories();
      }
    } else {
      _useDefaultCategories();
    }

    // 2. load nominalRollList
    final rollStr = _prefs.getString('nominalRollList');
    if (rollStr != null) {
      try {
        final decoded = jsonDecode(rollStr) as List;
        nominalRollList.clear();
        nominalRollList.addAll(decoded.map((p) => Map<String, String>.from(p as Map)));
      } catch (e) {
        // use default from file
      }
    }

    // 3. load _statuses and _history
    final statusesStr = _prefs.getString('personnelStatuses');
    final historyStr = _prefs.getString('personnelHistory');
    
    if (statusesStr != null) {
      try {
        final decoded = jsonDecode(statusesStr) as Map;
        _statuses.clear();
        decoded.forEach((key, value) {
          _statuses[key as String] = PersonStatus.fromJson(Map<String, dynamic>.from(value as Map));
        });
      } catch (e) {
        _initializeStatuses();
      }
    } else {
      _initializeStatuses();
    }

    if (historyStr != null) {
      try {
        final decoded = jsonDecode(historyStr) as Map;
        _history.clear();
        decoded.forEach((key, value) {
          final list = value as List;
          _history[key as String] = list.map((item) => PersonStatus.fromJson(Map<String, dynamic>.from(item as Map))).toList();
        });
      } catch (e) {
        _initializeHistory();
      }
    } else {
      _initializeHistory();
    }
  }

  void saveToPrefs() {
    _prefs.setString('categoryHierarchy', jsonEncode(categoryHierarchy));
    _prefs.setString('nominalRollList', jsonEncode(nominalRollList));
    
    final Map<String, dynamic> jsonStatuses = {};
    _statuses.forEach((key, value) {
      jsonStatuses[key] = value.toJson();
    });
    _prefs.setString('personnelStatuses', jsonEncode(jsonStatuses));

    final Map<String, dynamic> jsonHistory = {};
    _history.forEach((key, value) {
      jsonHistory[key] = value.map((status) => status.toJson()).toList();
    });
    _prefs.setString('personnelHistory', jsonEncode(jsonHistory));
  }

  void _useDefaultCategories() {
    categoryHierarchy = {
      'Present': ['Duty', 'Standby', 'Office'],
      'Leave': ['P/Lve', 'C/Lve', 'Weekend', 'Sick Lve'],
      'Aval': ['Leave Reserve', 'General Aval', 'Other'],
      'Att': {
        'Perm Comd': ['Arms Br', 'Army Camp', 'PMA', '3 Trg/ASL Muree', 'UN Msn', 'COAS Dte', '52 RSTE'],
        'Temp': ['9 Div', '30 CAB', '30 Corps', 'Arty Cen', '325 CIB', 'Arms Br'],
      },
      'Courses': ['JSC/ MCC/OGS', 'PRT Course', 'ARI(TA)', 'ARI(G)', 'SNBIC', 'SCC Screening', 'JNAC'],
      'OSL/Pris': ['OSL', 'Regt Prisoner', 'Detained'],
      'Sta Gds': ['ISI Sub Sec Gd', 'COM Gd', 'FG Deg Gd', 'PRO Sec', 'GMP', 'Ammo Gd'],
      'Unit Gds': ['MT', '158 Line', 'POL', '148 SP', 'Stores', 'Office', 'Guns', 'Prisoner'],
      'CMH/Sick': ['CMH Gwa', 'SIQ', 'CMH Kht'],
      'Regt Emp': ['RP', 'Ck House', 'Adm/Emg/CO Veh', 'DR', 'Rnrs', 'Orderly/ Daily NCO', 'Complain NCO', 'Tea Bar NCO', 'Store Man'],
      'Trg': ['Observer', 'Guns'],
      'Sports': ['Rugby', 'Volleyball'],
      'Aslt Course': ['Obstacle Trg', 'Physical Test', 'General Aslt'],
      'DIDO': ['Waiters', 'Managers'],
      'Working': ['Area Maint', 'Weapon Maint'],
      'Prot': ['Chinese Team', 'Players Pot'],
      'Ex/Cl': ['Extra Class', 'Remedial Class', 'Other'],
      'U/D': ['Under Displ', 'Inquiry', 'Other'],
    };
  }

  Map<String, dynamic> categoryHierarchy = {};

  void _initializeStatuses() {
    for (var person in nominalRollList) {
      final armyNo = person['armyNo'] ?? '';
      final category = _getInitialCategory(armyNo);
      
      String? subcategory;
      String? subSubcategory;
      
      final cleanNo = armyNo.replaceAll(RegExp(r'\D'), '');
      final id = int.tryParse(cleanNo) ?? 0;

      if (category == 'Present') {
        final subs = ['Duty', 'Standby', 'Office'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Leave') {
        final subs = ['P/Lve', 'C/Lve', 'Weekend', 'Sick Lve'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Aval') {
        final subs = ['Leave Reserve', 'General Aval', 'Other'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Att') {
        if (id % 2 == 0) {
          subcategory = 'Perm Comd';
          final subSubs = ['Arms Br', 'Army Camp', 'PMA', '3 Trg/ASL Muree', 'UN Msn', 'COAS Dte', '52 RSTE'];
          subSubcategory = subSubs[id % subSubs.length];
        } else {
          subcategory = 'Temp';
          final subSubs = ['9 Div', '30 CAB', '30 Corps', 'Arty Cen', '325 CIB', 'Arms Br'];
          subSubcategory = subSubs[id % subSubs.length];
        }
      } else if (category == 'Courses') {
        final subs = ['JSC/ MCC/OGS', 'PRT Course', 'ARI(TA)', 'ARI(G)', 'SNBIC', 'SCC Screening', 'JNAC'];
        subcategory = subs[id % subs.length];
      } else if (category == 'OSL/Pris') {
        final subs = ['OSL', 'Regt Prisoner', 'Detained'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Sta Gds') {
        final subs = ['ISI Sub Sec Gd', 'COM Gd', 'FG Deg Gd', 'PRO Sec', 'GMP', 'Ammo Gd'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Unit Gds') {
        final subs = ['MT', '158 Line', 'POL', '148 SP', 'Stores', 'Office', 'Guns', 'Prisoner'];
        subcategory = subs[id % subs.length];
      } else if (category == 'CMH/Sick') {
        final subs = ['CMH Gwa', 'SIQ', 'CMH Kht'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Regt Emp') {
        final subs = ['RP', 'Ck House', 'Adm/Emg/CO Veh', 'DR', 'Rnrs', 'Orderly/ Daily NCO', 'Complain NCO', 'Tea Bar NCO', 'Store Man'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Trg') {
        final subs = ['Observer', 'Guns'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Sports') {
        final subs = ['Rugby', 'Volleyball'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Aslt Course') {
        final subs = ['Obstacle Trg', 'Physical Test', 'General Aslt'];
        subcategory = subs[id % subs.length];
      } else if (category == 'DIDO') {
        final subs = ['Waiters', 'Managers'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Working') {
        final subs = ['Area Maint', 'Weapon Maint'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Prot') {
        final subs = ['Chinese Team', 'Players Pot'];
        subcategory = subs[id % subs.length];
      } else if (category == 'Ex/Cl') {
        final subs = ['Extra Class', 'Remedial Class', 'Other'];
        subcategory = subs[id % subs.length];
      } else if (category == 'U/D') {
        final subs = ['Under Displ', 'Inquiry', 'Other'];
        subcategory = subs[id % subs.length];
      }

      final initStatuses = _generateThreeMonthHistory(armyNo, category, subcategory, subSubcategory);
      _statuses[armyNo] = initStatuses.last;
      _history[armyNo] = initStatuses;
    }
  }

  List<PersonStatus> _generateThreeMonthHistory(
    String armyNo, 
    String currentCategory, 
    String? currentSub, 
    String? currentSubSub
  ) {
    final cleanNo = armyNo.replaceAll(RegExp(r'\D'), '');
    final seed = int.tryParse(cleanNo) ?? 123;
    
    int pseudoRandom(int max, int step) {
      return (seed * step + 7) % max;
    }
    
    final now = DateTime.now();
    final List<PersonStatus> list = [];
    
    final statusOptions = [
      {'category': 'Present', 'sub': 'Duty'},
      {'category': 'Leave', 'sub': 'C/Lve'},
      {'category': 'Present', 'sub': 'Office'},
      {'category': 'Courses', 'sub': 'JNAC'},
      {'category': 'Sta Gds', 'sub': 'COM Gd'},
      {'category': 'CMH/Sick', 'sub': 'SIQ'},
      {'category': 'Regt Emp', 'sub': 'RP'},
    ];
    
    final state1Idx = pseudoRandom(statusOptions.length, 1);
    final state1 = statusOptions[state1Idx];
    list.add(PersonStatus(
      category: state1['category']!,
      subcategory: state1['sub'],
      startDate: now.subtract(const Duration(days: 90)),
      endDate: now.subtract(const Duration(days: 60)),
    ));
    
    final state2Idx = (state1Idx + 2) % statusOptions.length;
    final state2 = statusOptions[state2Idx];
    list.add(PersonStatus(
      category: state2['category']!,
      subcategory: state2['sub'],
      startDate: now.subtract(const Duration(days: 60)),
      endDate: now.subtract(const Duration(days: 30)),
    ));
    
    final state3Idx = (state2Idx + 3) % statusOptions.length;
    final state3 = statusOptions[state3Idx];
    list.add(PersonStatus(
      category: state3['category']!,
      subcategory: state3['sub'],
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now.subtract(const Duration(days: 10)),
    ));
    
    list.add(PersonStatus(
      category: currentCategory,
      subcategory: currentSub,
      subSubcategory: currentSubSub,
      startDate: now.subtract(const Duration(days: 10)),
      endDate: null,
    ));
    
    return list;
  }

  void _initializeHistory() {
    _history.clear();
    _statuses.forEach((armyNo, status) {
      _history[armyNo] = _generateThreeMonthHistory(
        armyNo, 
        status.category, 
        status.subcategory, 
        status.subSubcategory
      );
    });
  }

  String _getInitialCategory(String armyNo) {
    final cleanNo = armyNo.replaceAll(RegExp(r'\D'), '');
    if (cleanNo.isEmpty) return 'Present';
    final id = int.tryParse(cleanNo) ?? 0;

    final statusList = [
      'Present', 'Leave', 'Aval', 'Att', 'Courses', 'OSL/Pris', 
      'Sta Gds', 'Unit Gds', 'CMH/Sick', 'Regt Emp', 'Trg', 'Sports', 
      'Aslt Course', 'DIDO', 'Working', 'Prot', 'Ex/Cl', 'U/D'
    ];
    
    final weights = [83, 85, 83, 33, 47, 47, 33, 48, 5, 30, 22, 22, 3, 22, 22, 22, 33, 33];
    final sum = weights.reduce((a, b) => a + b);
    
    final val = id % sum;
    int currentSum = 0;
    for (int i = 0; i < weights.length; i++) {
      currentSum += weights[i];
      if (val < currentSum) {
        return statusList[i];
      }
    }
    return 'Present';
  }

  PersonStatus getStatus(String armyNo) {
    if (!_statuses.containsKey(armyNo)) {
      _statuses[armyNo] = PersonStatus(
        category: 'Present',
        startDate: DateTime.now(),
        endDate: null,
      );
      saveToPrefs();
    }
    return _statuses[armyNo]!;
  }

  void updateStatus(String armyNo, PersonStatus newStatus) {
    final oldStatus = _statuses[armyNo];
    if (oldStatus != null) {
      final finalOldStatus = PersonStatus(
        category: oldStatus.category,
        subcategory: oldStatus.subcategory,
        subSubcategory: oldStatus.subSubcategory,
        startDate: oldStatus.startDate,
        endDate: newStatus.startDate,
      );

      if (!_history.containsKey(armyNo)) {
        _history[armyNo] = [finalOldStatus];
      } else {
        _history[armyNo]!.removeWhere((s) => s.endDate == null);
        _history[armyNo]!.add(finalOldStatus);
      }
    }

    _statuses[armyNo] = newStatus;

    if (!_history.containsKey(armyNo)) {
      _history[armyNo] = [newStatus];
    } else {
      _history[armyNo]!.removeWhere((s) => s.endDate == null);
      _history[armyNo]!.add(newStatus);
    }
    saveToPrefs();
  }

  List<PersonStatus> getHistory(String armyNo) {
    if (!_history.containsKey(armyNo) || _history[armyNo]!.isEmpty) {
      final current = getStatus(armyNo);
      _history[armyNo] = _generateThreeMonthHistory(
        armyNo, 
        current.category, 
        current.subcategory, 
        current.subSubcategory
      );
      saveToPrefs();
    }
    return _history[armyNo]!;
  }

  List<Map<String, String>> getPeopleInNode({
    required String category,
    String? subcategory,
    String? subSubcategory,
  }) {
    return nominalRollList.where((person) {
      final status = getStatus(person['armyNo'] ?? '');
      if (status.category != category) return false;
      if (subcategory != null && status.subcategory != subcategory) return false;
      if (subSubcategory != null && status.subSubcategory != subSubcategory) return false;
      return true;
    }).toList();
  }

  int getCountForCategory(String categoryName) {
    return nominalRollList.where((p) => getStatus(p['armyNo'] ?? '').category == categoryName).length;
  }

  int getCountForSubcategory(String categoryName, String subcategoryName) {
    return nominalRollList.where((p) {
      final status = getStatus(p['armyNo'] ?? '');
      return status.category == categoryName && status.subcategory == subcategoryName;
    }).length;
  }

  int getCountForSubSubcategory(String categoryName, String subcategoryName, String subSubcategoryName) {
    return nominalRollList.where((p) {
      final status = getStatus(p['armyNo'] ?? '');
      return status.category == categoryName &&
             status.subcategory == subcategoryName &&
             status.subSubcategory == subSubcategoryName;
    }).length;
  }

  void addMainCategory(String name) {
    if (!categoryHierarchy.containsKey(name)) {
      categoryHierarchy[name] = null;
    }
  }

  void addSubcategory(String category, String subcategory) {
    if (!categoryHierarchy.containsKey(category)) return;
    
    final current = categoryHierarchy[category];
    if (current == null) {
      categoryHierarchy[category] = [subcategory];
    } else if (current is List) {
      final list = List<String>.from(current);
      if (!list.contains(subcategory)) {
        list.add(subcategory);
        categoryHierarchy[category] = list;
      }
    } else if (current is Map) {
      final map = Map<String, dynamic>.from(current);
      if (!map.containsKey(subcategory)) {
        map[subcategory] = [];
        categoryHierarchy[category] = map;
        saveToPrefs();
      }
    }
  }

  void addSubSubcategory(String category, String subcategory, String subSubcategory) {
    if (!categoryHierarchy.containsKey(category)) return;
    
    final current = categoryHierarchy[category];
    if (current == null || current is List) {
      final List<String> oldSubs = current == null ? [] : List<String>.from(current as List);
      final Map<String, List<String>> newMap = {};
      for (var sub in oldSubs) {
        newMap[sub] = [];
      }
      if (!newMap.containsKey(subcategory)) {
        newMap[subcategory] = [subSubcategory];
      } else {
        newMap[subcategory]!.add(subSubcategory);
      }
      categoryHierarchy[category] = newMap;
    } else if (current is Map) {
      final map = Map<String, dynamic>.from(current);
      if (!map.containsKey(subcategory)) {
        map[subcategory] = [subSubcategory];
      } else {
        final List<String> list = List<String>.from(map[subcategory] as List);
        if (!list.contains(subSubcategory)) {
          list.add(subSubcategory);
          map[subcategory] = list;
        }
      }
      categoryHierarchy[category] = map;
      saveToPrefs();
    }
  }

  void renameCategory(String oldName, String newName) {
    if (oldName == newName || !categoryHierarchy.containsKey(oldName)) return;
    
    final data = categoryHierarchy.remove(oldName);
    categoryHierarchy[newName] = data;

    for (var key in _statuses.keys) {
      final status = _statuses[key]!;
      if (status.category == oldName) {
        status.category = newName;
      }
    }
  }

  void deleteCategory(String name) {
    if (!categoryHierarchy.containsKey(name)) return;

    categoryHierarchy.remove(name);

    for (var key in _statuses.keys) {
      final status = _statuses[key]!;
      if (status.category == name) {
        status.category = 'Present';
        status.subcategory = null;
        status.subSubcategory = null;
      }
    }
    saveToPrefs();
  }

  void renameSubcategory(String category, String oldSub, String newSub) {
    if (oldSub == newSub || !categoryHierarchy.containsKey(category)) return;

    final current = categoryHierarchy[category];
    if (current is List) {
      final list = List<String>.from(current);
      final idx = list.indexOf(oldSub);
      if (idx != -1) {
        list[idx] = newSub;
        categoryHierarchy[category] = list;
      }
    } else if (current is Map) {
      final map = Map<String, dynamic>.from(current);
      if (map.containsKey(oldSub)) {
        final val = map.remove(oldSub);
        map[newSub] = val;
        categoryHierarchy[category] = map;
      }
    }

    for (var key in _statuses.keys) {
      final status = _statuses[key]!;
      if (status.category == category && status.subcategory == oldSub) {
        status.subcategory = newSub;
      }
    }
  }

  void deleteSubcategory(String category, String subcategory) {
    if (!categoryHierarchy.containsKey(category)) return;

    final current = categoryHierarchy[category];
    if (current is List) {
      final list = List<String>.from(current);
      list.remove(subcategory);
      categoryHierarchy[category] = list.isEmpty ? null : list;
    } else if (current is Map) {
      final map = Map<String, dynamic>.from(current);
      map.remove(subcategory);
      categoryHierarchy[category] = map.isEmpty ? null : map;
    }

    for (var key in _statuses.keys) {
      final status = _statuses[key]!;
      if (status.category == category && status.subcategory == subcategory) {
        status.subcategory = null;
        status.subSubcategory = null;
      }
    }
  }

  void renameSubSubcategory(String category, String subcategory, String oldSubSub, String newSubSub) {
    if (oldSubSub == newSubSub || !categoryHierarchy.containsKey(category)) return;

    final current = categoryHierarchy[category];
    if (current is Map) {
      final map = Map<String, dynamic>.from(current);
      if (map.containsKey(subcategory)) {
        final List<String> list = List<String>.from(map[subcategory] as List);
        final idx = list.indexOf(oldSubSub);
        if (idx != -1) {
          list[idx] = newSubSub;
          map[subcategory] = list;
          categoryHierarchy[category] = map;
        }
      }
    }

    for (var key in _statuses.keys) {
      final status = _statuses[key]!;
      if (status.category == category &&
          status.subcategory == subcategory &&
          status.subSubcategory == oldSubSub) {
        status.subSubcategory = newSubSub;
      }
    }
  }

  void deleteSubSubcategory(String category, String subcategory, String subSubName) {
    if (!categoryHierarchy.containsKey(category)) return;

    final current = categoryHierarchy[category];
    if (current is Map) {
      final map = Map<String, dynamic>.from(current);
      if (map.containsKey(subcategory)) {
        final List<String> list = List<String>.from(map[subcategory] as List);
        list.remove(subSubName);
        map[subcategory] = list;
        categoryHierarchy[category] = map;
      }
    }

    for (var key in _statuses.keys) {
      final status = _statuses[key]!;
      if (status.category == category &&
          status.subcategory == subcategory &&
          status.subSubcategory == subSubName) {
        status.subSubcategory = null;
      }
    }
  }

  void addPerson(Map<String, String> person) {
    final armyNo = person['armyNo'] ?? '';
    if (nominalRollList.any((p) => p['armyNo'] == armyNo)) return;
    nominalRollList.add(person);
    saveToPrefs();
  }

  void editPerson(String oldArmyNo, Map<String, String> updatedPerson) {
    final idx = nominalRollList.indexWhere((p) => p['armyNo'] == oldArmyNo);
    if (idx != -1) {
      nominalRollList[idx] = updatedPerson;
      final newArmyNo = updatedPerson['armyNo'] ?? '';

      if (oldArmyNo != newArmyNo && newArmyNo.isNotEmpty) {
        final status = _statuses.remove(oldArmyNo);
        if (status != null) {
          _statuses[newArmyNo] = status;
        }
        final historyList = _history.remove(oldArmyNo);
        if (historyList != null) {
          _history[newArmyNo] = historyList;
        }
      }

      saveToPrefs();
    }
  }

  void removePerson(String armyNo) {
    nominalRollList.removeWhere((p) => p['armyNo'] == armyNo);
    _statuses.remove(armyNo);
    _history.remove(armyNo);
    saveToPrefs();
  }
}
