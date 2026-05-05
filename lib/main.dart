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
            seedColor: Colors.blueAccent,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.robotoTextTheme(),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            scrolledUnderElevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.robotoTextTheme(
            ThemeData.dark().textTheme,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const LoginScreen(), 
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
