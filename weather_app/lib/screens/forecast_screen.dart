import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

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
    final box = Hive.box('weatherBox');
    final forecast = box.get('forecastData', defaultValue: []);
    final locationName = box.get('locationName', defaultValue: 'Unknown Location');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "5-Day Forecast for $locationName",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF232526),
              Color(0xFF414345),
              Color(0xFF6a11cb),
              Color(0xFF2575fc),
            ],
          ),
        ),
        child: forecast.isEmpty
            ? Center(
                child: Text(
                  "No forecast data available. Please search for a city on the Weather tab.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: kToolbarHeight + 20),
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  return Card(
                    color: Colors.white.withOpacity(0.92),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            _getWeatherIcon(day['weather'][0]['main']),
                            color: Colors.deepPurple,
                            size: 36,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEE, MMM d').format(DateTime.parse(day['dt_txt'])),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${day['weather'][0]['description']}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Temp: ${day['main']['temp'].toStringAsFixed(1)}°C",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
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
}