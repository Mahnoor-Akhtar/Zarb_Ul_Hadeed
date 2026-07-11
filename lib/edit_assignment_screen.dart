import 'package:flutter/material.dart';
import 'personnel_data_manager.dart';

class EditAssignmentScreen extends StatefulWidget {
  final Map<String, String> person;
  final bool isDark;
  final Color textThemeColor;
  final Color silverText;
  final Color goldAccent;
  final Color valueGreenColor;
  final VoidCallback onSaved;

  const EditAssignmentScreen({
    super.key,
    required this.person,
    required this.isDark,
    required this.textThemeColor,
    required this.silverText,
    required this.goldAccent,
    required this.valueGreenColor,
    required this.onSaved,
  });

  @override
  State<EditAssignmentScreen> createState() => _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends State<EditAssignmentScreen> {
  final PersonnelDataManager _dataManager = PersonnelDataManager();

  late String _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSubSubcategory;
  late DateTime _startDate;
  DateTime? _endDate;

  List<String> _categories = [];
  List<String> _subcategories = [];
  List<String> _subSubcategories = [];

  @override
  void initState() {
    super.initState();
    final armyNo = widget.person['armyNo'] ?? '';
    final currentStatus = _dataManager.getStatus(armyNo);

    _selectedCategory = currentStatus.category;
    _selectedSubcategory = currentStatus.subcategory;
    _selectedSubSubcategory = currentStatus.subSubcategory;
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day); // Start date default to today (date only)
    final initialEndDate = currentStatus.endDate;
    _endDate = initialEndDate != null
        ? DateTime(initialEndDate.year, initialEndDate.month, initialEndDate.day)
        : null;

    _categories = _dataManager.categoryHierarchy.keys.toList();
    _updateDropdownLists(initial: true);
  }

  void _updateDropdownLists({bool initial = false}) {
    final categoryData = _dataManager.categoryHierarchy[_selectedCategory];

    if (categoryData == null) {
      // Category has no subcategories
      _subcategories = [];
      if (!initial) {
        _selectedSubcategory = null;
        _selectedSubSubcategory = null;
      }
      _subSubcategories = [];
    } else if (categoryData is List<String>) {
      // Category has subcategories as a list of strings
      _subcategories = categoryData;
      if (!initial || (_selectedSubcategory != null && !_subcategories.contains(_selectedSubcategory))) {
        _selectedSubcategory = _subcategories.first;
        _selectedSubSubcategory = null;
      }
      _subSubcategories = [];
    } else if (categoryData is Map<String, List<String>>) {
      // Category has subcategories and sub-subcategories
      _subcategories = categoryData.keys.toList();
      if (!initial || (_selectedSubcategory != null && !_subcategories.contains(_selectedSubcategory))) {
        _selectedSubcategory = _subcategories.first;
      }

      final subSubData = categoryData[_selectedSubcategory];
      if (subSubData != null) {
        _subSubcategories = subSubData;
        if (!initial || (_selectedSubSubcategory != null && !_subSubcategories.contains(_selectedSubSubcategory))) {
          _selectedSubSubcategory = _subSubcategories.first;
        }
      } else {
        _subSubcategories = [];
        _selectedSubSubcategory = null;
      }
    }
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(today) ? today : _startDate,
      firstDate: today,
      lastDate: DateTime(2030),
      builder: (context, child) => _buildDatePickerTheme(child!),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final initialDate = (_endDate != null && _endDate!.isAfter(_startDate))
        ? _endDate!
        : _startDate.add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
      builder: (context, child) => _buildDatePickerTheme(child!),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Widget _buildDatePickerTheme(Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: widget.goldAccent,
          onPrimary: Colors.black,
          surface: const Color(0xFF0A2214),
          onSurface: Colors.white,
        ),
      ),
      child: child,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  void _saveAssignment() {
    final armyNo = widget.person['armyNo'] ?? '';
    final newStatus = PersonStatus(
      category: _selectedCategory,
      subcategory: _selectedSubcategory,
      subSubcategory: _selectedSubSubcategory,
      startDate: _startDate,
      endDate: _endDate,
    );

    _dataManager.updateStatus(armyNo, newStatus);
    widget.onSaved();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Assignment Updated for ${widget.person['name']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0C5A32),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textThemeColor = widget.textThemeColor;
    final goldAccent = widget.goldAccent;
    final valueGreenColor = widget.valueGreenColor;

    final rank = widget.person['rank'] ?? '';
    final name = widget.person['name'] ?? '';
    final armyNo = widget.person['armyNo'] ?? '';

    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF03140A) : const Color(0xFFE8F5EE),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF03140A).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: goldAccent),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'EDIT PERSONNEL ASSIGNMENT',
            style: TextStyle(
              color: textThemeColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PERSONNEL INFO SUMMARY CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF051C0F), const Color(0xFF0C3D21)]
                        : [Colors.white, const Color(0xFFE8F5EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: goldAccent.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: goldAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: goldAccent.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          rank,
                          style: TextStyle(
                            color: goldAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: textThemeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: valueGreenColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: valueGreenColor.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              armyNo,
                              style: TextStyle(
                                color: valueGreenColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. INPUT FORM CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0C5A32).withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? goldAccent.withValues(alpha: 0.25) : const Color(0xFF0C5A32).withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASSIGNMENT DETAILS',
                      style: TextStyle(
                        color: goldAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Divider(height: 20, thickness: 0.5),

                    // Primary Category
                    _buildFormLabel('Primary Category'),
                    _buildDropdown<String>(
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                            _updateDropdownLists();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Subcategory (if applicable)
                    if (_subcategories.isNotEmpty) ...[
                      _buildFormLabel('Subcategory'),
                      _buildDropdown<String>(
                        value: _selectedSubcategory,
                        items: _subcategories,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSubcategory = val;
                              _updateDropdownLists();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Sub-subcategory (if applicable)
                    if (_subSubcategories.isNotEmpty) ...[
                      _buildFormLabel('Sub-subcategory Detail'),
                      _buildDropdown<String>(
                        value: _selectedSubSubcategory,
                        items: _subSubcategories,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSubSubcategory = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Start Date & End Date Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel('Start Date'),
                              GestureDetector(
                                onTap: _selectStartDate,
                                child: _buildDateDisplay(_formatDate(_startDate)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildFormLabel('End Date'),
                                  if (_endDate != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _endDate = null;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 6.0, right: 2.0),
                                        child: Text(
                                          'Set Infinite',
                                          style: TextStyle(
                                            color: widget.goldAccent,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _selectEndDate,
                                child: _buildDateDisplay(_endDate != null ? _formatDate(_endDate!) : 'Infinite'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveAssignment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C5A32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: goldAccent.withValues(alpha: 0.5), width: 1),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'SAVE ASSIGNMENT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: widget.isDark ? const Color(0xFF8B9B90) : const Color(0xFF4A5D52),
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final isDark = widget.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF03140A) : const Color(0xFFE8F5EE).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.goldAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          dropdownColor: isDark ? const Color(0xFF0A2214) : Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: widget.goldAccent),
          style: TextStyle(color: widget.textThemeColor, fontSize: 13, fontWeight: FontWeight.bold),
          items: items.map<DropdownMenuItem<T>>((T val) {
            return DropdownMenuItem<T>(
              value: val,
              child: Text(val.toString()),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateDisplay(String formattedText) {
    final isDark = widget.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF03140A) : const Color(0xFFE8F5EE).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.goldAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedText,
            style: TextStyle(
              color: widget.textThemeColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.calendar_month_rounded, color: widget.goldAccent, size: 18),
        ],
      ),
    );
  }
}
