// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:async';

// import 'package:docx_template/docx_template.dart';
import 'package:alippepro_v1/services/chatgpt_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:share/share.dart';
import 'package:alippepro_v1/providers/chatgpt_provider.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, Uint8List, rootBundle;

class PrepareLessonPlan extends StatefulWidget {
  const PrepareLessonPlan({super.key});

  @override
  _PrepareLessonPlanState createState() => _PrepareLessonPlanState();
}

class _PrepareLessonPlanState extends State<PrepareLessonPlan> {
  String? dropdownValue;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  bool isEditing = false;
  final ChatgptService chatgptServices = ChatgptService();
  String? _downloadedFilePath;
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();

    _textEditingController.dispose();
    _focusNode.dispose();
  }

  void _startDownload(type) async {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SpinKitCircle(
                    color: Colors.blue,
                    size: 50.0,
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<double>(
                    valueListenable: _progressNotifier,
                    builder: (context, progress, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blueAccent),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    String? path = await chatgptServices.downloadFile(
      type,
      _textEditingController.text,
      context,
      progressNotifier: _progressNotifier,
    );
    setState(() {
      _downloadedFilePath = path;
    });
    _progressNotifier.value = 0.0;
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8,
          titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Column(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                radius: 24,
                child: Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 15),
              Text(
                'Файл жүктөлдү',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColorDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(_downloadedFilePath.toString()),
              Text(
                'Сабактын планы ийгиликтүү жүктөлдү жана Жеке кабинетте "Сабактын пландары" папкасында сакталды.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Жабуу',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (_downloadedFilePath != null) {
                          if (_downloadedFilePath!.endsWith('.pdf')) {
                            final result =
                                await OpenFile.open(_downloadedFilePath);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PdfViewerScreen(
                            //         filePath: _downloadedFilePath!),
                            //   ),
                            // );
                          } else {
                            await OpenFile.open(_downloadedFilePath);
                          }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_open, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Ачуу',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final response =
        Provider.of<ChatgptProvider>(context, listen: false).chatgpt;
    _textEditingController =
        TextEditingController(text: response.response.toString());
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    print(_downloadedFilePath.toString());
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xffF0F0F0),
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // Привязка ScrollController
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromARGB(71, 41, 45, 50),
                            offset: Offset(8, 8),
                            spreadRadius: 0,
                            blurRadius: 5),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/img/planLesson.png',
                          width: 50,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text('Сабактын планын даяр',
                            style: TextStyle(
                                color: Color(0xff004C92),
                                fontSize: 20,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 20), // Placeholder for spacing
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: const Color(0xff004C92),
                        width: 1,
                        style: BorderStyle.solid)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Добавление анимированного текста с поддержкой Markdown
                    AnimatedMarkdownText(
                      response: _textEditingController.text,
                      onTextUpdated: _scrollToBottom, // Передаем коллбэк
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          hint: const Text('Көчүүрү'),
                          value: dropdownValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue;
                              if (newValue == 'Ms Word') {
                                _startDownload('word');
                              } else if (newValue == 'PDF') {
                                _startDownload('pdf');
                              }
                            });
                          },
                          items: <String>['Ms Word', 'PDF']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = true;
                            });
                            _editText(context);
                          },
                          child: const Text('Редакциялоо'),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _textEditingController.text));
                        Fluttertoast.showToast(
                          msg: 'Текст скопирован',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey[700],
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      },
                      child: const Text('Скопировать'),
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

  void _editText(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Позволяет занять полный экран
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final availableHeight =
                MediaQuery.of(context).size.height - keyboardHeight;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Компенсация клавиатуры
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: availableHeight *
                            0.8, // 80% от доступного пространства
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          style: GoogleFonts.montserrat(fontSize: 14),
                          controller: _textEditingController,
                          focusNode: _focusNode,
                          maxLines: null,
                          onSubmitted: (text) {
                            // Обновляем состояние и прокручиваем вниз
                            setState(() {
                              _textEditingController.text = text;
                            });
                            _scrollToBottom(); // Прокрутка вниз при изменении текста
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(
                                      0xff004C92)), // Цвет рамки по умолчанию
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(
                                      0xff004C92)), // Цвет рамки при доступности
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff004C92),
                                  width: 2.0), // Цвет рамки при фокусе
                            ),
                            labelText: 'Сабактын планын редакциялоо',
                            labelStyle: GoogleFonts.montserrat(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditing = false;
                          });
                          Navigator.pop(context);
                          _scrollToBottom(); // Прокрутка вниз после сохранения
                        },
                        child: const Text('Сактоо'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class AnimatedMarkdownText extends StatefulWidget {
  final String response;
  final VoidCallback onTextUpdated; // Коллбэк для обновления текста

  const AnimatedMarkdownText({
    super.key,
    required this.response,
    required this.onTextUpdated,
  });

  @override
  _AnimatedMarkdownTextState createState() => _AnimatedMarkdownTextState();
}

class _AnimatedMarkdownTextState extends State<AnimatedMarkdownText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 10 * widget.response.length),
      vsync: this,
    )..forward();
    _charCount = StepTween(
      begin: 0,
      end: widget.response.length,
    ).animate(_controller);

    // Слушаем изменения анимации
    _controller.addListener(() {
      if (_controller.isCompleted) {
        widget.onTextUpdated(); // Вызываем коллбэк, когда текст обновлен
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _charCount,
      builder: (context, child) {
        final String visibleText =
            widget.response.substring(0, _charCount.value);
        return MarkdownBody(
          data: visibleText.isEmpty ? '' : visibleText,
          styleSheet: MarkdownStyleSheet(
            h1: GoogleFonts.montserrat(
                fontSize: 22, fontWeight: FontWeight.bold),
            h2: GoogleFonts.montserrat(
                fontSize: 20, fontWeight: FontWeight.bold),
            h3: GoogleFonts.montserrat(
                fontSize: 18, fontWeight: FontWeight.bold),
            h4: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.bold),
            h5: GoogleFonts.montserrat(
                fontSize: 14, fontWeight: FontWeight.bold),
            h6: GoogleFonts.montserrat(
                fontSize: 14, fontWeight: FontWeight.bold),
            p: GoogleFonts.montserrat(
                fontSize: 14, fontWeight: FontWeight.w400),
            blockquote: GoogleFonts.montserrat(
                fontSize: 14, fontStyle: FontStyle.italic),
            code: GoogleFonts.montserrat(),
            listBullet: GoogleFonts.montserrat(fontSize: 14),
          ),
        );
      },
    ).animate().fadeIn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// PDF Viewer screen
class PdfViewerScreen extends StatefulWidget {
  final String filePath;

  const PdfViewerScreen({super.key, required this.filePath});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  int? pages = 0;

  int? currentPage = 0;

  bool isReady = false;

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сабактын планы')),
      body: Center(
        child: PDFView(
          filePath: widget.filePath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          backgroundColor: Colors.grey,
          onRender: (pages) {
            setState(() {
              pages = pages;
              isReady = true;
            });
          },
          onError: (error) {
            print(error.toString());
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            _controller.complete(pdfViewController);
          },
          onPageChanged: (int? page, int? total) {
            print('page change: ${page ?? 0 + 1}/$total');
            setState(() {
              currentPage = page;
            });
          },
        ),
      ),
    );
  }
}
