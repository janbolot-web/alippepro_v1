import 'package:alippepro_v1/features/market/view/catalog_screen.dart';
import 'package:alippepro_v1/features/market/view/home_screen.dart';
import 'package:alippepro_v1/features/market/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

int _currentIndex = 0;

class _MarketScreenState extends State<MarketScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const CatalogScreen(),
    // const CartScreen(),
    const ProfileScreen(),
  ];
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Можно добавить логику навигации на разные экраны
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),

      body: _screens[_currentIndex], // Показываем текущий экран
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xff005558),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Обновляем текущий индекс
          });
        },
        selectedLabelStyle: GoogleFonts.rubik(),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: 'Каталог'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.shopping_cart), label: 'Корзина'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
