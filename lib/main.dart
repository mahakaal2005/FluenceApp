import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  // Preload Inter font - this ensures font files are loaded before app renders
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
  ]);
  
  runApp(const App());
}


