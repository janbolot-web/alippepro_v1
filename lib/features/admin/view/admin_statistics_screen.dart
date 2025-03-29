// screens/admin_statistics_screen.dart
import 'package:alippepro_v1/features/admin/view/admin_user_statistics_screen.dart';
import 'package:alippepro_v1/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminStatisticsScreen extends StatefulWidget {
  final AdminService adminService;

  const AdminStatisticsScreen({super.key, required this.adminService});

  @override
  _AdminStatisticsScreenState createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? statisticsData;

  // Форматирование чисел и денег
  final NumberFormat numberFormat = NumberFormat("#,##0");
  final NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await widget.adminService.getAiStatistics();

      setState(() {
        statisticsData = data;
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
        title: const Text('Статистика использования ИИ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Общая'),
            Tab(text: 'По времени'),
            Tab(text: 'По пользователям'),
            Tab(text: 'Стоимость'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
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
                        onPressed: _loadStatistics,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTimeDistributionTab(),
                    _buildUserStatsTab(),
                    _buildCostAnalysisTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    final planStats = statisticsData!['planStats'];
    final quizStats = statisticsData!['quizStats'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Обзор использования ИИ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Статистика Plan vs Quiz
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Plan (Чат)',
                  requests: planStats['totalRequests'],
                  tokens: planStats['totalTokens'],
                  cost: planStats['estimatedCost'],
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Quiz (Тесты)',
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
            height: 300,
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

          // Общая статистика
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Общая статистика',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatRow(
                      'Всего запросов:',
                      numberFormat.format(planStats['totalRequests'] +
                          quizStats['totalRequests'])),
                  _buildStatRow(
                      'Всего токенов:',
                      numberFormat.format(
                          planStats['totalTokens'] + quizStats['totalTokens'])),
                  _buildStatRow(
                      'Общая стоимость:',
                      currencyFormat.format(double.parse(
                              planStats['estimatedCost'].toString()) +
                          double.parse(quizStats['estimatedCost'].toString()))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDistributionTab() {
    final hourlyStats = statisticsData!['hourlyStats'];
    final dailyStats = statisticsData!['dailyStats'];

    // Преобразуем данные для графика по часам
    final hourData = List<Map<String, dynamic>>.from(hourlyStats);

    // Агрегируем по часам (суммируем все дни)
    final Map<int, int> hourlyRequestsMap = {};
    final Map<int, int> hourlyTokensMap = {};

    for (var item in hourData) {
      final hour = item['_id']['hour'] as int;
      // Добавляем явное преобразование к int
      hourlyRequestsMap[hour] =
          (hourlyRequestsMap[hour] ?? 0) + (item['count'] as num).toInt();
      hourlyTokensMap[hour] =
          (hourlyTokensMap[hour] ?? 0) + (item['totalTokens'] as num).toInt();
    }

    // Создаем данные для графика по часам
    final List<FlSpot> hourlyRequestSpots = [];
    final List<FlSpot> hourlyTokenSpots = [];

    for (int i = 0; i < 24; i++) {
      hourlyRequestSpots
          .add(FlSpot(i.toDouble(), (hourlyRequestsMap[i] ?? 0).toDouble()));
      // Масштабируем токены для отображения на том же графике
      hourlyTokenSpots
          .add(FlSpot(i.toDouble(), (hourlyTokensMap[i] ?? 0) / 1000));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Распределение по времени',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // График по часам
          const Text('Активность по часам',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: LineChart(
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
                lineBarsData: [
                  LineChartBarData(
                    spots: hourlyRequestSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: hourlyTokenSpots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 12, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Text('Запросы'),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(width: 12, height: 12, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text('Токены (тыс.)'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Таблица с детальными данными по времени
          const Text('Детальная статистика по часам',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Дата')),
                DataColumn(label: Text('Час')),
                DataColumn(label: Text('Запросы')),
                DataColumn(label: Text('Токены')),
              ],
              rows: hourData.map<DataRow>((item) {
                final id = item['_id'];
                final dateStr =
                    '${id['day'].toString().padLeft(2, '0')}.${id['month'].toString().padLeft(2, '0')}.${id['year']}';
                final hourStr = '${id['hour'].toString().padLeft(2, '0')}:00';

                return DataRow(
                  cells: [
                    DataCell(Text(dateStr)),
                    DataCell(Text(hourStr)),
                    DataCell(Text(numberFormat.format(item['count']))),
                    DataCell(Text(numberFormat.format(item['totalTokens']))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatsTab() {
    final userStats =
        List<Map<String, dynamic>>.from(statisticsData!['userStats']);

    // Сортируем по количеству запросов
    userStats.sort((a, b) =>
        (b['totalRequests'] as int).compareTo(a['totalRequests'] as int));

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Топ пользователей по использованию ИИ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),

        // График топ-5 пользователей
        if (userStats.isNotEmpty)
          Container(
            height: 250,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: userStats.isNotEmpty
                    ? (userStats[0]['totalRequests'] as int) * 1.2
                    : 100,
                // Замените старый код в BarChartData
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    // tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${userStats[groupIndex]['name']}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${numberFormat.format(rod.toY.toInt())} запросов',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 &&
                            index < userStats.length &&
                            index < 5) {
                          final name = userStats[index]['name'] as String;
                          return Transform.rotate(
                            angle: 45 *
                                3.1415926535 /
                                180, // 45 градусов в радианах
                            child: Text(
                              name.length > 8
                                  ? '${name.substring(0, 8)}...'
                                  : name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  userStats.length > 5 ? 5 : userStats.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        // заменить y на toY
                        toY: (userStats[index]['totalRequests'] as int)
                            .toDouble(),
                        // заменить colors на color
                        color: Colors.blue, // или используйте градиент
                        // или если нужен градиент:
                        // color: LinearGradient(
                        //   colors: [Colors.blue, Colors.lightBlueAccent],
                        //   begin: Alignment.bottomCenter,
                        //   end: Alignment.topCenter,
                        // ),
                        width: 22,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(6)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Таблица пользователей
        Expanded(
          child: ListView.builder(
            itemCount: userStats.length,
            itemBuilder: (context, index) {
              final user = userStats[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user['name'].toString().isNotEmpty
                          ? user['name'][0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(user['name'] ?? 'Без имени'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['phoneNumber'] ??
                          user['email'] ??
                          'Нет контактов'),
                      Text(
                        'Запросы: ${numberFormat.format(user['totalRequests'])} • '
                        'Токены: ${numberFormat.format(user['totalTokens'])}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  // В _buildUserStatsTab() метода AdminStatisticsScreen
                  trailing: IconButton(
                    icon: const Icon(Icons.bar_chart),
                    tooltip: 'Подробная статистика',
                    onPressed: () {
                      try {
                        // Безопасное извлечение userId
                        final userId = user['_id'];

                        // Проверка что userId существует и имеет правильный формат
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Ошибка: ID пользователя отсутствует')),
                          );
                          return;
                        }

                        // Преобразуем id в строку, если он ещё не строка
                        final userIdString = userId.toString();

                        print(
                            'Переход к статистике пользователя с ID: $userIdString');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminUserStatisticsScreen(
                              adminService: widget.adminService,
                              userId: userIdString,
                              userName: user['name'] ?? 'Пользователь',
                            ),
                          ),
                        );
                      } catch (e) {
                        print(
                            'Ошибка при навигации к статистике пользователя: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Ошибка при открытии статистики')),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    try {
                      final userId = user['_id'];
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Ошибка: ID пользователя отсутствует')),
                        );
                        return;
                      }

                      final userIdString = userId.toString();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminUserStatisticsScreen(
                            adminService: widget.adminService,
                            userId: userIdString,
                            userName: user['name'] ?? 'Пользователь',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Ошибка при открытии статистики')),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCostAnalysisTab() {
    final planStats = statisticsData!['planStats'];
    final quizStats = statisticsData!['quizStats'];

    // Рассчитываем общую стоимость
    final totalCost = double.parse(planStats['estimatedCost'].toString()) +
        double.parse(quizStats['estimatedCost'].toString());

    // Расчет стоимости за токен
    final planCostPerToken = planStats['totalTokens'] > 0
        ? double.parse(planStats['estimatedCost'].toString()) /
            planStats['totalTokens']
        : 0.0;

    final quizCostPerToken = quizStats['totalTokens'] > 0
        ? double.parse(quizStats['estimatedCost'].toString()) /
            quizStats['totalTokens']
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Анализ затрат на GPT-4o',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Карточка с общей стоимостью
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Общая стоимость',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(totalCost),
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

          const SizedBox(height: 24),

          // Распределение затрат
          const Text('Распределение затрат',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // График распределения затрат
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: double.parse(planStats['estimatedCost'].toString()),
                    title:
                        'План\n${currencyFormat.format(double.parse(planStats['estimatedCost'].toString()))}',
                    color: Colors.blue,
                    radius: 100,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: double.parse(quizStats['estimatedCost'].toString()),
                    title:
                        'Тест\n${currencyFormat.format(double.parse(quizStats['estimatedCost'].toString()))}',
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

          // Таблица с детальной разбивкой затрат
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Детальная разбивка затрат',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatRow(
                      'План (Чат):',
                      currencyFormat.format(
                          double.parse(planStats['estimatedCost'].toString()))),
                  _buildDetailRow('Запросы:',
                      numberFormat.format(planStats['totalRequests'])),
                  _buildDetailRow(
                      'Токены:', numberFormat.format(planStats['totalTokens'])),
                  _buildDetailRow('Стоимость за токен:',
                      currencyFormat.format(planCostPerToken)),
                  const SizedBox(height: 16),
                  _buildStatRow(
                      'Тест (Quiz):',
                      currencyFormat.format(
                          double.parse(quizStats['estimatedCost'].toString()))),
                  _buildDetailRow('Запросы:',
                      numberFormat.format(quizStats['totalRequests'])),
                  _buildDetailRow(
                      'Токены:', numberFormat.format(quizStats['totalTokens'])),
                  _buildDetailRow('Стоимость за токен:',
                      currencyFormat.format(quizCostPerToken)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    'ИТОГО:',
                    currencyFormat.format(totalCost),
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Информация о тарифах OpenAI
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Информация о тарифах',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'Расчеты основаны на официальных тарифах OpenAI для модели GPT-4o:',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text('• \$0.01 за 1K входных токенов (prompt)'),
                  Text('• \$0.03 за 1K выходных токенов (completion)'),
                  SizedBox(height: 8),
                  Text(
                    'Цены могут изменяться. Актуальные тарифы смотрите на сайте OpenAI.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
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

  Widget _buildStatRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
