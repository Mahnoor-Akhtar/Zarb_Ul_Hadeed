import 'package:flutter/material.dart';
import '../services/personnel_data_manager.dart';

class PersonnelProfileScreen extends StatelessWidget {
  final Map<String, String> person;

  const PersonnelProfileScreen({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldAccent = isDark ? const Color(0xFFE6C200) : const Color(0xFF0C5A32);
    final silverText = isDark ? Colors.white70 : Colors.black54;
    final textThemeColor = isDark ? Colors.white : Colors.black87;

    final armyNo = person['armyNo'] ?? '';
    final rank = person['rank'] ?? '';
    final name = person['name'] ?? '';

    final manager = PersonnelDataManager();
    final status = manager.getStatus(armyNo);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel Profile'),
        backgroundColor: goldAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: const AssetImage('assets/images/profile_avatar.jpg'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '$rank $name',
                style: TextStyle(
                  color: textThemeColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Army No: $armyNo',
                style: TextStyle(color: silverText, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            // Status section
            Text('Current Status',
                style: TextStyle(
                    color: goldAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const Divider(height: 20, thickness: 1),
            Row(
              children: [
                const Icon(Icons.category, size: 20),
                const SizedBox(width: 8),
                Text(status.category,
                    style: TextStyle(color: textThemeColor, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            if (status.subcategory != null) ...[
              Row(
                children: [
                  const Icon(Icons.subdirectory_arrow_right, size: 20),
                  const SizedBox(width: 8),
                  Text(status.subcategory!,
                      style: TextStyle(color: textThemeColor, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${status.startDate.day}/${status.startDate.month}/${status.startDate.year}' +
                      (status.endDate != null
                          ? ' – ${status.endDate!.day}/${status.endDate!.month}/${status.endDate!.year}'
                          : ' – Present'),
                  style: TextStyle(color: textThemeColor, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
