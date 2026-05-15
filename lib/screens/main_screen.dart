import 'package:flutter/material.dart';
import 'browse_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'device_screen.dart';
import '../widgets/connectivity_banner.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BrowseScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
    DeviceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ConnectivityBanner(
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.sensors_outlined),
              selectedIcon: Icon(Icons.sensors),
              label: 'Device',
            ),
          ],
        ),
      ),
    );
  }
}
