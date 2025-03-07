// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class RaitingScreen extends StatefulWidget {
  const RaitingScreen({super.key});

  @override
  State<RaitingScreen> createState() => _RaitingScreenState();
}

class _RaitingScreenState extends State<RaitingScreen> {
  Map<String, dynamic> roomDataProvider = {};
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false).roomData;
    isExpandedList =
        List<bool>.filled(roomDataProvider['players'].length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
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
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 15,
                            child: GestureDetector(
                              child: const Icon(
                                Icons.arrow_back_ios,
                              ),
                              onTap: () {
                                Get.back();
                              },
                            ),
                          ),
                          Center(
                            child: Text('Окуучулардын\nжооптору',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.rubik(
                                    color: const Color(0xff004C92),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.6,
                      child: _studentList(),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _createAndDownloadPdf();
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xff004C92),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Көчүрүү',
                                  style: GoogleFonts.rubik(
                                      fontSize: 18, color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 28,
                                )
                              ],
                            )),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListView _studentList() {
    List<dynamic> filteredStudents = roomDataProvider['players']
        .where((student) => student['playerType'] != 'X')
        .toList();
    return ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpandedList[index] = !isExpandedList[index];
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color(0xff004C92), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              student['nickname'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff004C92),
                              ),
                            ),
                            if (isExpandedList[index])
                              const Icon(
                                Icons.keyboard_arrow_up,
                                size: 26,
                              )
                            else
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 26,
                              )
                          ],
                        )),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xff004C92), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        textAlign: TextAlign.center,
                        '${student['correctAnswer'].toString()} / ${roomDataProvider['questions'].length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff004C92),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isExpandedList[index])
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 80.0,
                        lineWidth: 5.0,
                        animation: true,
                        percent: (1 *
                            student['correctAnswer'] /
                            roomDataProvider['questions'].length),
                        center: Text(
                          '${(100 * student['correctAnswer'] / roomDataProvider['questions'].length).round()} %',
                          style: GoogleFonts.rubik(
                              fontWeight: FontWeight.w200,
                              color: const Color(0xff004C92),
                              fontSize: 30.0),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: const Color(0xffAC046A),
                      ),
                      const SizedBox(
                        height: 34,
                      ),
                      ListView.builder(
                        shrinkWrap: true, // Fix the infinite height issue
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevent scrolling
                        itemCount: student['result'].length,

                        itemBuilder: (context, resultIndex) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: student['result'][resultIndex]['correct']
                                    ? const Color(0xff088273)
                                    : const Color(0xffBA0F43),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${resultIndex + 1}.  ',
                                  style: GoogleFonts.rubik(
                                      color: const Color(0xff004C92)),
                                ),
                                // Use Expanded here to fill available space in Row
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student['result'][resultIndex]
                                            ['question'],
                                        style: GoogleFonts.rubik(
                                            color: const Color(0xff004C92)),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: student['result']
                                                      [resultIndex]['correct']
                                                  ? const Color(0xff088273)
                                                  : const Color(0xffBA0F43),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Wrap the answers in an Expanded widget for better layout
                                          Expanded(
                                            child: Wrap(
                                              spacing:
                                                  10, // Add spacing between answers
                                              children: student['result']
                                                      [resultIndex]['answer']
                                                  .map<Widget>((item) {
                                                return Text(
                                                  '${item.toString()}, ',
                                                  style: GoogleFonts.rubik(
                                                      color: const Color(0xff004C92)),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (!student['result'][resultIndex]
                                          ['correct'])
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Туура жообу: ',
                                              style: GoogleFonts.rubik(
                                                  color: const Color(0xff004C92)),
                                            ),
                                            Expanded(
                                              child: Wrap(
                                                spacing:
                                                    10, // Add spacing between correct answers
                                                children: student['result']
                                                            [resultIndex]
                                                        ['correctAnswer']
                                                    .map<Widget>((item) {
                                                  return Text(
                                                    item.toString(),
                                                    style: GoogleFonts.rubik(
                                                        color:
                                                            const Color(0xff004C92)),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(
              height: 5,
            ),
          ],
        );
      },
    );
  }

 Future<void> _createAndDownloadPdf() async {
  final pdf = pw.Document();
  final List players = roomDataProvider['players']
      .where((player) => player['playerType'] != 'X') // Исключаем создателя комнаты
      .toList();

  final ttf = await rootBundle.load('fonts/RobotoFlex-Regular.ttf');
  final font = pw.Font.ttf(ttf.buffer.asByteData());

  for (var player in players) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final playerResults = player['result'];
          return [
            pw.Center(
              child: pw.Text(
                'Окуучулардын жооптору',
                style: pw.TextStyle(
                  fontSize: 24,
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#004C92'),
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Информация об игроке и количестве правильных ответов
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: PdfColor.fromHex('#004C92'), width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      player['nickname'],
                      style: pw.TextStyle(
                        fontSize: 18,
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#004C92'),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: PdfColor.fromHex('#004C92'), width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      '${player['correctAnswer']} / ${roomDataProvider['questions'].length}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 18,
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#004C92'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // Список вопросов и ответов для каждого игрока
            ..._buildPlayerResults(playerResults, font), // Вызов функции для обработки вопросов
            pw.SizedBox(height: 30), // Отступ между игроками
          ];
        },
      ),
    );
  }

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}

// Функция для разбивки вопросов на страницы
List<pw.Widget> _buildPlayerResults(List playerResults, pw.Font font) {
  const int maxQuestionsPerPage = 5; // Количество вопросов на одной странице
  List<pw.Widget> widgets = [];

  for (var i = 0; i < playerResults.length; i += maxQuestionsPerPage) {
    final questionBatch = playerResults.skip(i).take(maxQuestionsPerPage).toList();

    widgets.add(
      pw.Wrap(
        spacing: 0,
        children: questionBatch.map<pw.Widget>((result) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                width: 1,
                color: PdfColor.fromHex('#004C92'),
                style: pw.BorderStyle.solid,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  result['question'],
                  style: pw.TextStyle(
                    font: font,
                    color: PdfColor.fromHex('#004C92'),
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Row(
                  children: [
                    pw.Container(
                      width: 7,
                      height: 7,
                      decoration: pw.BoxDecoration(
                        color: result['correct']
                            ? PdfColor.fromHex('#088273')
                            : PdfColor.fromHex('#BA0F43'),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Wrap(
                        spacing: 10,
                        children: result['answer']
                            .map<pw.Widget>((item) {
                          return pw.Text(
                            '${item.toString()}, ',
                            style: pw.TextStyle(
                              font: font,
                              color: PdfColor.fromHex('#004C92'),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                if (!result['correct'])
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Туура жообу: ',
                        style: pw.TextStyle(
                          font: font,
                          color: PdfColor.fromHex('#004C92'),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Wrap(
                          spacing: 10,
                          children: result['correctAnswer']
                              .map<pw.Widget>((item) {
                            return pw.Text(
                              item.toString(),
                              style: pw.TextStyle(
                                font: font,
                                color: PdfColor.fromHex('#004C92'),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  return widgets;
}
}
