// Основная страница с навигацией
import 'dart:convert';
import 'dart:ui';

import 'package:alippepro_v1/features/calendar/screens/calendar.dart'
    show AddSectionPage;
import 'package:alippepro_v1/features/calendar/screens/calendar_page.dart';
import 'package:alippepro_v1/features/calendar/screens/section_page.dart';
import 'package:alippepro_v1/models/calendar-models.dart';
import 'package:alippepro_v1/services/section_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with SingleTickerProviderStateMixin {
  // Текущий выбранный индекс
  int _selectedIndex = 5; // Начинаем с календаря (последний индекс)
  bool _isLoading = false;
  final SectionService _sectionService = SectionService();

  // Переменные для режима редактирования
  bool _isEditMode = false;
  List<Section> _originalSections =
      []; // Сохраняем оригинальный порядок на случай отмены

  // Контроллеры для анимаций дрожания
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimationX;
  late Animation<double> _shakeAnimationY;
  late Animation<double> _rotateAnimation;

  // Хранение порядка секций
  Map<String, int> _sectionOrderMap = {};
  bool _hasCustomOrder = false;

  // Список праздников
  final Map<DateTime, List<String>> _holidays = {
    DateTime(2025, 2, 23): ['Праздник'],
    DateTime(2025, 3, 8): ['Международный женский день'],
    DateTime(2025, 5, 1): ['Праздник весны и труда'],
    DateTime(2025, 5, 9): ['День Победы'],
  };

  // Начальный список разделов с задачами
  List<Section> _sections = [];

  // Список элементов расписания
  List<ScheduleItem> _scheduleItems = [];

  // Контроллер для прокрутки боковой панели
  final ScrollController _sidebarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Инициализация анимации с более плавным и небольшим эффектом
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800), // Увеличиваем длительность
      vsync: this,
    )..repeat(
        reverse: true,
        period:
            const Duration(milliseconds: 1500)); // Замедляем частоту повторения

    // Горизонтальное движение (уменьшаем амплитуду)
    _shakeAnimationX = Tween<double>(begin: -0.8, end: 0.8).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.ease, // Более плавная кривая
      ),
    );

    // Вертикальное движение (уменьшаем амплитуду)
    _shakeAnimationY = Tween<double>(begin: -0.4, end: 0.4).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.ease, // Более плавная кривая
      ),
    );

    // Небольшое вращение (уменьшаем угол)
    _rotateAnimation = Tween<double>(begin: -0.01, end: 0.01).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.ease, // Более плавная кривая
      ),
    );

    // Загружаем данные при запуске
    _loadData();
  }

  // Метод для загрузки всех данных
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Загружаем разделы из базы данных
      final List<Section> loadedSections =
          await _sectionService.getAllSections();

      // Загружаем пользовательский порядок секций
      await _loadSectionsOrder();

      setState(() {
        _sections = loadedSections;

        // Применяем пользовательский порядок, если он есть
        if (_hasCustomOrder && _sectionOrderMap.isNotEmpty) {
          _sections.sort((a, b) {
            final orderA = _sectionOrderMap[a.id] ?? 999999;
            final orderB = _sectionOrderMap[b.id] ?? 999999;
            return orderA.compareTo(orderB);
          });
        }

        _isLoading = false;
      });

      // Инициализируем расписание после загрузки разделов
      _initScheduleItems();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Показываем ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке данных: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Метод для инициализации расписания
  void _initScheduleItems() {
    _scheduleItems = [
      ScheduleItem(
        id: 'class1',
        time: '8:00 - 8:45',
        subject: 'Алгебра',
        classInfo: '6-кл',
        date: DateTime(2025, 2, 20),
      ),
      ScheduleItem(
        id: 'class2',
        time: '9:50 - 10:35',
        subject: 'Алгебра',
        classInfo: '9-кл',
        date: DateTime(2025, 2, 20),
      ),
      ScheduleItem(
        id: 'task1',
        time: '11:00 - 12:00',
        subject: 'Класстык журналды толтуруу',
        classInfo: '',
        date: DateTime(2025, 2, 20),
        isTask: true,
      ),
      ScheduleItem(
        id: 'class3',
        time: '13:30 - 14:15',
        subject: 'Геометрия',
        classInfo: '11-кл',
        date: DateTime(2025, 2, 20),
      ),
    ];
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // Методы для сохранения и загрузки порядка секций
  Future<void> _saveSectionsOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Обновляем Map порядка с текущими секциями
    _sectionOrderMap.clear();
    for (int i = 0; i < _sections.length; i++) {
      _sectionOrderMap[_sections[i].id] = i;
    }

    // Сохраняем Map как строку JSON
    final orderJson = jsonEncode(_sectionOrderMap);
    await prefs.setString('sections_order', orderJson);

    _hasCustomOrder = true;
  }

  Future<void> _loadSectionsOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Загружаем сохраненный порядок
    final orderJson = prefs.getString('sections_order');

    if (orderJson != null) {
      try {
        // Преобразуем строку JSON обратно в Map
        Map<String, dynamic> savedOrder = jsonDecode(orderJson);

        // Преобразуем к нужному типу (строки и int)
        _sectionOrderMap = Map<String, int>.from(
            savedOrder.map((key, value) => MapEntry(key, value as int)));

        // Устанавливаем флаг, если есть сохраненный порядок
        _hasCustomOrder = _sectionOrderMap.isNotEmpty;
      } catch (e) {
        print('Ошибка при загрузке порядка секций: $e');
        _hasCustomOrder = false;
        _sectionOrderMap.clear();
      }
    }
  }

  // Метод для добавления нового раздела
  Future<void> _addNewSection(String title, String letter, Color color) async {
    try {
      // Показываем индикатор загрузки
      setState(() {
        _isLoading = true;
      });

      // Создаем раздел на сервере
      final Section newSection =
          await _sectionService.createSection(title, letter, color);

      // Добавляем новый раздел в локальный список после успешного создания на сервере
      setState(() {
        _sections.add(newSection);

        // Автоматически переключаемся на новый раздел
        _selectedIndex = _sections.length - 1;

        // Сбрасываем состояние загрузки
        _isLoading = false;
      });

      // Обновляем порядок после добавления новой секции
      await _saveSectionsOrder();

      // Прокручиваем к новому разделу после добавления
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedSection();
      });

      // Показываем уведомление об успешном создании
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бөлүм ийгиликтүү түзүлдү'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Обрабатываем ошибку
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при создании раздела: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Метод для удаления раздела
  Future<void> _deleteSection(String sectionId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Удаляем раздел на сервере
      final bool success = await _sectionService.deleteSection(sectionId);

      if (success) {
        setState(() {
          // Удаляем раздел из локального списка
          _sections.removeWhere((section) => section.id == sectionId);

          // Если удаленный раздел был выбран, переключаемся на календарь
          if (_selectedIndex >= _sections.length) {
            _selectedIndex = _sections.length + 1; // Календарь
          }

          _isLoading = false;
        });

        // Обновляем порядок после удаления секции
        await _saveSectionsOrder();

        // Показываем уведомление об успешном удалении
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Бөлүм ийгиликтүү өчүрүлдү'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        // Показываем сообщение об ошибке
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось удалить раздел'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении раздела: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Метод для прокрутки к выбранному разделу
  void _scrollToSelectedSection() {
    if (_selectedIndex < _sections.length) {
      // Расчетная позиция для прокрутки (высота кнопки + отступ) × индекс
      final double position = (_selectedIndex * (42.0 + 16.0));

      // Прокручиваем до нужной позиции с анимацией
      _sidebarScrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Метод для добавления задачи в раздел
  Future<void> _addTaskToSection(
    String sectionId,
    String title,
    DateTime date,
    String time,
    isUrgent,
    type,
  ) async {
    try {
      // Показываем индикатор загрузки
      setState(() {
        _isLoading = true;
      });

      // Добавляем задачу в раздел на сервере
      final Section updatedSection = await _sectionService.addTaskToSection(
          sectionId, title, date, time, isUrgent, type);

      // Обновляем локальный список разделов после успешного добавления на сервере
      setState(() {
        final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
        if (sectionIndex != -1) {
          // Заменяем раздел на обновленный с сервера
          _sections[sectionIndex] = updatedSection;
        }

        // Сбрасываем состояние загрузки
        _isLoading = false;
      });

      // Показываем уведомление об успешном добавлении
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Задача успешно добавлена'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Обрабатываем ошибку
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при добавлении задачи: $e'),
          backgroundColor: Colors.red,
        ),
      );

      // Резервный вариант: добавляем задачу локально в случае ошибки
      setState(() {
        final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
        if (sectionIndex != -1) {
          final section = _sections[sectionIndex];

          section.tasks.add(
            Task(
              id: 'task_${DateTime.now().millisecondsSinceEpoch}',
              title: title,
              date: date,
              time: time,
              isUrgent: isUrgent,
              sectionId: sectionId,
              sectionTitle: section.title,
              sectionColor: section.color,
            ),
          );
        }
      });
    }
  }

  // Метод для получения всех задач из всех разделов для конкретной даты
  List<Task> _getTasksForDate(DateTime date) {
    final List<Task> tasksForDate = [];

    for (final section in _sections) {
      for (final task in section.tasks) {
        if (isSameDay(task.date, date)) {
          tasksForDate.add(task);
        }
      }
    }

    // Сортируем задачи по времени
    tasksForDate.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));

    return tasksForDate;
  }

  // Метод для добавления элемента расписания
  void _addScheduleItem(
      String time, String subject, String classInfo, DateTime date) {
    setState(() {
      _scheduleItems.add(
        ScheduleItem(
          id: 'schedule_${DateTime.now().millisecondsSinceEpoch}',
          time: time,
          subject: subject,
          classInfo: classInfo,
          date: date,
        ),
      );
    });
  }

  // Метод для получения элементов расписания для конкретной даты
  List<ScheduleItem> _getScheduleItemsForDate(DateTime date) {
    final List<ScheduleItem> itemsForDate = [];

    // Добавляем предметы из расписания
    for (final item in _scheduleItems) {
      if (isSameDay(item.date, date)) {
        itemsForDate.add(item);
      }
    }

    // Добавляем задачи из разделов
    for (final task in _getTasksForDate(date)) {
      itemsForDate.add(ScheduleItem.fromTask(task));
    }

    // Сортируем по времени
    return ScheduleItem.sortByTime(itemsForDate);
  }

  // Метод для удаления задачи из раздела
  Future<void> _deleteTaskFromSection(String sectionId, String taskId) async {
    try {
      // Показываем индикатор загрузки
      setState(() {
        _isLoading = true;
      });

      // Удаляем задачу на сервере
      final bool success = await _sectionService.deleteTask(sectionId, taskId);

      if (success) {
        // Обновляем локальное состояние, удаляя задачу из раздела
        setState(() {
          final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
          if (sectionIndex != -1) {
            // Создаем новый список задач без удаленной задачи
            final updatedTasks = _sections[sectionIndex]
                .tasks
                .where((task) => task.id != taskId)
                .toList();

            // Создаем новый раздел с обновленными задачами
            final updatedSection = Section(
              id: _sections[sectionIndex].id,
              title: _sections[sectionIndex].title,
              letter: _sections[sectionIndex].letter,
              color: _sections[sectionIndex].color,
              tasks: updatedTasks,
            );

            // Заменяем старый раздел на обновленный
            _sections[sectionIndex] = updatedSection;
          }

          // Сбрасываем состояние загрузки
          _isLoading = false;
        });
      } else {
        // Обрабатываем неудачу
        setState(() {
          _isLoading = false;
        });

        // Показываем сообщение об ошибке
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при удалении задачи'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Обрабатываем ошибку
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении задачи: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildContent() {
    // Если выбран календарь (последний элемент)
    if (_selectedIndex == _sections.length + 1) {
      return CalendarPage(
        onAddScheduleItem: _addScheduleItem,
        getScheduleItemsForDate: _getScheduleItemsForDate,
        scheduleItems: _scheduleItems,
        holidays: _holidays,
        onDeleteTask: _deleteTaskFromSection,
      );
    }
    // Если выбрана страница добавления раздела
    else if (_selectedIndex == _sections.length) {
      return AddSectionPage(onSectionAdded: _addNewSection);
    }
    // В противном случае показываем страницу раздела
    else if (_selectedIndex < _sections.length) {
      return SectionPage(
        section: _sections[_selectedIndex],
        onAddTask: (title, date, time, isUrgent) => _addTaskToSection(
            _sections[_selectedIndex].id, title, date, time, isUrgent, 'task'),
        onDeleteTask: _deleteTaskFromSection,
      );
    }
    // Защита от ошибок
    else {
      return CalendarPage(
        onAddScheduleItem: _addScheduleItem,
        getScheduleItemsForDate: _getScheduleItemsForDate,
        scheduleItems: _scheduleItems,
        holidays: _holidays,
        onDeleteTask: _deleteTaskFromSection,
      );
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 70,
      color: const Color(0xff1B434D),
      child: Column(
        children: [
          const SizedBox(height: 50),
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.arrow_back_ios,
                color: Colors.white),
            onPressed: () {
              if (_isEditMode) {
                // Сохраняем изменения и выходим из режима редактирования
                setState(() {
                  _isEditMode = false;
                });

                // Сохраняем новый порядок секций
                _saveSectionsOrder();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Изменения сохранены'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                Navigator.pop(context);
                // Обычная навигация назад
                // Здесь можно добавить реализацию для обычного режима
              }
            },
          ),
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                // Отмена изменений и выход из режима редактирования
                setState(() {
                  _sections = _originalSections;
                  _isEditMode = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Изменения отменены'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          const SizedBox(height: 20),

          // Основная прокручиваемая область с кнопками разделов
          Expanded(
            child: _buildScrollableSectionButtons(),
          ),

          // Кнопка добавления раздела (скрываем в режиме редактирования)
          if (!_isEditMode) _buildAddButton(),
          const SizedBox(height: 40),

          // Кнопка календаря (скрываем в режиме редактирования)
          if (!_isEditMode) _buildCalendarButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Создаем прокручиваемый список кнопок разделов с поддержкой drag-and-drop
  Widget _buildScrollableSectionButtons() {
    // if (_sections.isEmpty) {
    //   return Center(
    //     child: Text(
    //       "Нет разделов",
    //       style: TextStyle(color: Colors.white.withOpacity(0.7)),
    //     ),
    //   );
    // }

    if (_isEditMode) {
      // В режиме редактирования используем ReorderableListView
      return ReorderableListView.builder(
        scrollController: _sidebarScrollController,
        itemCount: _sections.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        onReorder: (oldIndex, newIndex) {
          // Вибрация при перемещении
          HapticFeedback.mediumImpact();

          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Section item = _sections.removeAt(oldIndex);
            _sections.insert(newIndex, item);
          });

          // Обновляем Map с пользовательским порядком
          for (int i = 0; i < _sections.length; i++) {
            _sectionOrderMap[_sections[i].id] = i;
          }
          _hasCustomOrder = true;
        },
        proxyDecorator: (child, index, animation) {
          // Эффект при перетаскивании
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            color: Colors.transparent,
            shadowColor: Colors.white.withOpacity(0.2),
            child: child,
          );
        },
        itemBuilder: (context, index) {
          return Padding(
            key: ValueKey(_sections[index].id),
            padding: const EdgeInsets.only(bottom: 16, left: 14, right: 14),
            child: _buildSidebarButton(
                _sections[index].letter, _sections[index].color, index),
          );
        },
      );
    } else {
      // Обычный режим просмотра
      return Scrollbar(
        controller: _sidebarScrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _sidebarScrollController,
          itemCount: _sections.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 14, right: 14),
              child: GestureDetector(
                onLongPress: () {
                  // Включаем режим редактирования при долгом нажатии
                  setState(() {
                    _isEditMode = true;
                    _originalSections =
                        List.from(_sections); // Сохраняем копию для отмены
                  });

                  // Показываем уведомление о режиме редактирования
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Режим редактирования активирован'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                child: _buildSidebarButton(
                    _sections[index].letter, _sections[index].color, index),
              ),
            );
          },
        ),
      );
    }
  }

  // Метод для отображения кнопки бокового меню
  Widget _buildSidebarButton(String text, Color color, int index) {
    bool isSelected = _selectedIndex == index && !_isEditMode;

    return _isEditMode
        ? _buildEditableSidebarButton(text, color, index)
        : GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            onLongPress: () {
              setState(() {
                _isEditMode = true;
                _originalSections = List.from(_sections);
              });

              // Показываем уведомление о режиме редактирования
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Режим редактирования активирован'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: color, width: 2) : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ),
          );
  }

  // Метод для отображения кнопки в режиме редактирования с усиленным эффектом дрожания
  Widget _buildEditableSidebarButton(String text, Color color, int index) {
    return AnimatedBuilder(
      animation:
          _shakeController, // Теперь слушаем контроллер вместо одной анимации
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            // Применяем смещение по обеим осям
            ..translate(_shakeAnimationX.value, _shakeAnimationY.value)
            // Добавляем вращение для эффекта качания
            ..rotateZ(_rotateAnimation.value),
          child: Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ),
              // Кнопка удаления
              Positioned(
                right: -5,
                top: -5,
                child: GestureDetector(
                  onTap: () {
                    // Показываем диалог подтверждения
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Удаление раздела"),
                        content: Text(
                            "Вы уверены, что хотите удалить раздел '${_sections[index].title}'?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Отмена"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteSection(_sections[index].id);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text("Удалить"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    bool isSelected = _selectedIndex == _sections.length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = _sections.length;
        });
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF78909C),
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarButton() {
    bool isSelected = _selectedIndex == _sections.length + 1;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = _sections.length + 1;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            width: isSelected ? 2 : 1,
          ),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.calendar_today,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            size: 22,
          ),
        ),
      ),
    );
  }
}

// Дополнительно доработайте класс SectionService, добавив метод для удаления раздела
extension SectionServiceExtension on SectionService {
  Future<bool> deleteSection(String sectionId) async {
    try {
      // Реализуйте вызов API для удаления раздела
      // Для примера, успешное удаление
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      print('Ошибка при удалении раздела: $e');
      return false;
    }
  }

  // Дополнительно можно добавить метод для сохранения порядка разделов
  Future<bool> updateSectionsOrder(List<String> sectionIds) async {
    try {
      // Реализуйте вызов API для обновления порядка
      // Для примера, успешное обновление
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      print('Ошибка при обновлении порядка разделов: $e');
      return false;
    }
  }
}
