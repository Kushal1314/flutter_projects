import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final Locale locale;
  final Function(bool) onThemeChanged;
  final Function(String) onLangChanged;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.locale,
    required this.onThemeChanged,
    required this.onLangChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _darkMode;
  late String _language;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDark;
    _language = widget.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0).copyWith(top: kToolbarHeight + 20), // Adjust padding for app bar
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SwitchListTile(
                  title: const Text("Dark Mode", style: TextStyle(fontSize: 18)),
                  value: _darkMode,
                  onChanged: (val) {
                    setState(() => _darkMode = val);
                    widget.onThemeChanged(val);
                  },
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Language",
                      border: InputBorder.none, // Remove underline
                    ),
                    value: _language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text("English")),
                      DropdownMenuItem(value: 'ne', child: Text("Nepali")),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _language = val);
                      widget.onLangChanged(val);
                    },
                    style: const TextStyle(fontSize: 18, color: Colors.black), // Text style for selected item
                    dropdownColor: Theme.of(context).cardColor, // Dropdown background color
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