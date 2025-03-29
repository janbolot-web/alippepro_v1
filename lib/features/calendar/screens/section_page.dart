import 'dart:convert';
import 'dart:ui';

import 'package:alippepro_v1/features/calendar/widgets/event_card.dart';
import 'package:alippepro_v1/models/calendar-models.dart';
import 'package:alippepro_v1/services/section_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SectionPage extends StatefulWidget {
  final Section section;
  final Function(String, DateTime, String, bool) onAddTask;
  final Function(String, String)? onDeleteTask; // Add delete task callback

  const SectionPage({
    super.key,
    required this.section,
    required this.onAddTask,
    this.onDeleteTask, // Add this parameter
  });

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  final Set<String> _deletingTaskIds = {};
// Добавьте в класс _SectionPageState
  Map<String, int> _taskOrderMap =
      {}; // Ключ - ID задачи, значение - порядковый номер
  bool _hasCustomOrder =
      false; // Флаг, показывающий, менял ли пользователь порядок
  @override
  void initState() {
    super.initState();
    _loadTaskOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context: context),
        Expanded(
          child: _buildTaskList(),
        ),
        _buildAddTaskButton(context),
      ],
    );
  }

  // Метод для сохранения порядка
  Future<void> _saveTaskOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Создаем ключ для текущей секции
    final sectionKey = 'section_${widget.section.id}_order';

    // Сохраняем Map как строку JSON
    final orderJson = jsonEncode(_taskOrderMap);
    await prefs.setString(sectionKey, orderJson);
  }

