import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookScreen extends StatefulWidget {
  final String url;
  final String fileName;
  final String title;

  const BookScreen(
      {super.key,
      required this.url,
      required this.title,
      required this.fileName});

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  String? localFilePath;
  bool isLoading = true;
  PDFViewController? _pdfViewController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool isPortrait = true; // Флаг для отслеживания ориентации экрана
  bool isDarkMode = false; // Флаг для отслеживания темы (черный фон)
  double _sliderValue = 0.0; // Значение ползунка

  @override
  void initState() {
    super.initState();
    _loadPagePosition(); // Загружаем сохраненную позицию страницы
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/${widget.fileName}";

    // Проверка, существует ли файл
    if (await File(filePath).exists()) {
      // Если файл существует, открыть его
      setState(() {
        localFilePath = filePath;
        isLoading = false;
      });
    } else {
      // Если файл не найден, загрузить его
      await _downloadPdf(filePath);
    }
  }
Future<void> _downloadPdf(String filePath) async {
  try {
    await Dio().download(widget.url, filePath);
    setState(() {
      localFilePath = filePath;
      isLoading = false;
    });
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      print('Ошибка: файл не найден (404)');
    } else {
      print('Ошибка загрузки PDF: $e');
    }
  }
}


  // Функция для переворота экрана
  void _toggleScreenOrientation() {
    if (isPortrait) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    setState(() {
      isPortrait = !isPortrait;
    });
  }

  // Функция для переключения фона
  void _toggleBackground() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  // Функция для перехода на страницу по значению ползунка
  void _onSliderChanged(double value) {
    if (_pdfViewController != null) {
      int page = value.toInt();
      // Убедитесь, что значение страницы в пределах допустимого диапазона
      if (page >= 0 && page < _totalPages) {
        _pdfViewController!.setPage(page);
        setState(() {
          _currentPage = page;
          _sliderValue = value;
          _savePagePosition(page); // Сохраняем текущую позицию
        });
      }
    }
  }

  // Функция для сохранения текущей страницы
  Future<void> _savePagePosition(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${widget.fileName}currentPage', page);
  }

// Функция для загрузки сохраненной страницы
  Future<void> _loadPagePosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt('${widget.fileName}currentPage') ?? 0;
    setState(() {
      _currentPage = savedPage;
      _sliderValue = savedPage.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Убедитесь, что значения min и max корректны
    double minValue = 0.0;
    double maxValue = _totalPages > 0 ? (_totalPages - 1).toDouble() : 0.0;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: GoogleFonts.rubik(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isPortrait ? Icons.screen_rotation : Icons.screen_lock_rotation,
            ),
            onPressed: _toggleScreenOrientation,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: isDarkMode ? Colors.black : Colors.white, // Цвет фона
              child: Column(
                children: [
                  // Ползунок для быстрого перелистывания страниц
                  // Показываем ползунок только если страниц больше одной

                  Expanded(
                    child: PDFView(
                      filePath: localFilePath!,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages ?? 0;
                          // Убедитесь, что значение ползунка в пределах допустимого диапазона
                          if (_totalPages > 0) {
                            _sliderValue = _currentPage
                                .toDouble()
                                .clamp(0.0, (_totalPages - 1).toDouble());
                          }
                        });
                      },
                      defaultPage: _currentPage,
                      onViewCreated: (PDFViewController pdfViewController) {
                        setState(() {
                          _pdfViewController = pdfViewController;
                        });
                        // Устанавливаем сохраненную страницу при создании PDFViewController
                        if (_pdfViewController != null &&
                            _currentPage < _totalPages) {
                          _pdfViewController!.setPage(_currentPage);
                        }
                      },
                      onPageChanged: (int? currentPage, int? totalPages) {
                        setState(() {
                          _currentPage = currentPage ?? 0;
                          _totalPages = totalPages ?? 0;
                          _sliderValue = _currentPage
                              .toDouble()
                              .clamp(0.0, (_totalPages - 1).toDouble());
                          _savePagePosition(
                              _currentPage); // Сохраняем текущую страницу
                        });
                      
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          if (_totalPages > 1)
                            Slider(
                              value: _sliderValue,
                              min: minValue,
                              max: maxValue,
                              divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                              onChanged: _onSliderChanged,
                              activeColor:
                                  isDarkMode ? Colors.white : const Color(0xFF004C92),
                              inactiveColor:
                                  isDarkMode ? Colors.grey : Colors.black54,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Страница: ${_currentPage + 1} из $_totalPages",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    // Возвращаем ориентацию экрана к стандартной, если приложение закрывается
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
