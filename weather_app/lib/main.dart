import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/screens/forecast_screen.dart';
import 'package:weather_app/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.openBox('weatherBox');

  final apiKey = dotenv.env['OPENWEATHER_API'] ?? '';

  runApp(WeatherApp(apiKey: apiKey));
}

class WeatherApp extends StatefulWidget {
  final String apiKey;
  const WeatherApp({super.key, required this.apiKey});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool _isDark = false;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('is_dark') ?? false;
      _locale = Locale(prefs.getString('language') ?? 'en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDark ? ThemeData.dark() : ThemeData.light(),
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ne')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MainApp(
        apiKey: widget.apiKey,
        onThemeChanged: (dark) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_dark', dark);
          setState(() => _isDark = dark);
        },
        onLangChanged: (lang) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('language', lang);
          setState(() => _locale = Locale(lang));
        },
        isDark: _isDark,
        locale: _locale,
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  final String apiKey;
  final Function(bool) onThemeChanged;
  final Function(String) onLangChanged;
  final bool isDark;
  final Locale locale;

  const MainApp({
    super.key,
    required this.apiKey,
    required this.onThemeChanged,
    required this.onLangChanged,
    required this.isDark,
    required this.locale,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  final FlutterLocalNotificationsPlugin _notifs = FlutterLocalNotificationsPlugin();

  late HomeScreen homeScreen;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initNotifs();
    homeScreen = HomeScreen(apiKey: widget.apiKey, notifs: _notifs);
  }

  Future<void> _initNotifs() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _notifs.initialize(settings);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homeScreen,
      const ForecastScreen(),
      SettingsScreen(
        isDark: widget.isDark,
        locale: widget.locale,
        onThemeChanged: widget.onThemeChanged,
        onLangChanged: widget.onLangChanged,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)],
          ),
        ),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Weather"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Forecast"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}