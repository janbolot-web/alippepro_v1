// Страница календаря и регламента
import 'dart:convert';
import 'dart:ui';

import 'package:alippepro_v1/features/calendar/widgets/event_card.dart';
import 'package:alippepro_v1/models/calendar-models.dart';
import 'package:alippepro_v1/services/section_service.dart';
import 'package:alippepro_v1/services/shedule_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final Function(String, String, String, DateTime) onAddScheduleItem;
  final Function(DateTime) getScheduleItemsForDate;
  final List<ScheduleItem> scheduleItems;
  final Map<DateTime, List<String>> holidays;
  final Function(String, String)? onDeleteTask;

  const CalendarPage({
    super.key,
    required this.onAddScheduleItem,
    required this.getScheduleItemsForDate,
    required this.scheduleItems,
    required this.holidays,
    this.onDeleteTask, // Add this parameter
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<ScheduleItem> _currentScheduleItems = []; // Элементы регламента
  bool _isLoading = false;
  final ScheduleService _scheduleService =
      ScheduleService(); // Добавляем сервис для расписания
  final SectionService _sectionService =
      SectionService(); // Сервис для разделов и задач

  // Добавьте в класс _CalendarPageState
  Map<String, int> _userOrderMap =
      {}; // Ключ - ID элемента, значение - порядковый номер
  bool _hasCustomOrder =
      false; // Флаг, показывающий, менял ли пользователь порядок
  final ScrollController _scrollController = ScrollController();

  final List<String> weekdaysShort = [
    'дүй',
    'шей',
    'шар',
    'бей',
    'жум',
    'шар',
    'жек'
  ];

  final Map<int, String> dayNamesKyrgyz = {
    1: 'Дүйшөмбү',
    2: 'Шейшемби',
    3: 'Шаршемби',
    4: 'Бейшемби',
    5: 'Жума',
    6: 'Ишемби',
    7: 'Жекшемби',
  };

  // Текущие элементы расписания для выбранной даты
  List<ScheduleItem> _currentItems = [];
  List<ScheduleItem> _allScheduleItems = []; // Все элементы регламента

  @override
  void initState() {
    super.initState();
    _loadAllScheduleItems(); // Загружаем все регламенты сразу
    _updateCurrentItems(); // Затем обновляем текущие элементы для выбранной даты
  }

  // Метод для загрузки всех регламентов
  Future<void> _loadAllScheduleItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем все регламенты через сервис
      final allSchedules = await _scheduleService.getAllScheduleItems();

      setState(() {
        _allScheduleItems = allSchedules;
        _isLoading = false;
      });

      // После загрузки всех данных, обновляем элементы для текущей даты
      _updateCurrentItemsForSelectedDay();
    } catch (e) {
      print('Ошибка при загрузке регламентов: $e');
      setState(() {
        _isLoading = false;
        _allScheduleItems = [];
      });
    }
  }

  // Обновляем текущие элементы для выбранной даты
  void _updateCurrentItemsForSelectedDay() async {
    // Сначала загружаем сохраненный порядок для текущей даты
    await _loadUserOrder();

    setState(() {
      // Фильтруем элементы регламента для выбранной даты
      _currentScheduleItems = _allScheduleItems
          .where((item) => isSameDay(item.date, _selectedDay))
          .toList();

      // Получаем задачи из разделов
      _currentItems = widget.getScheduleItemsForDate(_selectedDay);
    });
  }

  // Обновляем список текущих элементов при изменении даты
  void _updateCurrentItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем задачи из разделов
      final tasks = widget.getScheduleItemsForDate(_selectedDay);

      // Получаем элементы регламента через сервис
      final scheduleItems =
          await _scheduleService.getScheduleByDate(_selectedDay);

      setState(() {
        _currentItems = tasks.where((item) => item.isTask).toList();
        _currentScheduleItems = scheduleItems;
        _isLoading = false;
      });
      _updateCurrentItemsForSelectedDay();
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
      setState(() {
        _isLoading = false;

        // В случае ошибки используем только локальные данные
        _currentItems = widget.getScheduleItemsForDate(_selectedDay);
        _currentScheduleItems = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Фиксированные элементы вверху
        _buildCalendarHeader(),
        _buildTableCalendar(),
        _buildRegulationHeader(),
        _buildDayNavigation(),

        // Прокручиваемая часть
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScheduleItems(),
                _buildAddButton(),
                SizedBox(
                  height: 25,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    // Используем сфокусированный день вместо текущей даты
    // _focusedDay содержит месяц, который отображается на экране
    final DateTime displayedDate = _focusedDay;

    // Список месяцев на кыргызском
    final List<String> months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];

    // Формируем строку с годом и месяцем текущего просматриваемого месяца
    final String formattedDateYear = '${displayedDate.year} ';
    final String formattedDateMonth = months[displayedDate.month - 1];

    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 44, 24, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedDateYear,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C313A),
              ),
            ),
            Text(
              formattedDateMonth,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C313A),
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTableCalendar() {
    // Используем текущую системную дату как "сегодня"
    final today = DateTime.now();

    return Stack(
      children: [
        // Фоновый текст с годом
        Positioned.fill(
          child: Center(
            child: Text(
              today.year.toString(),
              style: GoogleFonts.montserrat(
                fontSize: 100,
                fontWeight: FontWeight.w900,
                color: const Color(0xff1B434D).withOpacity(0.10),
              ),
            ),
          ),
        ),
        // Сам календарь
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xff1B434D).withOpacity(0.60),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xff1B434D), width: 1),
          ),
          child: TableCalendar(
            firstDay: DateTime(2024),
            lastDay: DateTime(2026),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            daysOfWeekHeight: 20, // Уменьшаем высоту строки с днями недели
            rowHeight: 36, // Уменьшаем высоту строк календаря
            holidayPredicate: (day) {
              // Проверяем, является ли день праздничным
              return widget.holidays.keys
                  .any((holiday) => isSameDay(holiday, day));
            },
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  GoogleFonts.montserrat(color: Colors.white, fontSize: 12),
              weekendStyle:
                  GoogleFonts.montserrat(color: Colors.white, fontSize: 12),
              dowTextFormatter: (date, locale) {
                return weekdaysShort[date.weekday - 1];
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
              titleTextStyle: TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
              headerMargin: EdgeInsets.only(
                  bottom: 4), // Уменьшаем нижний отступ заголовка
              headerPadding: EdgeInsets.all(0),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white),
              outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              // Настраиваем стиль для сегодняшнего дня
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.transparent,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              holidayTextStyle: const TextStyle(
                color: Color(0xFFFF9800),
                fontWeight: FontWeight.bold,
              ),
              markersMaxCount: 0,
              cellMargin: const EdgeInsets.all(2), // Уменьшаем отступы ячеек
              cellPadding: EdgeInsets.zero, // Убираем внутренние отступы ячеек
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            // В методе onDaySelected добавьте сброс пользовательского порядка при смене даты
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                // Сбрасываем пользовательский порядок при смене даты
                _hasCustomOrder = false;
                _userOrderMap.clear();
                _updateCurrentItemsForSelectedDay();
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                // Проверяем, является ли день праздничным
                final isHoliday = widget.holidays.keys
                    .any((holiday) => isSameDay(holiday, day));

                if (isHoliday) {
                  return Center(
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                // Проверяем, является ли день сегодняшним
                if (isSameDay(day, today)) {
                  return Center(
                    child: Container(
                      width: 28, // Уменьшаем размер контейнера
                      height: 28, // Уменьшаем размер контейнера
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13, // Уменьшаем размер шрифта
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return null;
              },
              // Настраиваем отображение сегодняшнего дня
              todayBuilder: (context, day, focusedDay) {
                return Center(
                  child: Container(
                    width: 28, // Уменьшаем размер контейнера
                    height: 28, // Уменьшаем размер контейнера
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13, // Уменьшаем размер шрифта
                        ),
                      ),
                    ),
                  ),
                );
              },
              // Делаем более компактный внешний вид для выбранного дня
              selectedBuilder: (context, day, focusedDay) {
                return Center(
                  child: Container(
                    width: 28, // Уменьшаем размер контейнера
                    height: 28, // Уменьшаем размер контейнера
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13, // Уменьшаем размер шрифта
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegulationHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Менин',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: const Color(0xffAC046A),
            ),
          ),
          Text(
            'РЕГЛАМЕНТИМ',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xff1B434D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayNavigation() {
    String displayedDayName =
        dayNamesKyrgyz[_selectedDay.weekday] ?? 'Бейшемби';

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 14, color: Color(0xFF1C313A)),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                _focusedDay = _selectedDay;

                // Используем метод _updateCurrentItemsForSelectedDay вместо _updateCurrentItems
                _updateCurrentItemsForSelectedDay();

                // Сбрасываем пользовательский порядок при смене даты
                _hasCustomOrder = false;
                _userOrderMap.clear();
              });
            },
          ),
          Text(
            displayedDayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C313A),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFF1C313A)),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.add(const Duration(days: 1));
                _focusedDay = _selectedDay;

                // Используем метод _updateCurrentItemsForSelectedDay вместо _updateCurrentItems
                _updateCurrentItemsForSelectedDay();

                // Сбрасываем пользовательский порядок при смене даты
                _hasCustomOrder = false;
                _userOrderMap.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItems() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Объединенный список всех элементов для отображения
    List<dynamic> allItems = [];

    // Проверка на пустой список
    if (_currentItems.isEmpty && _currentScheduleItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                '${DateFormat('dd.MM.yyyy').format(_selectedDay)} үчүн сабактар жок',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Добавляем задачи и элементы регламента в общий список
    allItems.addAll(_currentItems);
    allItems.addAll(_currentScheduleItems);

    // Сортируем по времени
    allItems.sort((a, b) {
      // Если пользователь изменил порядок, используем его настройки
      if (_hasCustomOrder) {
        // Получаем порядковые номера (или большое число, если элемент новый)
        final orderA = _userOrderMap[a.id] ?? 999999;
        final orderB = _userOrderMap[b.id] ?? 999999;

        // Сначала сортируем по пользовательскому порядку
        if (orderA != orderB) {
          return orderA.compareTo(orderB);
        }
      }

      // Если порядок не задан или элементы имеют одинаковый порядок,
      // сортируем по времени (как раньше)
      final timeA = _parseTimeString(a.time);
      final timeB = _parseTimeString(b.time);
      return timeA.compareTo(timeB);
    });

    // Отображаем все элементы в ReorderableListView
    return Scrollable(
      axisDirection: AxisDirection.down,
      controller: PrimaryScrollController.of(context),
      physics: const AlwaysScrollableScrollPhysics(),
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return ReorderableListView.builder(
          shrinkWrap: true,
          // Убираем физику, которая блокирует скролл
          physics: const ClampingScrollPhysics(),
          proxyDecorator: _proxyDecorator,
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            final item = allItems[index];
            final bool isTask =
                item is Task || (item is ScheduleItem && item.isTask);

            return AnimatedContainer(
                key: ValueKey(item.id),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: _buildDragItemDecoration(index),
                child: isTask
                    ? Column(
                        children: [
                          _buildSimpleEventCard(item, index),
                          SizedBox(
                            height: 5,
                          )
                        ],
                      )
                    : Column(
                        children: [
                          _buildSimpleScheduleCard(item, index),
                          SizedBox(
                            height: 5,
                          )
                        ],
                      ));
          },
          // В обработчике onReorder
          onReorder: (oldIndex, newIndex) {
            HapticFeedback.mediumImpact(); // Добавляем вибрацию при перемещении

            setState(() {
              // Корректируем индекс при перемещении элемента вниз
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }

              // Получаем элемент, который перемещаем
              final item = allItems.removeAt(oldIndex);

              // Вставляем элемент на новую позицию
              allItems.insert(newIndex, item);

              // Устанавливаем флаг пользовательского порядка
              _hasCustomOrder = true;

              // Обновляем Map с пользовательским порядком
              for (int i = 0; i < allItems.length; i++) {
                _userOrderMap[allItems[i].id] = i;
              }

              // Обновляем порядок в исходных списках
              _updateItemsOrder(allItems);
            });

            // Сохраняем пользовательский порядок после изменения
            _saveUserOrder();

            // Показываем визуальную обратную связь
            _showDragCompleteFeedback(context);
          },
        );
      },
    );
  }

  // Декоратор для создания эффекта при перетаскивании
  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.2),
          child: child,
        );
      },
      child: child,
    );
  }

  // Декорация для элементов списка
  BoxDecoration _buildDragItemDecoration(int index) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Показываем финальную обратную связь после завершения перетаскивания
  void _showDragCompleteFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.done, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              "Тапшырмалардын тартиби сакталды",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff1B434D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Упрощенные карточки без вложенных GestureDetector/InkWell
