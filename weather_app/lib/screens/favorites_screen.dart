import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Cities',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService().getFavoriteCities(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No favorite cities yet.',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
              );
            }
            final docs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.only(top: kToolbarHeight + 20),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final city = docs[i]['city'];
                return Card(
                  color: Colors.white.withOpacity(0.92),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    title: Text(
                      city,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await FirestoreService().deleteFavoriteCity(docs[i].id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted $city from favorites!')),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}