// ignore_for_file: empty_catches

import 'package:alippepro_v1/models/player.dart';
import 'package:flutter/material.dart';

class RoomDataProvider extends ChangeNotifier {
  Map<String, dynamic> _roomData = {};
  bool _showGameResults = false;
  Map<String, dynamic> _infoData = {};
  String _playerId = '';
  final int _playerCount = 0;
  Map<String, dynamic> _chatGPTData = {};
  int _filledBoxes = 0;
  bool _gameEnd = false;
  int _timeDifference = 0;
  int _currentVersion = 0;
  int _gameStartTime = 0;
  bool _isLoadingQuestions = false; // Добавлено: состояние загрузки вопросов

  Player _player1 = Player(
      nickname: '',
      socketID: '',
      points: 0,
      playerType: 'X',
      correctAnswer: 0,
      isConnected: true,
      result: []);

  Player _player2 = Player(
      nickname: '',
      socketID: '',
      points: 0,
      playerType: 'O',
      correctAnswer: 0,
      isConnected: true,
      result: []);

  Map<String, dynamic> get roomData => _roomData;
  bool get showGameResults => _showGameResults;
  Map<String, dynamic> get infoData => _infoData;
  String get playerId => _playerId;
  int get playerCount => _playerCount;
  Map<String, dynamic> get chatGPTData => _chatGPTData;
  int get filledBoxes => _filledBoxes;
  Player get player1 => _player1;
  Player get player2 => _player2;
  bool get gameEnd => _gameEnd;
  int get timeDifference => _timeDifference;
  int get currentVersion => _currentVersion;
  int get gameStartTime => _gameStartTime;
  bool get isLoadingQuestions => _isLoadingQuestions; // Геттер для состояния загрузки

  // Обновление данных от ChatGPT с поддержкой инкрементального добавления вопросов
  void updateChatGPTData(Map<String, dynamic> data) {
    try {
      if (data.containsKey('questions')) {
        // Проверка, создаем новый список или обновляем существующий
        if (_chatGPTData.isEmpty || !_chatGPTData.containsKey('questions')) {
          _chatGPTData = data;
        } else {
          // Если уже есть вопросы, обновляем их
          final newQuestions = data['questions'] as List;
          if (newQuestions.isNotEmpty) {
            _chatGPTData['questions'] = newQuestions;
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print("Ошибка обновления данных ChatGPT: $e");
    }
  }

  // Добавление одного нового вопроса в список
  void addQuestion(Map<String, dynamic> question) {
    try {
      if (_chatGPTData.isEmpty) {
        _chatGPTData = {'questions': [question]};
      } else if (!_chatGPTData.containsKey('questions')) {
        _chatGPTData['questions'] = [question];
      } else {
        (_chatGPTData['questions'] as List).add(question);
      }
      notifyListeners();
    } catch (e) {
      print("Ошибка добавления вопроса: $e");
    }
  }

  // Установка/изменение состояния загрузки вопросов
  void setLoadingQuestions(bool loading) {
    _isLoadingQuestions = loading;
    notifyListeners();
  }

  // Обновление разницы во времени для синхронизации с сервером
  void updateTimeDifference(int diff) {
    _timeDifference = diff;
    notifyListeners();
  }

  // Обновление версии данных для согласованности
  void updateVersion(int version) {
    _currentVersion = version;
    notifyListeners();
  }

  // Обновление времени начала игры
  void updateGameStartTime(int time) {
    _gameStartTime = time;
    notifyListeners();
  }

  void updateGameEnd() {
    _gameEnd = true;
    notifyListeners();
  }

  void updateShowGameResults(bool data) {
    try {
      _showGameResults = data;
    } catch (e) {}
    notifyListeners();
  }

  void updateInfoData(data) {
    try {
      _infoData = data;
    } catch (e) {}
    notifyListeners();
  }

  void updatePlayerIdData(Map<String, dynamic> data) {
    try {
      _playerId = data['playerId'];
      notifyListeners();
    } catch (e) {}
  }

  void updateRoomData(Map<String, dynamic> data) {
    try {
      if (data['room'] != null) {
        _roomData = data['room'];
      } else {
        _roomData = data;
      }
      notifyListeners();
    } catch (e) {
      print("Error updating room data: $e");
    }
  }

  void updatePlayer1(Map<String, dynamic> player1Data) {
    _player1 = Player.fromMap(player1Data);
    notifyListeners();
  }

  void updatePlayer2(Map<String, dynamic> player2Data) {
    _player2 = Player.fromMap(player2Data);
    notifyListeners();
  }

  void updateDisplayElements(int index, String choice) {
    _filledBoxes += 1;
    notifyListeners();
  }

  void setFilledBoxesTo0() {
    _filledBoxes = 0;
  }

  void removeAll() {
    _playerId = '';
    _gameEnd = false;
    _currentVersion = 0;
    _timeDifference = 0;
    _gameStartTime = 0;
    _isLoadingQuestions = false;
    
    // Отсроченный вызов notifyListeners() после завершения фазы сборки
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }
}