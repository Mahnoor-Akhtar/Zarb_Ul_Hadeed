import 'package:flutter/material.dart';
import 'mock_data.dart';

class ManageAttributesScreen extends StatefulWidget {
  final bool isDark;
  final Color textThemeColor;
  final Color silverText;
  final Color goldAccent;
  final Color valueGreenColor;

  const ManageAttributesScreen({
    super.key,
    required this.isDark,
    required this.textThemeColor,
    required this.silverText,
    required this.goldAccent,
    required this.valueGreenColor,
  });

  @override
  State<ManageAttributesScreen> createState() => _ManageAttributesScreenState();
}

class _ManageAttributesScreenState extends State<ManageAttributesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<String> _trades = [];
  List<String> _ranks = [];
  List<String> _batteries = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAttributes();
  }

  Future<void> _loadAttributes() async {
    setState(() => _isLoading = true);
    
    final trades = await MockDataManager().getTrades();
    final ranks = await MockDataManager().getRanks();
    final batteries = await MockDataManager().getBatteries();

    if (mounted) {
      setState(() {
        _trades = trades;
        _ranks = ranks;
        _batteries = batteries;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditDialog(String type, {String? existingValue, int? index}) {
    final TextEditingController controller = TextEditingController(
      text: type == 'Rank' && existingValue != null ? existingValue.trim() : existingValue,
    );

    String selectedType = 'Subcategory';
    String? selectedParent;
    final List<String> categories = _ranks.where((r) => r.toLowerCase() != 'all' && !r.startsWith(' ')).toList();

    if (type == 'Rank') {
      if (existingValue != null) {
        if (existingValue.startsWith(' ')) {
          selectedType = 'Subcategory';
          String? foundParent;
          for (int i = index! - 1; i >= 0; i--) {
            if (!_ranks[i].startsWith(' ') && _ranks[i].toLowerCase() != 'all') {
              foundParent = _ranks[i];
              break;
            }
          }
          selectedParent = foundParent;
        } else {
          selectedType = 'Category';
        }
      } else {
        selectedType = categories.isNotEmpty ? 'Subcategory' : 'Category';
      }
      if (selectedParent == null && categories.isNotEmpty) {
        selectedParent = categories.first;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: widget.isDark ? const Color(0xFF03140A) : Colors.white,
              title: Text(
                existingValue == null ? 'Add New $type' : 'Edit $type',
                style: TextStyle(color: widget.textThemeColor, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type == 'Rank' && categories.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Subcategory', style: TextStyle(fontSize: 12)),
                            value: 'Subcategory',
                            groupValue: selectedType,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedType = val);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Category', style: TextStyle(fontSize: 12)),
                            value: 'Category',
                            groupValue: selectedType,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedType = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (selectedType == 'Subcategory') ...[
                      const SizedBox(height: 8),
                      const Text('Parent Category:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: selectedParent,
                        isExpanded: true,
                        dropdownColor: widget.isDark ? const Color(0xFF03140A) : Colors.white,
                        style: TextStyle(color: widget.textThemeColor, fontSize: 12),
                        items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedParent = val);
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: controller,
                    style: TextStyle(color: widget.textThemeColor),
                    decoration: InputDecoration(
                      hintText: type == 'Rank'
                          ? (selectedType == 'Category' ? 'Enter Category name' : 'Enter Rank name')
                          : 'Enter $type name',
                      hintStyle: TextStyle(color: widget.silverText),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.goldAccent.withValues(alpha: 0.5))),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.goldAccent)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: widget.silverText)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final val = controller.text.trim();
                    if (val.isEmpty) return;

                    Navigator.pop(context);
                    setState(() {
                      if (type == 'Trade') {
                        if (existingValue != null && index != null) {
                          _trades[index] = val;
                        } else {
                          _trades.add(val);
                        }
                      } else if (type == 'Battery') {
                        if (existingValue != null && index != null) {
                          _batteries[index] = val;
                        } else {
                          _batteries.add(val);
                        }
                      } else if (type == 'Rank') {
                        final formattedVal = selectedType == 'Category' ? val : '  $val';

                        if (existingValue != null && index != null) {
                          _ranks.removeAt(index);
                        }

                        if (selectedType == 'Category') {
                          if (existingValue != null && index != null && index < _ranks.length) {
                            _ranks.insert(index, formattedVal);
                          } else {
                            _ranks.add(formattedVal);
                          }
                        } else {
                          if (selectedParent != null) {
                            int insertIdx = _ranks.indexOf(selectedParent!);
                            if (insertIdx != -1) {
                              int i = insertIdx + 1;
                              while (i < _ranks.length && _ranks[i].startsWith(' ')) {
                                i++;
                              }
                              _ranks.insert(i, formattedVal);
                            } else {
                              _ranks.add(formattedVal);
                            }
                          } else {
                            _ranks.add(formattedVal);
                          }
                        }
                      }
                    });

                    await _saveAttributes(type);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: widget.goldAccent),
                  child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteAttribute(String type, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF03140A) : Colors.white,
        title: Text('Delete $type', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this $type?', style: TextStyle(color: widget.textThemeColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: widget.silverText)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                if (type == 'Trade') _trades.removeAt(index);
                else if (type == 'Rank') _ranks.removeAt(index);
                else if (type == 'Battery') _batteries.removeAt(index);
              });
              await _saveAttributes(type);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAttributes(String type) async {
    if (type == 'Trade') await MockDataManager().saveTrades(_trades);
    else if (type == 'Rank') await MockDataManager().saveRanks(_ranks);
    else if (type == 'Battery') await MockDataManager().saveBatteries(_batteries);
  }

  Widget _buildList(String type, List<String> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isAll = item.toLowerCase() == 'all';
        
        final isSub = type == 'Rank' && item.startsWith(' ');
        final displayText = isSub ? item.trim() : item;
        final isCategoryHeader = type == 'Rank' && !isSub && !isAll;

        return Padding(
          padding: EdgeInsets.only(left: isSub ? 20.0 : 0.0),
          child: Card(
            color: isCategoryHeader 
                ? (widget.isDark ? const Color(0xFF0C5A32).withValues(alpha: 0.2) : const Color(0xFFE8F5EE))
                : (widget.isDark ? const Color(0xFF0C5A32).withValues(alpha: 0.1) : Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isCategoryHeader ? widget.goldAccent : widget.goldAccent.withValues(alpha: 0.3),
                width: isCategoryHeader ? 1.2 : 1.0,
              ),
            ),
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: isSub 
                  ? Icon(Icons.subdirectory_arrow_right, color: widget.goldAccent.withValues(alpha: 0.7), size: 16) 
                  : null,
              title: Text(
                displayText,
                style: TextStyle(
                  color: isAll 
                      ? widget.goldAccent 
                      : (isCategoryHeader ? widget.goldAccent : widget.textThemeColor),
                  fontWeight: (isAll || isCategoryHeader) ? FontWeight.bold : FontWeight.w500,
                  fontSize: isCategoryHeader ? 14 : 13,
                ),
              ),
              trailing: isAll ? const SizedBox.shrink() : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: widget.valueGreenColor, size: 20),
                    onPressed: () => _showAddEditDialog(type, existingValue: item, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteAttribute(type, index),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: widget.isDark ? const Color(0xFF03140A) : const Color(0xFFE8F5EE),
        appBar: AppBar(
          backgroundColor: widget.isDark ? const Color(0xFF03140A).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: widget.goldAccent),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Manage App Attributes',
            style: TextStyle(
              color: widget.textThemeColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: widget.goldAccent,
            labelColor: widget.goldAccent,
            unselectedLabelColor: widget.silverText,
            tabs: const [
              Tab(text: 'Trades'),
              Tab(text: 'Ranks'),
              Tab(text: 'Batteries'),
            ],
          ),
        ),
        body: _isLoading 
            ? Center(child: CircularProgressIndicator(color: widget.goldAccent))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildList('Trade', _trades),
                  _buildList('Rank', _ranks),
                  _buildList('Battery', _batteries),
                ],
              ),
        floatingActionButton: _isLoading ? null : FloatingActionButton(
          onPressed: () {
            final idx = _tabController.index;
            final type = idx == 0 ? 'Trade' : idx == 1 ? 'Rank' : 'Battery';
            _showAddEditDialog(type);
          },
          backgroundColor: widget.goldAccent,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}