// Метод для загрузки порядка
  Future<void> _loadTaskOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Создаем ключ для текущей секции
    final sectionKey = 'section_${widget.section.id}_order';

    // Загружаем сохраненный порядок
    final orderJson = prefs.getString(sectionKey);

    if (orderJson != null) {
      try {
        // Преобразуем строку JSON обратно в Map
        Map<String, dynamic> savedOrder = jsonDecode(orderJson);

        // Преобразуем к нужному типу (строки и int)
        _taskOrderMap = Map<String, int>.from(
            savedOrder.map((key, value) => MapEntry(key, value as int)));

        // Устанавливаем флаг, если есть сохраненный порядок
        _hasCustomOrder = _taskOrderMap.isNotEmpty;

        // Применяем порядок (сортируем список задач)
        if (_hasCustomOrder) {
          widget.section.tasks.sort((a, b) {
            final orderA = _taskOrderMap[a.id] ?? 999999;
            final orderB = _taskOrderMap[b.id] ?? 999999;
            return orderA.compareTo(orderB);
          });
        }
      } catch (e) {
        print('Ошибка при загрузке порядка задач: $e');
        _hasCustomOrder = false;
        _taskOrderMap.clear();
      }
    }
  }

  Widget _buildHeader({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Менин',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Color(0xffAC046A),
                ),
              ),
              Text(
                'ТАПШЫРМАЛАРЫМ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: widget.section.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.section.title,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add this to your _SectionPageState class declaration
  Set<String> _loadingTaskIds = {}; // Track which tasks are currently loading

  Future<void> _updateTaskCompletionStatus(
      String taskId, bool completed) async {
    // Immediately update UI for better UX
    setState(() {
      // Add task ID to loading list
      _loadingTaskIds.add(taskId);

      // Update task state in section tasks
      for (int i = 0; i < widget.section.tasks.length; i++) {
        if (widget.section.tasks[i].id == taskId) {
          // Create a new task with updated completion status
          widget.section.tasks[i] = Task(
            id: widget.section.tasks[i].id,
            title: widget.section.tasks[i].title,
            date: widget.section.tasks[i].date,
            time: widget.section.tasks[i].time,
            completed: completed,
            sectionId: widget.section.id,
            isUrgent: false,
            sectionTitle: '',
            sectionColor: Colors.black,
          );
          break;
        }
      }
    });

    try {
      // Call the API service to update the task status
      final sectionService = SectionService(); // Initialize the service
      await sectionService.updateTaskCompletionStatus(
        widget.section.id,
        taskId,
        completed,
      );

      // Show success notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                completed ? 'Тапшырма аткарылды' : 'Тапшырма аткарылган жок',
                style: const TextStyle(fontFamily: 'Montserrat'),
              ),
            ],
          ),
          backgroundColor: const Color(0xff1B434D),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Статусту жаңыртууда ката кетти: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // If there's an error, revert the UI to previous state
      setState(() {
        for (int i = 0; i < widget.section.tasks.length; i++) {
          if (widget.section.tasks[i].id == taskId) {
            // Create a new task with previous completion status
            widget.section.tasks[i] = Task(
              id: widget.section.tasks[i].id,
              title: widget.section.tasks[i].title,
              date: widget.section.tasks[i].date,
              time: widget.section.tasks[i].time,
              completed: !completed, // Revert back
              sectionId: widget.section.id, isUrgent: false, sectionTitle: '',
              sectionColor: Colors.black,
            );
            break;
          }
        }
      });
    } finally {
      // Remove task ID from loading list
      setState(() {
        _loadingTaskIds.remove(taskId);
      });
    }
  }

  Widget _buildTaskList() {
    if (widget.section.tasks.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "Тапшырмалар табылган жок.\nЖаңы тапшырма кошуңуз!",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: widget.section.tasks.length,
      proxyDecorator: (child, index, animation) {
        // Добавляем красивый эффект при перетаскивании
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.2),
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) {
        // Корректируем индекс при перемещении вниз
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        setState(() {
          // Перемещаем элемент в списке
          final task = widget.section.tasks.removeAt(oldIndex);
          widget.section.tasks.insert(newIndex, task);

          // Обновляем Map с пользовательским порядком
          _hasCustomOrder = true;
          for (int i = 0; i < widget.section.tasks.length; i++) {
            _taskOrderMap[widget.section.tasks[i].id] = i;
          }
        });

        // Сохраняем новый порядок
        _saveTaskOrder();

        // Вибрация при перемещении
        HapticFeedback.mediumImpact();

        // Показываем сообщение после перемещения
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.done, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  "Тапшырмалардын тартиби сакталды",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xff1B434D),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      itemBuilder: (context, index) {
        final task = widget.section.tasks[index];
        final bool isTaskLoading = _loadingTaskIds.contains(task.id);
        final bool isDeleting = _deletingTaskIds.contains(task.id);

        return Slidable(
          key: ValueKey('task-${task.id}-${task.completed}'),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _deleteTask(task),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Өчүрүү',
              ),
            ],
          ),
          child: Stack(
            children: [
              // Важно: используем обычный EventCard вместо AnimatedEventCard,
              // чтобы избежать конфликта с drag and drop
              Column(
                children: [
                  EventCard(
                    title: task.title,
                    date: task.date,
                    timeRange: task.time,
                    isCompleted: task is Task ? task.completed : false,
                    taskId: task.id,
                    isLoading: isTaskLoading,
                    onCheckChanged: (bool? value, String taskId) {
                      _updateTaskCompletionStatus(taskId, value ?? false);
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),

              if (isDeleting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Future<void> _deleteTask(Task task) async {
    // Confirm deletion with a styled dialog
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
              // Header
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

              // Confirmation text
              Text(
                '\"${task.title}\" тапшырмасын өчүрүүнү каалайсызбы?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff1B434D),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
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
                  // Delete button
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
    if (confirm == true && widget.onDeleteTask != null) {
      try {
        setState(() {
          _deletingTaskIds.add(task.id);
        });

        // Call the delete function passed from parent
        await widget.onDeleteTask!(widget.section.id, task.id);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Тапшырма \"${task.title}\" ийгиликтүү өчүрүлдү'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Өчүрүү учурунда ката кетти: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Cleanup
        setState(() {
          _deletingTaskIds.remove(task.id);
        });
      }
    }
  }

// Для задач с чекбоксом предлагаю переработать строку так, чтобы она не ломалась
  Widget _buildTaskItem(item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                item.time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Checkbox(
              value: false,
              onChanged: (_) {},
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.red,
                size: 16,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _showAddTaskDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C313A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Жаңы тапшырма кошуу',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isUrgent = false;

    // Цвета из дизайна
    const Color backgroundColor = Color(0xFFF5F5F5);
    const Color primaryColor = Color(0xFF1C313A);
    const Color accentColor = Color(0xff1B434D);

    // Преобразование даты в формат "МЕСЯЦ \ ДЕНЬ \ ГОД"
    String formatDateCustom(DateTime date) {
      final List<String> monthNames = [
        'ЯНВАРЬ',
        'ФЕВРАЛЬ',
        'МАРТ',
        'АПРЕЛЬ',
        'МАЙ',
        'ИЮНЬ',
        'ИЮЛЬ',
        'АВГУСТ',
        'СЕНТЯБРЬ',
        'ОКТЯБРЬ',
        'НОЯБРЬ',
        'ДЕКАБРЬ'
      ];

      return '${monthNames[date.month - 1]} \\ ${date.day} \\ ${date.year}';
    }

    // Функция для создания временного диапазона
    String formatTimeRange(String startTime, String endTime) {
      if (startTime.isEmpty && endTime.isEmpty) {
        return '00:00 - 00:00';
      }
      return '$startTime - $endTime';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Поле для названия задачи
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Тапшырманы жаз',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Divider(color: Colors.grey[300]),

                  // Поле выбора даты
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Text(
                            formatDateCustom(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(color: Colors.grey[300]),

                  // Поля времени начала и конца
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Text(
                              'Убактысы',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Начальное время
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Row(
                            children: [
                              Text(
                                'Башталышы:',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (pickedTime != null) {
                                      final String formattedTime =
                                          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

                                      setState(() {
                                        startTimeController.text =
                                            formattedTime;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      startTimeController.text.isEmpty
                                          ? '00:00'
                                          : startTimeController.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Конечное время
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Row(
                            children: [
                              Text(
                                'Аякташы:  ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (pickedTime != null) {
                                      final String formattedTime =
                                          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

                                      setState(() {
                                        endTimeController.text = formattedTime;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      endTimeController.text.isEmpty
                                          ? '00:00'
                                          : endTimeController.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.grey[300]),

                  // Чекбокс для приоритета
                  // Row(
                  //   children: [
                  //     Checkbox(
                  //       value: isUrgent,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           isUrgent = value ?? false;
                  //         });
                  //       },
                  //       activeColor: accentColor,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //     ),
                  //     Text(
                  //       'Маанилүү',
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         color: Colors.grey[800],
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 24),

                  // Кнопки действий
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Кнопка отмены
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffBA0F43),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Артка',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Кнопка добавления
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final title = titleController.text.trim();
                            final startTime = startTimeController.text.trim();
                            final endTime = endTimeController.text.trim();

                            // Форматируем временной диапазон
                            final timeRange = formatTimeRange(
                                startTime.isEmpty ? '00:00' : startTime,
                                endTime.isEmpty ? '00:00' : endTime);

                            if (title.isNotEmpty) {
                              widget.onAddTask(
                                  title, selectedDate, timeRange, isUrgent);
                              Navigator.pop(context);
                            } else {
                              // Показать сообщение об ошибке
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Пожалуйста, введите название задачи'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Кошуу',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Метод для валидации времени
  bool _validateTime(String time) {
    // Проверяем формат времени (HH:MM)
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    return regex.hasMatch(time);
  }

// Диалог выбора диапазона времени
  Future<Map<String, String>?> showTimeRangePickerDialog(BuildContext context,
      {String? initialStartTime, String? initialEndTime}) async {
    String startTime = initialStartTime ?? '';
    String endTime = initialEndTime ?? '';
    bool confirmed = false;

    const Color accentColor = Color(0xff1B434D);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок
                  Text(
                    'Тандоо убакыт',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Выбор начального времени
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, color: Colors.grey[600]),
                      const SizedBox(width: 16),
                      Text(
                        'Башталышы:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            TimeOfDay initialTime = TimeOfDay.now();
                            if (startTime.isNotEmpty) {
                              final parts = startTime.split(':');
                              initialTime = TimeOfDay(
                                hour: int.parse(parts[0]),
                                minute: int.parse(parts[1]),
                              );
                            }

                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: initialTime,
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: accentColor,
                                    colorScheme: ColorScheme.light(
                                      primary: accentColor,
                                      onSurface: Colors.black,
                                    ),
                                    buttonTheme: ButtonThemeData(
                                      colorScheme: ColorScheme.light(
                                        primary: accentColor,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setState(() {
                                startTime =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              startTime.isEmpty ? '00:00' : startTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[800]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Выбор конечного времени
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Icon(Icons.access_time_filled, color: Colors.grey[600]),
                      const SizedBox(width: 16),
                      Text(
                        'Аягы:       ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            TimeOfDay initialTime = TimeOfDay.now();
                            if (endTime.isNotEmpty) {
                              final parts = endTime.split(':');
                              initialTime = TimeOfDay(
                                hour: int.parse(parts[0]),
                                minute: int.parse(parts[1]),
                              );
                            } else if (startTime.isNotEmpty) {
                              // Предлагаем конечное время на 2 часа позже начального
                              final parts = startTime.split(':');
                              int startHour = int.parse(parts[0]);
                              int endHour = (startHour + 2) % 24;
                              initialTime = TimeOfDay(
                                hour: endHour,
                                minute: int.parse(parts[1]),
                              );
                            }

                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: initialTime,
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: accentColor,
                                    colorScheme: ColorScheme.light(
                                      primary: accentColor,
                                      onSurface: Colors.black,
                                    ),
                                    buttonTheme: ButtonThemeData(
                                      colorScheme: ColorScheme.light(
                                        primary: accentColor,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setState(() {
                                endTime =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              endTime.isEmpty ? '00:00' : endTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[800]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Кнопки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          confirmed = true;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: const Text(
                          'Тандоо',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (confirmed) {
      return {
        'startTime': startTime.isEmpty ? '00:00' : startTime,
        'endTime': endTime.isEmpty ? '00:00' : endTime,
      };
    }

    return null;
  }

// Стильный календарь для выбора даты
  Future<DateTime?> showStyledDatePicker(BuildContext context,
      {required DateTime initialDate}) async {
    const primaryColor = Color(0xff1B434D);
    const accentColor = Color(0xffBA0F43);

    // Список месяцев на кириллице

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              secondary: accentColor,
              onSecondary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: primaryColor,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              dayStyle: const TextStyle(fontSize: 16),
              weekdayStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
              todayBackgroundColor:
                  WidgetStateProperty.all(primaryColor.withOpacity(0.15)),
              todayForegroundColor: WidgetStateProperty.all(primaryColor),
              // selectedBackgroundColor: MaterialStateProperty.all(primaryColor),
              // selectedForegroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: Colors.white,
              yearStyle: const TextStyle(fontSize: 16),
              surfaceTintColor: Colors.white,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryColor;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return null;
              }),
              rangePickerBackgroundColor: Colors.white,
              rangePickerSurfaceTintColor: Colors.white,
              rangeSelectionBackgroundColor: primaryColor.withOpacity(0.15),
              rangeSelectionOverlayColor:
                  WidgetStateProperty.all(primaryColor.withOpacity(0.15)),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('ru', 'RU'),
            child: child!,
          ),
        );
      },
    );
  }

// Преобразование даты в формат "МЕСЯЦ \ ДЕНЬ \ ГОД"
  String formatDateCustom(DateTime date) {
    final List<String> monthNames = [
      'ЯНВАРЬ',
      'ФЕВРАЛЬ',
      'МАРТ',
      'АПРЕЛЬ',
      'МАЙ',
      'ИЮНЬ',
      'ИЮЛЬ',
      'АВГУСТ',
      'СЕНТЯБРЬ',
      'ОКТЯБРЬ',
      'НОЯБРЬ',
      'ДЕКАБРЬ'
    ];

    return '${monthNames[date.month - 1]} \\ ${date.day} \\ ${date.year}';
  }
}
