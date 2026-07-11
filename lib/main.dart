import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'personnel_data_manager.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  PersonnelDataManager().init(prefs);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  bool _isLoggedIn = false;
  bool _isDarkMode = false; // default to light theme
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = _prefs.getBool('isDarkMode') ?? false; // default to light (false)
    });
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '117 SP Regt.',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C5A32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C5A32),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _showSplash
          ? SplashScreen(
              onFinish: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : !_isLoggedIn
              ? LoginScreen(
                  onLoginSuccess: () {
                    setState(() {
                      _isLoggedIn = true;
                    });
                  },
                  isDarkMode: _isDarkMode,
                  onToggleTheme: _toggleTheme,
                )
              : DashboardScreen(
                  onLogout: () {
                    setState(() {
                      _isLoggedIn = false;
                    });
                  },
                  isDarkMode: _isDarkMode,
                  onToggleTheme: _toggleTheme,
                ),
    );
  }
}
