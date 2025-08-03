import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('weatherBox');
    final forecast = box.get('forecastData', defaultValue: []);
    final locationName = box.get('locationName', defaultValue: 'Unknown Location');

    return Scaffold(
      appBar: AppBar(
        title: Text("5-Day Forecast for $locationName"),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
      ),
      extendBodyBehindAppBar: true, // Extend body behind app bar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)], // Same gradient as MainApp body
          ),
        ),
        child: forecast.isEmpty
            ? const Center(
                child: Text(
                  "No forecast data available. Please search for a city on the Weather tab.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: kToolbarHeight + 20), // Adjust padding for app bar
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(_getWeatherIcon(day['weather'][0]['main']), color: Colors.blue, size: 30),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEE, MMM d').format(DateTime.parse(day['dt_txt'])),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${day['weather'][0]['description']}",
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Temp: ${day['main']['temp'].toStringAsFixed(1)}°C",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
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
      return Icons.cloudy_snowing; // Using a rain/snow icon
    } else if (condition.contains('mist') || condition.contains('fog') || condition.contains('haze')) {
      return Icons.filter_drama; // A general mist/haze icon
    }
    return Icons.cloud; // Default icon
  }
}