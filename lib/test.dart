import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTStreamPage extends StatefulWidget {
  const ChatGPTStreamPage({super.key});

  @override
  _ChatGPTStreamPageState createState() => _ChatGPTStreamPageState();
}

class _ChatGPTStreamPageState extends State<ChatGPTStreamPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StreamController<String> _responseStreamController =
      StreamController<String>();
  bool _isLoading = false;
  String accumulatedResponse = "";

  Future<void> sendMessage(String message) async {
    final url = Uri.parse(
        "https://workers-playground-shiny-haze-2f78jjjj.janbolotcode.workers.dev/v1/chat/completions");
    final headers = {
      'Authorization': 'Bearer ghu_flwC3qPtwVTXX6VkxSLaxqJX3xIU1W2QexTG',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": message}
      ],
      "stream": true,
    });

    setState(() {
      _isLoading = true;
      accumulatedResponse = "";
    });

    try {
      final request = http.Request('POST', url)
        ..headers.addAll(headers)
        ..body = body;

      final response = await request.send();

      if (response.statusCode == 200) {
        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) {
          if (line.startsWith("data: ") && line.trim() != "data: [DONE]") {
            final jsonResponse =
                jsonDecode(line.substring(6)); // Убираем "data: "
            final content =
                jsonResponse['choices'][0]['delta']['content'] ?? "";

            setState(() {
              accumulatedResponse += content;
            });

            _responseStreamController.add(accumulatedResponse);

            // Прокрутка вниз после обновления сообщения
            _scrollToBottom();
          }
        }, onDone: () {
          setState(() {
            _isLoading = false;
          });
        }, onError: (error) {
          _responseStreamController.add("Ошибка: $error");
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        _responseStreamController.add("Ошибка запроса: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _responseStreamController.add("Ошибка: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _responseStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading == false) {
      print(accumulatedResponse);
    }
    return Scaffold(
      appBar: AppBar(title: const Text("ChatGPT Markdown")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<String>(
              stream: _responseStreamController.stream,
              builder: (context, snapshot) {
                return SingleChildScrollView(
                    controller: _scrollController, // Контроллер для скроллинга
                    padding: const EdgeInsets.all(16.0),
                    child: MarkdownBody(
                      data: snapshot.data ?? "Введите сообщение для ChatGPT",
                      styleSheet: MarkdownStyleSheet(
                        h1: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h4: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        h5: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        h6: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        p: GoogleFonts.montserrat(
                          fontSize: 14,
                        ),
                        blockquote: GoogleFonts.montserrat(
                            fontSize: 14, fontStyle: FontStyle.italic),
                        code: GoogleFonts.montserrat(),
                        listBullet: GoogleFonts.montserrat(fontSize: 14),
                      ),
                    ));
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Введите сообщение",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      sendMessage(message);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
