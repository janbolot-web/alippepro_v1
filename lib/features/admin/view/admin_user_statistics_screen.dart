// screens/admin_user_statistics_screen.dart
import 'package:alippepro_v1/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminUserStatisticsScreen extends StatefulWidget {
  final AdminService adminService;
  final String userId;
  final String userName;

  const AdminUserStatisticsScreen({
    super.key,
    required this.adminService,
    required this.userId,
    required this.userName,
  });

  @override
  _AdminUserStatisticsScreenState createState() =>
      _AdminUserStatisticsScreenState();
}

class _AdminUserStatisticsScreenState extends State<AdminUserStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? userData;

  // Форматирование чисел, дат и денег
  final NumberFormat numberFormat = NumberFormat("#,##0");
  final NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');
  final DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserStatistics() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await widget.adminService.getUserAiStatistics(widget.userId);

      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Статистика: ${widget.userName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Обзор'),
            Tab(text: 'План (Чат)'),
            Tab(text: 'Тест (Quiz)'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserStatistics,
            tooltip: 'Обновить данные',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ошибка загрузки данных: $errorMessage',
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserStatistics,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildPlanTab(),
                    _buildQuizTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    final planStats = userData!['planStats'];
    final quizStats = userData!['quizStats'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о пользователе
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Информация о пользователе',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildInfoRow('ID:', widget.userId),
                  _buildInfoRow(
                      'Имя:', userData!['user']['name'] ?? 'Не указано'),
                  _buildInfoRow(
                      'Email:', userData!['user']['email'] ?? 'Не указан'),
                  _buildInfoRow('Телефон:',
                      userData!['user']['phoneNumber'] ?? 'Не указан'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Статистика использования
          const Text('Статистика использования ИИ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'План (Чат)',
                  requests: planStats['totalRequests'],
                  tokens: planStats['totalTokens'],
                  cost: planStats['estimatedCost'],
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Тест (Quiz)',
                  requests: quizStats['totalRequests'],
                  tokens: quizStats['totalTokens'],
                  cost: quizStats['estimatedCost'],
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // График распределения токенов
          const Text('Распределение токенов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: planStats['totalTokens'].toDouble(),
                    title:
                        'План\n${numberFormat.format(planStats['totalTokens'])}',
                    color: Colors.blue,
                    radius: 100,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: quizStats['totalTokens'].toDouble(),
                    title:
                        'Тест\n${numberFormat.format(quizStats['totalTokens'])}',
                    color: Colors.green,
                    radius: 100,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Распределение по времени (если есть данные)
          if ((userData!['hourlyStats'] as List).isNotEmpty) ...[
            const Text('Распределение запросов по времени',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildTimeUsageChart(),
            ),
          ],

          const SizedBox(height: 24),

          // Общая стоимость
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Общая стоимость использования',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(double.parse(
                            planStats['estimatedCost'].toString()) +
                        double.parse(quizStats['estimatedCost'].toString())),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'По тарифам OpenAI для GPT-4o',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTab() {
    final planStats = userData!['planStats'];
    final requests = List<Map<String, dynamic>>.from(planStats['requests']);

    // Сортируем запросы по времени (сначала новые)
    requests.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return Column(
      children: [
        // Сводная информация
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('План (Чат) - сводная информация',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildStatRow('Всего запросов:',
                      numberFormat.format(planStats['totalRequests'])),
                  _buildStatRow('Всего токенов:',
                      numberFormat.format(planStats['totalTokens'])),
                  _buildStatRow(
                      'Общая стоимость:',
                      currencyFormat.format(
                          double.parse(planStats['estimatedCost'].toString()))),
                ],
              ),
            ),
          ),
        ),

        // Заголовок для списка запросов
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('История запросов',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${requests.length} запросов',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Список запросов
        Expanded(
          child: requests.isEmpty
              ? const Center(child: Text('Нет данных о запросах'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(
                        request['timestamp'] * 1000);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ExpansionTile(
                        title: Text(dateFormat.format(dateTime)),
                        subtitle: Text(
                            'Токены: ${numberFormat.format(request['totalTokens'])}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('ID запроса:', request['id']),
                                _buildDetailRow('Модель:', request['model']),
                                _buildDetailRow(
                                    'Токены запроса:',
                                    numberFormat
                                        .format(request['promptTokens'])),
                                _buildDetailRow(
                                    'Токены ответа:',
                                    numberFormat
                                        .format(request['completionTokens'])),
                                _buildDetailRow(
                                    'Всего токенов:',
                                    numberFormat
                                        .format(request['totalTokens'])),
                                _buildDetailRow(
                                    'Стоимость:',
                                    currencyFormat.format(double.parse(
                                        request['estimatedCost'].toString()))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuizTab() {
    final quizStats = userData!['quizStats'];
    final requests = List<Map<String, dynamic>>.from(quizStats['requests']);

    // Сортируем запросы по времени (сначала новые)
    // Замените строку с ошибкой на более безопасную версию
// Было:
// requests.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

// Безопасная сортировка с проверкой типов и null-значений:
    requests.sort((a, b) {
      // Проверяем наличие timestamp в обоих элементах
      final timestampA = a['timestamp'];
      final timestampB = b['timestamp'];

      // Если оба timestamp отсутствуют, считаем элементы равными
      if (timestampA == null && timestampB == null) return 0;

      // Если только у одного отсутствует timestamp, он идёт в конец
      if (timestampA == null) return 1;
      if (timestampB == null) return -1;

      // Преобразуем к строкам для сравнения, если разные типы
      String strA = timestampA.toString();
      String strB = timestampB.toString();

      // Для числовых timestamp выполняем числовое сравнение
      try {
        // Пробуем преобразовать в числа и сравнить
        final numA = num.tryParse(strA);
        final numB = num.tryParse(strB);

        if (numA != null && numB != null) {
          // Обратная сортировка - новейшие сначала
          return numB.compareTo(numA);
        }
      } catch (_) {}

      // Если не получилось числовое сравнение, сравниваем как строки
      return strB.compareTo(strA);
    });

    return Column(
      children: [
        // Сводная информация
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Тест (Quiz) - сводная информация',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildStatRow('Всего запросов:',
                      numberFormat.format(quizStats['totalRequests'])),
                  _buildStatRow('Всего токенов:',
                      numberFormat.format(quizStats['totalTokens'])),
                  _buildStatRow(
                      'Общая стоимость:',
                      currencyFormat.format(
                          double.parse(quizStats['estimatedCost'].toString()))),
                ],
              ),
            ),
          ),
        ),

        // Заголовок для списка запросов
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('История запросов',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${requests.length} запросов',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Список запросов
        Expanded(
          child: requests.isEmpty
              ? const Center(child: Text('Нет данных о запросах'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(
                        request['timestamp'] * 1000);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ExpansionTile(
                        title: Text(dateFormat.format(dateTime)),
                        subtitle: Text(
                            'Токены: ${numberFormat.format(request['totalTokens'])}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('ID запроса:', request['id']),
                                _buildDetailRow('Модель:', request['model']),
                                _buildDetailRow(
                                    'Токены запроса:',
                                    numberFormat
                                        .format(request['promptTokens'])),
                                _buildDetailRow(
                                    'Токены ответа:',
                                    numberFormat
                                        .format(request['completionTokens'])),
                                _buildDetailRow(
                                    'Всего токенов:',
                                    numberFormat
                                        .format(request['totalTokens'])),
                                _buildDetailRow(
                                    'Стоимость:',
                                    currencyFormat.format(double.parse(
                                        request['estimatedCost'].toString()))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTimeUsageChart() {
    final hourlyStats =
        List<Map<String, dynamic>>.from(userData!['hourlyStats']);

    // Агрегируем по часам (суммируем все дни)
    final Map<int, int> hourlyUsageMap = {};

    for (var item in hourlyStats) {
      final hour = item['_id']['hour'] as int;
      hourlyUsageMap[hour] = (hourlyUsageMap[hour] ?? 0) + item['count'] as int;
    }

    // Создаем данные для графика
    final List<FlSpot> spots = [];
    for (int i = 0; i < 24; i++) {
      spots.add(FlSpot(i.toDouble(), (hourlyUsageMap[i] ?? 0).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 3 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${value.toInt()}:00',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}K',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 23,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      {required String title,
      required int requests,
      required int tokens,
      required dynamic cost,
      required Color color}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatItem('Запросы:', numberFormat.format(requests), color),
            const SizedBox(height: 8),
            _buildStatItem('Токены:', numberFormat.format(tokens), color),
            const SizedBox(height: 8),
            _buildStatItem('Стоимость:',
                currencyFormat.format(double.parse(cost.toString())), color),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
