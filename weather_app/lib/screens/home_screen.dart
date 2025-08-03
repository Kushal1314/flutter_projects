import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:glassmorphism/glassmorphism.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  final String apiKey;
  final FlutterLocalNotificationsPlugin notifs;

  const HomeScreen({super.key, required this.apiKey, required this.notifs});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? weather;
  List<dynamic>? forecast;
  Map<String, dynamic>? air;
  String _location = '';
  bool _loading = false;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    final box = Hive.box('weatherBox');
    setState(() {
      weather = box.get('weatherData');
      forecast = box.get('forecastData');
      air = box.get('airData');
      _location = box.get('locationName') ?? '';
    });
  }

  Future<void> _fetchWeather(String city) async {
    if (city.trim().isEmpty) {
      _showErrorDialog('Please enter a city name.');
      return;
    }

    setState(() => _loading = true);

    try {
      final wRes = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${widget.apiKey}&units=metric'));

      if (wRes.statusCode != 200) {
        _showErrorDialog('City not found or API error.');
        setState(() => _loading = false);
        return;
      }
      final wData = jsonDecode(wRes.body);

      final fRes = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=${widget.apiKey}&units=metric'));

      if (fRes.statusCode != 200) {
        _showErrorDialog('Failed to fetch forecast data.');
        setState(() => _loading = false);
        return;
      }
      final fList = jsonDecode(fRes.body)['list'] as List;
      final fData = fList.where((x) {
        return x['dt_txt'] != null && x['dt_txt'].contains('12:00:00');
      }).toList();

      final aRes = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=${wData['coord']['lat']}&lon=${wData['coord']['lon']}&appid=${widget.apiKey}'));

      if (aRes.statusCode != 200) {
        _showErrorDialog('Failed to fetch air quality data.');
        setState(() => _loading = false);
        return;
      }
      final aData = jsonDecode(aRes.body);

      // Cache results
      final box = Hive.box('weatherBox');
      box.put('weatherData', wData);
      box.put('forecastData', fData);
      box.put('airData', aData);
      box.put('locationName', '${wData['name']}, ${wData['sys']['country']}');

      setState(() {
        weather = wData;
        forecast = fData;
        air = aData;
        _location = '${wData['name']}, ${wData['sys']['country']}';
      });

      await _scheduleNotification();
    } catch (e) {
      _showErrorDialog('Failed to fetch weather data. Please try again.');
      print('Weather fetch error: $e');
    }

    setState(() => _loading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _scheduleNotification() async {
    if (weather == null) return;

    final condition = weather!['weather'][0]['main'];
    final temp = weather!['main']['temp'].toStringAsFixed(1);

    await widget.notifs.zonedSchedule(
      0,
      'Daily Weather',
      'Today in $_location: $condition, $temp°C',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_channel',
          'Weather',
          channelDescription: 'Daily weather updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('rain')) {
      return Icons.grain;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else if (condition.contains('thunderstorm')) {
      return Icons.flash_on;
    } else if (condition.contains('drizzle')) {
      return Icons.grain;
    } else if (condition.contains('mist') ||
        condition.contains('fog') ||
        condition.contains('haze')) {
      return Icons.filter_drama;
    }
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF232526), // dark blue/gray
              Color(0xFF414345), // deep gray
              Color(0xFF6a11cb), // purple
              Color(0xFF2575fc), // blue
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // --- Search Bar ---
              Card(
                elevation: 8,
                color: Colors.white.withOpacity(0.95),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          style: GoogleFonts.poppins(),
                          decoration: InputDecoration(
                            labelText: 'Enter city name',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                          ),
                          onSubmitted: (value) => _fetchWeather(value),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: () => _fetchWeather(_cityController.text),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const CircularProgressIndicator(color: Colors.white)
              else if (weather != null) ...[
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 300,
                  borderRadius: 28,
                  blur: 24,
                  border: 2,
                  alignment: Alignment.center,
                  linearGradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _location,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Icon(
                        _getWeatherIcon(weather!['weather'][0]['description']),
                        size: 100,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${weather!['weather'][0]['description']}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '🌡️ ${weather!['main']['temp']}°C',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '💧 Humidity: ${weather!['main']['humidity']}%',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (air != null)
                  Text(
                    'Air Quality Index: ${air!['list'][0]['main']['aqi']}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.favorite),
                  label: Text('Save as Favorite'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final city = _location;
                    await FirestoreService().addFavoriteCity(city);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved $city as favorite!')),
                    );
                  },
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Text(
                      'Search for a city to get weather information.',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}