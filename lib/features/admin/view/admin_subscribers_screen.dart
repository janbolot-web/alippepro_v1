// screens/admin_subscribers_screen.dart
import 'package:alippepro_v1/models/user.dart';
import 'package:alippepro_v1/services/admin_service.dart';
import 'package:flutter/material.dart';


class AdminSubscribersScreen extends StatefulWidget {
  final AdminService adminService;

  const AdminSubscribersScreen({super.key, required this.adminService});

  @override
  _AdminSubscribersScreenState createState() => _AdminSubscribersScreenState();
}

class _AdminSubscribersScreenState extends State<AdminSubscribersScreen> {
  List<User> subscribers = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String searchQuery = '';
  String sortBy = 'subscription.expiresAt'; // По умолчанию сортируем по дате доступа
  int sortOrder = -1; // По умолчанию новейшие первыми
  int currentPage = 1;
  int totalPages = 1;
  int totalUsers = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubscribers();
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (currentPage < totalPages) {
        _loadMoreSubscribers();
      }
    }
  }

  Future<void> _loadSubscribers() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      currentPage = 1;
    });

    try {
      final response = await widget.adminService.getUsersWithAiSubscription(
        page: 1,
        search: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      setState(() {
        subscribers = response.users;
        totalPages = response.totalPages;
        currentPage = response.currentPage;
        totalUsers = response.totalUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки подписчиков: $e')),
      );
    }
  }

  Future<void> _loadMoreSubscribers() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await widget.adminService.getUsersWithAiSubscription(
        page: currentPage + 1,
        search: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      setState(() {
        subscribers.addAll(response.users);
        currentPage = response.currentPage;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки дополнительных подписчиков: $e')),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _loadSubscribers();
  }

  void _changeSorting(String newSortBy) {
    setState(() {
      if (sortBy == newSortBy) {
        // Если уже сортируем по этому полю, просто меняем порядок
        sortOrder = sortOrder == 1 ? -1 : 1;
      } else {
        // Если новое поле, устанавливаем его и порядок по умолчанию
        sortBy = newSortBy;
        sortOrder = -1; // По умолчанию сортировка по убыванию (новейшие первыми)
      }
    });
    _loadSubscribers();
  }

  // Функция для форматирования даты истечения подписки
  String _formatExpiryDate(Map<String, dynamic>? aiSub) {
    if (aiSub == null) return "N/A";
    
    String expiresAtStr = aiSub['expiresAt'] is String ? aiSub['expiresAt'] : "N/A";
    if (expiresAtStr != "N/A") {
      try {
        // Извлекаем YYYY-MM-DD из ISO строки даты
        return expiresAtStr.substring(0, 10);
      } catch (e) {
        return expiresAtStr;
      }
    }
    return expiresAtStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подписчики ИИ'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _changeSorting,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'subscription.expiresAt',
                child: Row(
                  children: [
                    Icon(sortBy == 'subscription.expiresAt'
                        ? (sortOrder == 1
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : null),
                    const SizedBox(width: 8),
                    const Text('По дате доступа'),
                  ],
                ),
              ),
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
                    const Text('По дате регистрации'),
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
                    const Text('По имени'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'subscription.planPoint',
                child: Row(
                  children: [
                    Icon(sortBy == 'subscription.planPoint'
                        ? (sortOrder == 1
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : null),
                    const SizedBox(width: 8),
                    const Text('По количеству Plan Points'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'subscription.quizPoint',
                child: Row(
                  children: [
                    Icon(sortBy == 'subscription.quizPoint'
                        ? (sortOrder == 1
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : null),
                    const SizedBox(width: 8),
                    const Text('По количеству Quiz Points'),
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
                labelText: 'Поиск подписчиков',
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
                : subscribers.isEmpty
                    ? const Center(child: Text('Подписчики не найдены'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: subscribers.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == subscribers.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final user = subscribers[index];
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
                                  if (aiSub != null)
                                    Text(
                                      'ИИ: План ${aiSub['planPoint']}, '
                                      'Тест ${aiSub['quizPoint']}',
                                      style: const TextStyle(color: Colors.green),
                                    ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Активен до:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _formatExpiryDate(aiSub),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Показываем больше информации о подписке
                                _showSubscriptionDetails(user);
                              },
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Всего: $totalUsers подписчиков | Страница $currentPage из $totalPages',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Диалог с подробной информацией о подписке
  void _showSubscriptionDetails(User user) {
    final aiSub = user.aiSubscription;
    
    if (aiSub == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Информация о подписке'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Пользователь: ${user.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('ID: ${user.id}'),
                const SizedBox(height: 8),
                Text('Телефон: ${user.phoneNumber ?? "Не указан"}'),
                Text('Email: ${user.email ?? "Не указан"}'),
                const SizedBox(height: 8),
                const Text('Подписка ИИ:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Plan Points: ${aiSub['planPoint']}'),
                Text('Quiz Points: ${aiSub['quizPoint']}'),
                Text('Статус: ${aiSub['isActive'] ? "Активна" : "Неактивна"}'),
                Text('Действует до: ${_formatExpiryDate(aiSub)}'),
                const SizedBox(height: 16),
                const Text('Действия:', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Предоставить дополнительный доступ
                _showGrantAccessDialog(user);
              },
              child: const Text('Продлить доступ'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  // Диалог для предоставления доступа (продления подписки)
  Future<void> _showGrantAccessDialog(User user) async {
    int planPoints = 120;
    int quizPoints =30;
    int expiresInDays = 30;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Продлить доступ к ИИ'),
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
                  onChanged: (value) => quizPoints = int.tryParse(value) ??30,
                  controller: TextEditingController(text: '30'),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Срок действия (дней)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => expiresInDays = int.tryParse(value) ?? 30,
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
                
                try {
                  await widget.adminService.grantAiAccess(
                    userId: user.id,
                    planPoint: planPoints,
                    quizPoint: quizPoints,
                    expiresInDays: expiresInDays,
                  );
                  // Обновляем список пользователей
                  _loadSubscribers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Доступ успешно продлен')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              },
              child: const Text('Продлить'),
            ),
          ],
        );
      },
    );
  }
}