// screens/admin_dashboard_screen.dart
import 'package:alippepro_v1/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'admin_users_screen.dart';
import 'admin_subscribers_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;

  const AdminDashboardScreen({
    super.key,
    required this.token,
  });

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  late AdminService adminService;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    adminService = AdminService(token: widget.token);
  }

  // Функция для изменения выбранной вкладки
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Обновите метод _buildBody() в классе _AdminDashboardScreenState
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return AdminUsersScreen(adminService: adminService);
      case 1:
        return AdminSubscribersScreen(adminService: adminService);
      case 2:
        return _buildStatisticsTab();
        // return AdminStatisticsScreen(adminService: adminService);
      default:
        return const Center(child: Text('Выберите раздел'));
    }
  }

  // Заглушка для вкладки статистики (можно расширить позже)
  Widget _buildStatisticsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Статистика',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Функция статистики находится в разработке',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Пользователи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Подписчики',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Статистика',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
