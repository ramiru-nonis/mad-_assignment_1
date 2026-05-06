import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';

// this is the main method which runs app

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Cellario Lite',
        themeMode: ThemeMode.system, // Follows device setting
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A237E), // Deep Indigo
            brightness: Brightness.light,
            primary: const Color(0xFF1A237E),
            surface: const Color(0xFFF8F9FF),
            surfaceContainerLow: const Color(0xFFFFFFFF),
          ),
          textTheme: GoogleFonts.robotoTextTheme(),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: const Color(0xFFF8F9FF),
            titleTextStyle: GoogleFonts.roboto(
              color: const Color(0xFF1A237E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9FA8DA), // Light Indigo
            brightness: Brightness.dark,
            primary: const Color(0xFFC5CAE9),
            surface: const Color(0xFF0F1014),
            surfaceContainerLow: const Color(0xFF1C1D24),
          ),
          textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: const Color(0xFF0F1014),
            titleTextStyle: GoogleFonts.roboto(
              color: const Color(0xFFC5CAE9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        home: const LoginScreen(), 
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
