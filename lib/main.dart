import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// import home page
import 'features/home/home_page.dart';

void main() {
  runApp(const StaraApp());
}

class StaraApp extends StatelessWidget {
  const StaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stara Media Group',
      debugShowCheckedModeBanner: false,

      // THEME
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2B4DFF),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // DARK MODE
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2B4DFF),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFF0E1327),
      ),

      // HOME
      home: const HomePage(),
    );
  }
}
