import 'package:flutter/foundation.dart';
import '../services/mock_data.dart';

class ViewAllGroupsViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> groups = [];
  bool isLoading = true;

  ViewAllGroupsViewModel() {
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading = true;
    notifyListeners();
    
    groups = await MockDataManager().getCommandGroup();
    
    isLoading = false;
    notifyListeners();
  }
}
