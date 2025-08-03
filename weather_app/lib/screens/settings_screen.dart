import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDark;
    _language = widget.locale.languageCode;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _darkMode
                ? [Color(0xFF232526), Color(0xFF414345)]
                : [Color(0xFF74ebd5), Color(0xFFACB6E5)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0).copyWith(top: kToolbarHeight + 20),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : AssetImage('assets/default_avatar.png') as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white.withOpacity(0.92),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SwitchListTile(
                  title: Text(
                    "Dark Mode",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  value: _darkMode,
                  onChanged: (val) {
                    setState(() => _darkMode = val);
                    widget.onThemeChanged(val);
                  },
                  secondary: Icon(
                    _darkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Card(
                color: Colors.white.withOpacity(0.92),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Language",
                      border: InputBorder.none,
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
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
                    dropdownColor: Colors.white,
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