// Обновленный метод для создания анимированной карточки события с индикатором загрузки

  Set<String> _deletingTaskIds = {};
  Set<String> _deletingScheduleIds = {};

// In _buildSimpleEventCard, add onTap handler inside the Slidable widget:
  Widget _buildSimpleEventCard(dynamic item, int index) {
    final bool isTaskLoading = _loadingTaskIds.contains(item.id);
    final bool isDeleting = _deletingTaskIds.contains(item.id);

    return Slidable(
      key: ValueKey('task-${item.id}-${item.completed}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteTask(item),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Өчүрүү',
          ),
        ],
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _showEditTaskDialog(context, item),
            child: EventCard(
              title: item.subject,
              date: item.date,
              timeRange: item.time,
              isCompleted:
                  item is Task ? item.completed : (item.completed ?? false),
              taskId: item.id,
              isLoading: isTaskLoading,
              onCheckChanged: (bool? value, String taskId) {
                _updateTaskCompletionStatus(taskId, value ?? false);
              },
            ),
          ),
          if (isDeleting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

// 2. Now add the edit dialog for schedule items (lessons)
  void _showEditScheduleItemDialog(BuildContext context, ScheduleItem item) {
    // Extract time range parts
    String timeStart = "08:00";
    String timeEnd = "08:45";

    if (item.time.contains('-')) {
      final parts = item.time.split('-');
      timeStart = parts[0].trim();
      timeEnd = parts.length > 1 ? parts[1].trim() : "08:45";
    }

    final TextEditingController timeStartController =
        TextEditingController(text: timeStart);
    final TextEditingController timeEndController =
        TextEditingController(text: timeEnd);
    final TextEditingController subjectController =
        TextEditingController(text: item.subject);

    // Extract class from classInfo
    String selectedClass = '1-класс';
    if (item.classInfo.isNotEmpty) {
      // Try to find a match in the class list
      selectedClass = item.classInfo;
    }

    // Список классов для выбора
    final List<String> classList = [
      '1-класс',
      '2-класс',
      '3-класс',
      '4-класс',
      '5-класс',
      '6-класс',
      '7-класс',
      '8-класс',
      '9-класс',
      '10-класс',
      '11-класс',
      '12-класс',
    ];

    // Ensure the selected class is in the list
    if (!classList.contains(selectedClass)) {
      classList.add(selectedClass);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff1B434D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_calendar,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Расписаниени оңдоо',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1B434D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Время занятия
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Башталышы',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1B434D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: _parseTimeOfDay(timeStart),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xff1B434D),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Color(0xff1B434D),
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  timeStartController.text =
                                      '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    timeStartController.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Icon(Icons.access_time,
                                      color: Color(0xff1B434D), size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Аягы',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1B434D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: _parseTimeOfDay(timeEnd),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xff1B434D),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Color(0xff1B434D),
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  timeEndController.text =
                                      '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    timeEndController.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Icon(Icons.access_time,
                                      color: Color(0xff1B434D), size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Название предмета
                const Text(
                  'Сабактын аталышы',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1B434D),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    hintText: 'Мисалы: Алгебра',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    prefixIcon:
                        const Icon(Icons.book, color: Color(0xff1B434D)),
                  ),
                ),
                const SizedBox(height: 16),

                // Выбор класса
                const Text(
                  'Класс',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1B434D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedClass,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xff1B434D)),
                    items: classList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedClass = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Кнопки действий
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Кнопка отмены
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text(
                        'Жокко чыгаруу',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Кнопка обновления
                    ElevatedButton(
                      onPressed: () {
                        final timeStart = timeStartController.text.trim();
                        final timeEnd = timeEndController.text.trim();
                        final subject = subjectController.text.trim();
                        final timeRange = '$timeStart - $timeEnd';

                        if (subject.isNotEmpty) {
                          Navigator.pop(context); // Закрываем диалог

                          // Обновляем элемент расписания
                          _updateScheduleItem(
                            context,
                            id: item.id,
                            subject: subject,
                            classInfo: selectedClass,
                            timeRange: timeRange,
                            date: item.date,
                          );
                        } else {
                          // Показываем сообщение об ошибке, если не заполнено название предмета
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Предметтин атын киргизиңиз'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1B434D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Сактоо',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// 3. Add the edit dialog for tasks

  void _showEditTaskDialog(BuildContext context, dynamic item) {
    final String title = item is Task ? item.title : item.subject;
    final DateTime date = item.date;
    final String timeRange = item.time;
    final bool isUrgent = item is Task ? item.isUrgent : false;

    // Extract start and end times from the time range
    String timeStart = "08:00";
    String timeEnd = "08:45";

    if (timeRange.contains('-')) {
      final parts = timeRange.split('-');
      timeStart = parts[0].trim();
      timeEnd = parts.length > 1 ? parts[1].trim() : "08:45";
    }

    final TextEditingController titleController =
        TextEditingController(text: title);
    final TextEditingController timeStartController =
        TextEditingController(text: timeStart);
    final TextEditingController timeEndController =
        TextEditingController(text: timeEnd);

    DateTime selectedDate = date;
    bool isTaskUrgent = isUrgent;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff1B434D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_note,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Тапшырманы оңдоо',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1B434D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Название задачи
                const Text(
                  'Тапшырманын аталышы',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1B434D),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Тапшырманын аталышын жазыңыз',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    prefixIcon:
                        const Icon(Icons.assignment, color: Color(0xff1B434D)),
                  ),
                ),
                const SizedBox(height: 16),

                // Дата
                // const Text(
                //   'Күн',
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //     color: Color(0xff1B434D),
                //   ),
                // ),
                // const SizedBox(height: 8),
                // InkWell(
                //   onTap: () async {
                //     final DateTime? pickedDate = await showDatePicker(
                //       context: context,
                //       initialDate: selectedDate,
                //       firstDate: DateTime(2024),
                //       // Change this line to extend the date range:
                //       lastDate: DateTime(20206), // Change from 2025 to 2030
                //       // locale: const Locale('ky'),
                //       builder: (context, child) {
                //         return Theme(
                //           data: Theme.of(context).copyWith(
                //             colorScheme: const ColorScheme.light(
                //               primary: Color(0xff1B434D),
                //               onPrimary: Colors.white,
                //               surface: Colors.white,
                //               onSurface: Color(0xff1B434D),
                //             ),
                //             dialogBackgroundColor: Colors.white,
                //           ),
                //           child: child!,
                //         );
                //       },
                //     );

                //     if (pickedDate != null) {
                //       setState(() {
                //         selectedDate = pickedDate;
                //       });
                //     }
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 12, vertical: 12),
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.grey),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           DateFormat('dd.MM.yyyy').format(selectedDate),
                //           style: const TextStyle(
                //             fontSize: 16,
                //             color: Color(0xff1B434D),
                //           ),
                //         ),
                //         const Icon(Icons.calendar_today,
                //             color: Color(0xff1B434D), size: 16),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),

                // Время (Start and End)
                const Text(
                  'Убакыт',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1B434D),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Башталышы',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1B434D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: _parseTimeOfDay(timeStart),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xff1B434D),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Color(0xff1B434D),
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  timeStartController.text =
                                      '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    timeStartController.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Icon(Icons.access_time,
                                      color: Color(0xff1B434D), size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Аякташы',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1B434D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: _parseTimeOfDay(timeEnd),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xff1B434D),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Color(0xff1B434D),
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  timeEndController.text =
                                      '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    timeEndController.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Icon(Icons.access_time,
                                      color: Color(0xff1B434D), size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Срочность
                // Row(
                //   children: [
                //     Checkbox(
                //       value: isTaskUrgent,
                //       activeColor: const Color(0xff1B434D),
                //       onChanged: (bool? value) {
                //         setState(() {
                //           isTaskUrgent = value ?? false;
                //         });
                //       },
                //     ),
                //     const Text(
                //       'Шашылыш тапшырма',
                //       style: TextStyle(
                //         fontSize: 16,
                //         color: Color(0xff1B434D),
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 24),

                // Кнопки действий
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Кнопка отмены
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text(
                        'Жокко чыгаруу',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Кнопка обновления
                    ElevatedButton(
                      onPressed: () {
                        final taskTitle = titleController.text.trim();
                        final taskTimeStart = timeStartController.text.trim();
                        final taskTimeEnd = timeEndController.text.trim();
                        final timeRange = '$taskTimeStart - $taskTimeEnd';

                        if (taskTitle.isNotEmpty) {
                          Navigator.pop(context); // Закрываем диалог

                          // Получаем ID секции из задачи
                          final String sectionId = item is Task
                              ? item.sectionId
                              : (item.sectionId ?? '');

                          // Обновляем задачу
                          _updateTask(
                            context,
                            id: item.id,
                            sectionId: sectionId,
                            title: taskTitle,
                            date: selectedDate,
                            time: timeRange,
                            isUrgent: isTaskUrgent,
                          );
                        } else {
                          // Показываем сообщение об ошибке если название пустое
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Тапшырманын атын киргизиңиз'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1B434D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Сактоо',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// In _buildSimpleScheduleCard, add onTap handler:
  Widget _buildSimpleScheduleCard(ScheduleItem item, int index) {
    final bool isDeleting = _deletingScheduleIds.contains(item.id);

    return Slidable(
      key: ValueKey('schedule-$index-${item.id}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteScheduleItem(item),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Өчүрүү',
          ),
        ],
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _showEditScheduleItemDialog(context, item),
            child: Container(
              margin: const EdgeInsets.only(bottom: 0),
              child: _buildScheduleItemCard(item),
            ),
          ),
          if (isDeleting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

// 4. Helper function to parse time string to TimeOfDay
  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.trim().split(':');
    int hour = 8; // Default values
    int minute = 0;

    if (parts.length >= 1) {
      try {
        hour = int.parse(parts[0]);
      } catch (e) {
        print('Error parsing hour: $e');
      }
    }

    if (parts.length >= 2) {
      try {
        // Handle cases where the minute part might contain additional text
        final minutePart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        minute = int.parse(minutePart);
      } catch (e) {
        print('Error parsing minute: $e');
      }
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

// 5. Add update methods for both types of items
// Update schedule item
  Future<void> _updateScheduleItem(
    BuildContext context, {
    required String id,
    required String subject,
    required String classInfo,
    required String timeRange,
    required DateTime date,
  }) async {
    final BuildContext contextToUse = context;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update schedule item through service
      final ScheduleItem updatedItem =
          await _scheduleService.updateScheduleItem(
        id: id,
        subject: subject,
        classInfo: classInfo,
        timeRange: timeRange,
        date: date,
      );

      // Update item in local lists
      setState(() {
        // Update in all schedule items
        final allIndex = _allScheduleItems.indexWhere((item) => item.id == id);
        if (allIndex != -1) {
          _allScheduleItems[allIndex] = updatedItem;
        }

        // Update in current schedule items if it's the selected day
        if (isSameDay(date, _selectedDay)) {
          final currentIndex =
              _currentScheduleItems.indexWhere((item) => item.id == id);
          if (currentIndex != -1) {
            _currentScheduleItems[currentIndex] = updatedItem;
          }
        }

        _isLoading = false;
      });

      // Show success message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (contextToUse.mounted) {
          ScaffoldMessenger.of(contextToUse).showSnackBar(
            const SnackBar(
              content: Text('Сабак ийгиликтүү жаңыртылды'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });

      // Show error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (contextToUse.mounted) {
          ScaffoldMessenger.of(contextToUse).showSnackBar(
            SnackBar(
              content: Text('Жаңыртууда ката кетти: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

// Update task

  Future<void> _updateTask(
    BuildContext context, {
    required String id,
    required String sectionId,
    required String title,
    required DateTime date,
    required String time,
    required bool isUrgent,
  }) async {
    final BuildContext contextToUse = context;

    setState(() {
      _isLoading = true;

      // Apply changes to local state immediately for better user experience
      final currentIndex = _currentItems.indexWhere((item) => item.id == id);
      if (currentIndex != -1) {
        final currentItem = _currentItems[currentIndex];
        if (currentItem is ScheduleItem) {
          _currentItems[currentIndex] = currentItem.copyWith(
            subject: title,
            date: date,
            time: time,
          );
        }
      }
    });

    try {
      // If sectionId is empty, it might be a schedule task, not a section task
      if (sectionId.isEmpty) {
        // Update as a schedule item through schedule service
        final ScheduleItem updatedItem =
            await _scheduleService.updateScheduleItem(
          id: id,
          subject: title,
          classInfo: '',
          timeRange: time,
          date: date,
          isTask: true,
          isUrgent: isUrgent,
        );

        // Update in local lists
        setState(() {
          // Update in all schedule items
          final allIndex =
              _allScheduleItems.indexWhere((item) => item.id == id);
          if (allIndex != -1) {
            _allScheduleItems[allIndex] = updatedItem;
          }

          // Update in current items
          final currentIndex =
              _currentItems.indexWhere((item) => item.id == id);
          if (currentIndex != -1) {
            _currentItems[currentIndex] = updatedItem;
          }
        });
      } else {
        // Add a small delay to make the loading state visible
        await Future.delayed(const Duration(milliseconds: 100));

        // Update as a section task through section service
        final updatedSection = await _sectionService.updateTask(
          sectionId,
          id,
          title,
          date,
          time,
          isUrgent,
        );

        // Now updatedSection is a Section object
        // Find the updated task in the section
        Task? updatedTask;
        for (var task in updatedSection.tasks) {
          if (task.id == id) {
            updatedTask = task;
            break;
          }
        }

        setState(() {
          // If we found the updated task, update the local UI
          if (updatedTask != null) {
            final currentIndex =
                _currentItems.indexWhere((item) => item.id == id);
            if (currentIndex != -1) {
              _currentItems[currentIndex] = ScheduleItem.fromTask(updatedTask);
            }
          }
        });
      }

      setState(() {
        _isLoading = false;
      });

      // Show success message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (contextToUse.mounted) {
          ScaffoldMessenger.of(contextToUse).showSnackBar(
            const SnackBar(
              content: Text('Тапшырма ийгиликтүү жаңыртылды'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });

      // REMOVE THIS LINE - it's overriding your updates with potentially stale data
      // _updateCurrentItemsForSelectedDay();
    } catch (e) {
      // Handle error
      print('Error updating task: $e');

      setState(() {
        _isLoading = false;
      });

      // Show error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (contextToUse.mounted) {
          ScaffoldMessenger.of(contextToUse).showSnackBar(
            SnackBar(
              content: Text('Жаңыртууда ката кетти: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });

      // Also refresh the items list to ensure consistency
      _updateCurrentItemsForSelectedDay();
    }
  }

  Future<void> _deleteTask(dynamic item) async {
    final String id = item.id;
    final String sectionId =
        item is Task ? item.sectionId : (item.sectionId ?? '');
    final String title = item is Task ? item.title : item.subject;

    // Confirm deletion with a styled dialog similar to _showAddScheduleItemDialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Тапшырманы өчүрүү',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1B434D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Подтверждение
              Text(
                '\"$title\" тапшырмасын өчүрүүнү каалайсызбы?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff1B434D),
                ),
              ),
              const SizedBox(height: 24),

              // Кнопки действий
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Кнопка отмены
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                    child: const Text(
                      'Жокко чыгаруу',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Кнопка удаления
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Өчүрүү',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // If confirmed, proceed with deletion
    if (confirm == true) {
      try {
        setState(() {
          _deletingTaskIds.add(id);
        });

        bool success = false;

        // Check if it's a section task or schedule task
        if (sectionId.isNotEmpty) {
          // If we have the onDeleteTask callback, use it for section tasks
          if (widget.onDeleteTask != null) {
            await widget.onDeleteTask!(sectionId, id);
            success = true;
          } else {
            // Fallback to direct service call if callback not provided
            success = await _sectionService.deleteTask(sectionId, id);
          }
        } else {
          // For schedule items, still use the schedule service
          success = await _scheduleService.deleteScheduleItem(id);
        }

        if (success) {
          setState(() {
            // Create new lists instead of modifying in place
            _currentItems =
                _currentItems.where((task) => task.id != id).toList();
            _currentScheduleItems =
                _currentScheduleItems.where((item) => item.id != id).toList();
            _allScheduleItems =
                _allScheduleItems.where((item) => item.id != id).toList();

            // Remove from user order if it exists
            _userOrderMap.remove(id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Тапшырма \"$title\" ийгиликтүү өчүрүлдү'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Error handling remains the same...
      } finally {
        setState(() {
          _deletingTaskIds.remove(id);
        });
      }
    }
  }

  Future<void> _deleteScheduleItem(ScheduleItem item) async {
    // Confirm deletion with styled dialog matching the add dialog style
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Расписаниени өчүрүү',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1B434D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Подтверждение
              Text(
                '\"${item.subject}\" предметин расписаниеден өчүрүүнү каалайсызбы?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff1B434D),
                ),
              ),
              const SizedBox(height: 24),

              // Кнопки действий
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Кнопка отмены
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                    child: const Text(
                      'Жокко чыгаруу',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Кнопка удаления
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Өчүрүү',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // If confirmed, proceed with deletion
    if (confirm == true) {
      try {
        setState(() {
          _deletingScheduleIds.add(item.id);
        });

        final success = await _scheduleService.deleteScheduleItem(item.id);

        if (success) {
          // Immediately update local UI state
          setState(() {
            // Remove item from current schedule items
            _currentScheduleItems
                .removeWhere((scheduleItem) => scheduleItem.id == item.id);

            // Also remove from all schedule items list
            _allScheduleItems
                .removeWhere((scheduleItem) => scheduleItem.id == item.id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Предмет \"${item.subject}\" ийгиликтүү өчүрүлдү'),
              backgroundColor: Colors.green,
            ),
          );

          // Still call this to ensure everything is in sync
          _updateCurrentItemsForSelectedDay();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Өчүрүү учурунда ката кетти: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _deletingScheduleIds.remove(item.id);
        });
      }
    }
  }

  // Виджет для карточки регламента с анимацией и стилем
  Widget _buildScheduleItemCard(ScheduleItem item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          // Time slot
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Text(
              textAlign: TextAlign.center,
              item.time,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xff1B434D),
              ),
            ),
          ),
          SizedBox(
            width: 2,
          ),
          // Subject name - center expanded area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                item.subject,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xff1B434D),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 2,
          ),
          // Class info (grade)
          Container(
            width: MediaQuery.of(context).size.width * 0.135,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(
              item.classInfo.contains("-кл")
                  ? item.classInfo
                      .substring(0, item.classInfo.indexOf("-кл") + 3)
                  : item.classInfo,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xff1B434D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this to your _CalendarPageState class declaration
  Set<String> _loadingTaskIds = {}; // Track which tasks are currently loading

// Обработка изменения статуса завершения задачи с локализованной загрузкой
  Future<void> _updateTaskCompletionStatus(
      String taskId, bool completed) async {
    // Немедленно обновляем UI для лучшего UX
    setState(() {
      // Добавляем ID задачи в список загружаемых
      _loadingTaskIds.add(taskId);

      // Обновляем состояние задачи в _currentItems
      for (int i = 0; i < _currentItems.length; i++) {
        if (_currentItems[i].id == taskId) {
          if (_currentItems[i] is ScheduleItem) {
            // Используем copyWith вместо создания нового объекта
            _currentItems[i] = (_currentItems[i] as ScheduleItem).copyWith(
              completed: completed,
              completedAt: completed ? DateTime.now() : null,
            );
          }
          break;
        }
      }

      // Также обновляем в _currentScheduleItems, если задача там есть
      for (int i = 0; i < _currentScheduleItems.length; i++) {
        if (_currentScheduleItems[i].id == taskId) {
          _currentScheduleItems[i] = _currentScheduleItems[i].copyWith(
            completed: completed,
            completedAt: completed ? DateTime.now() : null,
          );
          break;
        }
      }
    });

    try {
      // Ищем задачу в списке текущих элементов
      bool taskFound = false;
      String? sectionId;

      // Проверяем в текущих задачах
      for (int i = 0; i < _currentItems.length; i++) {
        if (_currentItems[i].id == taskId) {
          // Если нашли в текущих элементах
          if (_currentItems[i] is ScheduleItem) {
            ScheduleItem item = _currentItems[i] as ScheduleItem;
            sectionId = item.sectionId;

            if (sectionId != null) {
              // Обновляем статус в API через сервис
              await _sectionService.updateTaskCompletionStatus(
                sectionId,
                taskId,
                completed,
              );
              taskFound = true;
              break;
            } else if (item.isTask) {
              // Если это задача из расписания
              await _scheduleService.updateScheduleItemCompletionStatus(
                taskId,
                completed,
              );
              taskFound = true;
              break;
            }
          }
        }
      }

      // Если задача не найдена в текущих элементах, проверяем в расписании
      if (!taskFound) {
        for (int i = 0; i < _currentScheduleItems.length; i++) {
          if (_currentScheduleItems[i].id == taskId) {
            await _scheduleService.updateScheduleItemCompletionStatus(
              taskId,
              completed,
            );
            taskFound = true;
            break;
          }
        }
      }

      // Если все еще не нашли задачу, пробуем найти в секциях
      if (!taskFound) {
        // Получаем все секции
        final sections = await _sectionService.getAllSections();

        for (var section in sections) {
          for (var task in section.tasks) {
            if (task.id == taskId) {
              // Обновляем статус через API
              await _sectionService.updateTaskCompletionStatus(
                section.id,
                taskId,
                completed,
              );
              taskFound = true;
              break;
            }
          }
          if (taskFound) break;
        }
      }

      // Показываем уведомление об успехе
      if (taskFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  completed ? 'Тапшырма аткарылды' : 'Тапшырма аткарылган жок',
                  style: GoogleFonts.montserrat(),
                ),
              ],
            ),
            backgroundColor: const Color(0xff1B434D),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Если задача не найдена, показываем ошибку
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Тапшырма табылган жок'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Показываем ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Статусту жаңыртууда ката кетти: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // В случае ошибки возвращаем UI в предыдущее состояние
      setState(() {
        // Возвращаем состояние задачи обратно
        for (int i = 0; i < _currentItems.length; i++) {
          if (_currentItems[i].id == taskId &&
              _currentItems[i] is ScheduleItem) {
            _currentItems[i] = (_currentItems[i] as ScheduleItem).copyWith(
              completed: !completed, // Инвертируем обратно
              completedAt: !completed ? DateTime.now() : null,
            );
          }
        }

        for (int i = 0; i < _currentScheduleItems.length; i++) {
          if (_currentScheduleItems[i].id == taskId) {
            _currentScheduleItems[i] = _currentScheduleItems[i].copyWith(
              completed: !completed, // Инвертируем обратно
              completedAt: !completed ? DateTime.now() : null,
            );
          }
        }
      });
    } finally {
      // Удаляем ID задачи из списка загружаемых
      setState(() {
        _loadingTaskIds.remove(taskId);
      });
    }
  }

  // Обновленный метод _buildAddButton с более компактной кнопкой
  Widget _buildAddButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8), // Уменьшенные отступы
      child: GestureDetector(
        onTap: () {
          _showAddScheduleItemDialog(context);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Регламент кошуу',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C313A),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.add,
              size: 16,
              color: Color(0xFF1C313A),
            ),
          ],
        ),
      ),
    );
  }

  // Показываем диалог для добавления нового элемента в расписание
  // Показываем диалог для добавления нового элемента в расписание на кыргызском
  void _showAddScheduleItemDialog(BuildContext context) {
    final TextEditingController timeStartController =
        TextEditingController(text: "08:00");
    final TextEditingController timeEndController =
        TextEditingController(text: "08:45");
    final TextEditingController subjectController = TextEditingController();

    // Выбранная дата (текущая выбранная, но скрыта от пользователя)
    DateTime selectedDate = _selectedDay;

    // Предустановленные значения времени для быстрого выбора
    final List<String> quickTimeSlots = [
      '08:00 - 08:45',
      '08:55 - 09:40',
      '09:50 - 10:35',
      '10:45 - 11:30',
      '11:40 - 12:25',
      '12:35 - 13:20',
      '13:30 - 14:15',
      '14:25 - 15:10',
      '15:20 - 16:05',
      'Башка...' // Option for custom time
    ];

    // Выбранный временной слот
    String selectedTimeSlot = quickTimeSlots[0];

    // Флаг для отслеживания пользовательского времени
    bool isCustomTime = false;

    // Выбранный класс (по умолчанию первый)
    String selectedClass = '1-класс';

    // Список классов для выбора
    final List<String> classList = [
      '1-класс',
      '2-класс',
      '3-класс',
      '4-класс',
      '5-класс',
      '6-класс',
      '7-класс',
      '8-класс',
      '9-класс',
      '10-класс',
      '11-класс',
      '12-класс',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff1B434D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.event_note,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Расписаниеге сабак кошуу',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1B434D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Время занятия - выбор из предустановленных слотов

                // Пользовательское время (видимо только если выбран "Башка...")
                AnimatedOpacity(
                  opacity: isCustomTime || selectedTimeSlot == 'Башка...'
                      ? 1.0
                      : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Башталышы',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1B434D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xff1B434D),
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Color(0xff1B434D),
                                        ),
                                        dialogBackgroundColor: Colors.white,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedTime != null) {
                                  setState(() {
                                    isCustomTime = true;
                                    selectedTimeSlot = 'Башка...';
                                    timeStartController.text =
                                        '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      timeStartController.text,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Icon(Icons.access_time,
                                        color: Color(0xff1B434D), size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Аягы',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1B434D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xff1B434D),
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Color(0xff1B434D),
                                        ),
                                        dialogBackgroundColor: Colors.white,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedTime != null) {
                                  setState(() {
                                    isCustomTime = true;
                                    selectedTimeSlot = 'Башка...';
                                    timeEndController.text =
                                        '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      timeEndController.text,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Icon(Icons.access_time,
                                        color: Color(0xff1B434D), size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Название предмета
                const Text(
                  'Сабактын аталышы',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1B434D),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    hintText: 'Мисалы: Алгебра',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    prefixIcon:
                        const Icon(Icons.book, color: Color(0xff1B434D)),
                  ),
                ),
                const SizedBox(height: 16),

                // Выбор класса
                const Text(
                  'Класс',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1B434D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedClass,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xff1B434D)),
                    items: classList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedClass = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Кнопки действий
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Кнопка отмены
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text(
                        'Жокко чыгаруу',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Кнопка добавления
                    ElevatedButton(
                      onPressed: () {
                        final timeStart = timeStartController.text.trim();
                        final timeEnd = timeEndController.text.trim();
                        final subject = subjectController.text.trim();
                        final timeRange = '$timeStart - $timeEnd';

                        if (subject.isNotEmpty) {
                          Navigator.pop(context); // Закрываем диалог

                          // Используем новый метод для добавления расписания
                          _addScheduleItem(
                            context,
                            subject: subject,
                            classInfo: selectedClass,
                            timeRange: timeRange,
                            date: selectedDate,
                          );
                        } else {
                          // Показываем сообщение об ошибке, если не заполнено название предмета
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Предметтин атын киргизиңиз'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1B434D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Кошуу',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Используйте SharedPreferences для сохранения порядка
  Future<void> _saveUserOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Создаем ключ для текущей даты
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay);

    // Сохраняем Map как строку JSON
    final orderJson = jsonEncode(_userOrderMap);
    await prefs.setString('order_$dateKey', orderJson);
  }

  // Загружаем сохраненный порядок
  Future<void> _loadUserOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Создаем ключ для текущей даты
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay);

    // Загружаем сохраненный порядок
    final orderJson = prefs.getString('order_$dateKey');

    if (orderJson != null) {
      // Преобразуем строку JSON обратно в Map
      Map<String, dynamic> savedOrder = jsonDecode(orderJson);

      // Преобразуем к нужному типу (строки и int)
      _userOrderMap = Map<String, int>.from(
          savedOrder.map((key, value) => MapEntry(key, value as int)));

      // Устанавливаем флаг, если есть сохраненный порядок
      _hasCustomOrder = _userOrderMap.isNotEmpty;
    } else {
      // Сбрасываем порядок, если ничего не сохранено
      _hasCustomOrder = false;
      _userOrderMap.clear();
    }
  }

  // Метод для добавления элемента расписания
  Future<void> _addScheduleItem(
    BuildContext context, {
    required String subject,
    required String classInfo,
    required String timeRange,
    required DateTime date,
  }) async {
    final BuildContext contextToUse = context;

    setState(() {
      _isLoading = true;
    });

    try {
      // Добавляем элемент расписания через сервис
      final ScheduleItem addedItem = await _scheduleService.addScheduleItem(
        subject: subject,
        classInfo: classInfo,
        timeRange: timeRange,
        date: date,
      );

      // Добавляем новый элемент в общий список
      setState(() {
        _allScheduleItems.add(addedItem);
        _isLoading = false;
      });

      // Обновляем текущие элементы, если это текущая дата
      if (isSameDay(date, _selectedDay)) {
        _updateCurrentItemsForSelectedDay();
      }

      // Показываем сообщение об успешном добавлении
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (contextToUse.mounted) {
          ScaffoldMessenger.of(contextToUse).showSnackBar(
            const SnackBar(
              content: Text('Предмет успешно добавлен в расписание'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (e) {
      // Обрабатываем ошибку
      setState(() {
        _isLoading = false;
      });

      // Показываем сообщение об ошибке
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (contextToUse.mounted) {
          ScaffoldMessenger.of(contextToUse).showSnackBar(
            SnackBar(
              content: Text('Ошибка при добавлении предмета: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  // Метод для обновления порядка элементов в списках
  void _updateItemsOrder(List<dynamic> reorderedItems) {
    // Очищаем текущие списки
    _currentItems.clear();
    _currentScheduleItems.clear();

    // Распределяем элементы обратно в соответствующие списки
    for (var item in reorderedItems) {
      if (item is Task || (item is ScheduleItem && item.isTask)) {
        _currentItems.add(item);
      } else {
        _currentScheduleItems.add(item);
      }
    }

    // Здесь можно добавить логику для сохранения изменений на сервере
    // например, вызов метода _scheduleService.updateOrder(...)
  }

  // Вспомогательный метод для преобразования строки времени в DateTime
  DateTime _parseTimeString(String timeString) {
    // Если строка содержит диапазон (например, "08:00 - 08:45"), берем первое время
    String time = timeString;
    if (timeString.contains('-')) {
      time = timeString.split('-')[0].trim();
    }

    final DateTime today = DateTime.now();
    final List<String> parts = time.split(':');

    int hour = 0;
    int minute = 0;

    try {
      if (parts.length >= 1) hour = int.parse(parts[0]);
      if (parts.length >= 2) minute = int.parse(parts[1]);
    } catch (e) {
      print('Ошибка при парсинге времени: $e');
    }

    return DateTime(today.year, today.month, today.day, hour, minute);
  }
}
