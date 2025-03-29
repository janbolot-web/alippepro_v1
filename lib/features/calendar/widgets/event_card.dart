import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedEventCard extends StatefulWidget {
  final String title;
  final DateTime date;
  final String timeRange;
  final bool isCompleted;
  final String taskId;
  final bool isLoading; // Added loading parameter
  final Function(bool?, String) onCheckChanged;
  final VoidCallback? onLongPress;

  const AnimatedEventCard({
    Key? key,
    required this.title,
    required this.date,
    required this.timeRange,
    this.isCompleted = false,
    required this.taskId,
    this.isLoading = false, // Default to false
    required this.onCheckChanged,
    this.onLongPress,
  }) : super(key: key);

  @override
  _AnimatedEventCardState createState() => _AnimatedEventCardState();
}

class _AnimatedEventCardState extends State<AnimatedEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.isLoading
          ? null // Disable long press when loading
          : () {
              _controller.forward().then((_) {
                _controller.reverse();
              });
              if (widget.onLongPress != null) {
                widget.onLongPress!();
              }
              HapticFeedback.mediumImpact();
            },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: EventCard(
              title: widget.title,
              date: widget.date,
              timeRange: widget.timeRange,
              isCompleted: widget.isCompleted,
              taskId: widget.taskId,
              isLoading: widget.isLoading, // Pass loading state
              onCheckChanged: widget.onCheckChanged,
            ),
          );
        },
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final String title;
  final DateTime date;
  final String timeRange;
  final bool isCompleted;
  final String taskId;
  final bool isLoading; // Added loading parameter
  final Function(bool?, String) onCheckChanged;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.timeRange,
    this.isCompleted = false,
    required this.taskId,
    this.isLoading = false, // Default to false
    required this.onCheckChanged,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late bool _isChecked;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isCompleted;

    // Setup loading animation controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _loadingAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_loadingController);
  }

  @override
  void didUpdateWidget(EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted != widget.isCompleted) {
      setState(() {
        _isChecked = widget.isCompleted;
      });
    }

    // Handle loading state changes
    if (oldWidget.isLoading != widget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Разделение строки времени на начало и конец для отображения
    List<String> timeParts = widget.timeRange.split(' - ');
    String startTime = timeParts.isNotEmpty ? timeParts[0] : "";
    String endTime = timeParts.length > 1 ? timeParts[1] : "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
      decoration: BoxDecoration(
        color: _isChecked ? const Color(0xFFECF8F0) : Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: _isChecked ? const Color(0xFF4CAF50) : const Color(0xff1B434D),
          width: _isChecked ? 1.0 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Checkbox or Loading indicator based on loading state
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    border: Border.all(
                      color: _isChecked
                          ? const Color(0xFF4CAF50)
                          : const Color(0xff1B434D),
                      width: 1.5,
                    ),
                    color: _isChecked
                        ? const Color(0xFF4CAF50)
                        : Colors.transparent,
                  ),
                  child: Checkbox(
                    value: _isChecked,
                    onChanged: widget.isLoading
                        ? null // Disable checkbox when loading
                        : (bool? value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });

                            // Вызываем метод родителя
                            widget.onCheckChanged(value, widget.taskId);

                            // Добавляем отклик на нажатие
                            HapticFeedback.lightImpact();
                          },
                    fillColor: MaterialStateProperty.all(Colors.transparent),
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    side: BorderSide.none,
                  ),
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .55,
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff2D4356),
                          decoration:
                              _isChecked ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFF4CAF50),
                          decorationThickness: 2,
                        ),
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .55,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date
                          Text(
                            formatDateCustom(widget.date),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: const Color(0xff7D8A8D),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          // Time range separated for display
                          Row(
                            children: [
                              Text(
                                startTime,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: const Color(0xff7D8A8D),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Text(
                                " - ",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                endTime,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_isChecked && !widget.isLoading)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 12,
                              color: Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Аткарылды', // "Completed" in Kyrgyz
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.isLoading)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xff1B434D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xff1B434D).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xff1B434D)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Жаңыртуу', // "Updating" in Kyrgyz
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff1B434D),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Функция форматирования даты
String formatDateCustom(DateTime date) {
  final List<String> monthNames = [
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

  String month = monthNames[date.month - 1].toUpperCase();
  return '$month \\ ${date.day} \\ ${date.year}';
}
