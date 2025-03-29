// screens/admin_users_screen.dart
import 'package:alippepro_v1/models/user.dart';
import 'package:alippepro_v1/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  final AdminService adminService;

  const AdminUsersScreen({super.key, required this.adminService});

  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> users = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String searchQuery = '';
  String sortBy = 'createdAt';
  int sortOrder = -1;
  int currentPage = 1;
  int totalPages = 1;
  int totalUsers = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (currentPage < totalPages) {
        _loadMoreUsers();
      }
    }
  }

  // Замените только соответствующие методы в screens/admin_users_screen.dart
  Future<void> _loadUsers() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      currentPage = 1;
    });

    try {
      final response = await widget.adminService.getUsers(
        page: 1,
        search: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      setState(() {
        users = response.users;
        totalPages = response.totalPages;
        currentPage = response.currentPage;
        totalUsers = response.totalUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Ошибка загрузки пользователей: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки пользователей: $e')),
      );
    }
  }

  Future<void> _loadMoreUsers() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await widget.adminService.getUsers(
        page: currentPage + 1,
        search: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      setState(() {
        users.addAll(response.users);
        totalPages = response.totalPages;
        currentPage = response.currentPage;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ошибка загрузки дополнительных пользователей: $e')),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _loadUsers();
  }

  void _changeSorting(String newSortBy) {
    setState(() {
      if (sortBy == newSortBy) {
        // Если уже сортируем по этому полю, просто меняем порядок
        sortOrder = sortOrder == 1 ? -1 : 1;
      } else {
        // Если новое поле, устанавливаем его и порядок по умолчанию
        sortBy = newSortBy;
        sortOrder = -1; // По умолчанию сортировка по убыванию
      }
    });
    _loadUsers();
  }

  Future<void> _showGrantAccessDialog(User user) async {
    int planPoints = 120;
    int quizPoints = 30;
    int expiresInDays = 30;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Предоставить доступ к ИИ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Пользователь: ${user.name}'),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Plan Points'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => planPoints = int.tryParse(value) ?? 120,
                  controller: TextEditingController(text: '120'),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Quiz Points'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quizPoints = int.tryParse(value) ?? 30,
                  controller: TextEditingController(text: '30'),
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Срок действия (дней)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      expiresInDays = int.tryParse(value) ?? 30,
                  controller: TextEditingController(text: '30'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                print(user.id);

                try {
                  await widget.adminService.grantAiAccess(
                    userId: user.id,
                    planPoint: planPoints,
                    quizPoint: quizPoints,
                    expiresInDays: expiresInDays,
                  );
                  // Обновляем список пользователей
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Доступ успешно предоставлен')),
                  );
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              },
              child: const Text('Предоставить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление пользователями'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _changeSorting,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'createdAt',
                child: Row(
                  children: [
                    Icon(sortBy == 'createdAt'
                        ? (sortOrder == 1
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : null),
                    const SizedBox(width: 8),
                    const Text('Дата регистрации'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'name',
                child: Row(
                  children: [
                    Icon(sortBy == 'name'
                        ? (sortOrder == 1
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : null),
                    const SizedBox(width: 8),
                    const Text('Имя'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск пользователей',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
              ),
              onChanged: (value) {
                // Задержка поиска, чтобы избежать слишком частых запросов
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchController.text) {
                    _onSearchChanged(value);
                  }
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? const Center(child: Text('Пользователи не найдены'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: users.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == users.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final user = users[index];
                          final aiSub = user.aiSubscription;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.avatarUrl != null &&
                                        user.avatarUrl!.isNotEmpty
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null ||
                                        user.avatarUrl!.isEmpty
                                    ? Text(user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?')
                                    : null,
                              ),
                              title: Text(user.name.isNotEmpty
                                  ? user.name
                                  : 'Без имени'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.phoneNumber ?? user.email),
                                  if (user.hasActiveAiSubscription &&
                                      aiSub != null)
                                    Text(
                                      'ИИ: План ${aiSub['planPoint']}, '
                                      'Тест ${aiSub['quizPoint']}',
                                      style: const TextStyle(color: Colors.green),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _showGrantAccessDialog(user),
                                tooltip: 'Предоставить доступ к ИИ',
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Всего: $totalUsers пользователей | Страница $currentPage из $totalPages',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
