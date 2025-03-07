import 'package:alippepro_v1/models/chatgpt.dart';
import 'package:flutter/material.dart';

class ChatgptProvider extends ChangeNotifier {
  Chatgpt _chatgpt = Chatgpt(
    response: '',
  );
  Chatgpt get chatgpt => _chatgpt;

  void setChatgpt(String chatgpt) {
    _chatgpt = Chatgpt.fromJson(chatgpt);
    notifyListeners();
  }

  void setChatgptFromModel(Chatgpt chatgpt) {
    _chatgpt = chatgpt;
    notifyListeners();
  }
}

class QuizProvider extends ChangeNotifier {
  Quiz _quiz = Quiz(
    response: [],
  );
  Quiz get quiz => _quiz;

  void setQuiz(String quiz) {
    _quiz = Quiz.fromJson(quiz);
    notifyListeners();
  }

  void setQuizFromModel(Quiz quiz) {
    _quiz = quiz;
    notifyListeners();
  }
}