import 'package:flutter/material.dart';
import 'mock_data.dart';

class ViewAllGroupsScreen extends StatefulWidget {
  final bool isDark;
  final Color textThemeColor;
  final Color silverText;
  final Color goldAccent;
  final Color valueGreenColor;

  const ViewAllGroupsScreen({
    super.key,
    required this.isDark,
    required this.textThemeColor,
    required this.silverText,
    required this.goldAccent,
    required this.valueGreenColor,
  });

  @override
  State<ViewAllGroupsScreen> createState() => _ViewAllGroupsScreenState();
}

class _ViewAllGroupsScreenState extends State<ViewAllGroupsScreen> {
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await MockDataManager().getCommandGroup();
    if (mounted) {
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    }
  }

  Widget _buildGroupSection(String title, List<Map<String, dynamic>> slots, IconData icon) {
    if (slots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: widget.goldAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: widget.goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        ...slots.map((slot) => _buildSlotCard(slot)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot) {
    final isAssigned = slot['armyNo'] != null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: widget.isDark 
            ? const Color(0xFF0C5A32).withValues(alpha: 0.15) 
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark 
              ? widget.goldAccent.withValues(alpha: 0.3)
              : const Color(0xFF0C5A32).withValues(alpha: 0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: widget.goldAccent.withValues(alpha: 0.2),
          child: Text(
            '${slot['slotId']}',
            style: TextStyle(
              color: widget.goldAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          isAssigned ? (slot['username'] ?? 'Unknown') : 'Unassigned Slot',
          style: TextStyle(
            color: isAssigned ? widget.textThemeColor : widget.silverText,
            fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
            fontStyle: isAssigned ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        subtitle: isAssigned ? Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Army No: ${slot['armyNo']}',
            style: TextStyle(color: widget.silverText, fontSize: 12),
          ),
        ) : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.valueGreenColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.valueGreenColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            (slot['role'] as String).toUpperCase(),
            style: TextStyle(
              color: widget.valueGreenColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final superAdmins = _groups.where((s) => s['role'] == 'superadmin').toList();
    final admins = _groups.where((s) => s['role'] == 'admin').toList();
    final users = _groups.where((s) => s['role'] == 'user').toList();

    return Theme(
      data: widget.isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: widget.isDark ? const Color(0xFF03140A) : const Color(0xFFE8F5EE),
        appBar: AppBar(
          backgroundColor: widget.isDark 
              ? const Color(0xFF03140A).withValues(alpha: 0.85) 
              : Colors.white.withValues(alpha: 0.85),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: widget.goldAccent),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'All Command Groups',
            style: TextStyle(
              color: widget.textThemeColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading 
            ? Center(child: CircularProgressIndicator(color: widget.goldAccent))
            : ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 40),
                children: [
                  _buildGroupSection('SUPERADMINS', superAdmins, Icons.admin_panel_settings),
                  _buildGroupSection('DATA ENTRY ADMINS', admins, Icons.manage_accounts),
                  _buildGroupSection('VIEW-ONLY USERS', users, Icons.person),
                ],
              ),
      ),
    );
  }
}
