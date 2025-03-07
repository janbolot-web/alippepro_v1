import 'package:alippepro_v1/features/games/screens/game_screen.dart';
import 'package:alippepro_v1/features/games/views/resultQuiz.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/recources/socket_client.dart';
import 'package:alippepro_v1/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  // Persistent room ID storage key
  static const String _persistentRoomIdKey = 'persistent_room_id';
  static const String _persistentPlayerIdKey = 'persistent_player_id';

  // Original room ID to maintain consistency
  String _originalRoomId = '';
  String _originalPlayerId = '';

  Socket get socketClient => _socketClient;

  // Для отслеживания синхронизации времени
  int _timeDifference = 0;

  // Инициализация сокета
  void initSocket(BuildContext context) {
    // Загрузить сохраненные ID при инициализации
    _loadPersistentIds();

    // Запрос времени сервера для синхронизации
    requestServerTime();

    // Настройка обработчиков ошибок и переподключений
    setupErrorHandling(context);

    // Настройка обработчика переподключения
    setupReconnectionHandling(context);

    // Регистрация клиента с информацией о платформе
    registerClient();
  }

  // Загружает сохраненные ID комнаты и игрока
  Future<void> _loadPersistentIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _originalRoomId = prefs.getString(_persistentRoomIdKey) ?? '';
      _originalPlayerId = prefs.getString(_persistentPlayerIdKey) ?? '';

      print(
          'Loaded persistent roomId: $_originalRoomId, playerId: $_originalPlayerId');
    } catch (e) {
      print('Error loading persistent IDs: $e');
    }
  }

  // Сохраняет ID комнаты и игрока для последующего использования
  Future<void> _savePersistentIds(String roomId, String playerId) async {
    if (roomId.isEmpty || playerId.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_persistentRoomIdKey, roomId);
      await prefs.setString(_persistentPlayerIdKey, playerId);

      // Обновляем локальные переменные
      _originalRoomId = roomId;
      _originalPlayerId = playerId;

      print('Saved persistent roomId: $roomId, playerId: $playerId');
    } catch (e) {
      print('Error saving persistent IDs: $e');
    }
  }

  // Настройка обработки переподключения
  void setupReconnectionHandling(BuildContext context) {
    _socketClient.on('connect', (_) {
      print('Socket connected with ID: ${_socketClient.id}');

      // При переподключении и наличии сохраненных ID - пытаемся восстановить сессию
      if (_originalRoomId.isNotEmpty && _originalPlayerId.isNotEmpty) {
        print(
            'Attempting to reconnect to room: $_originalRoomId with playerId: $_originalPlayerId');
        _socketClient.emit('reconnect_to_room', {
          'roomId': _originalRoomId,
          'playerId': _originalPlayerId,
          'socketId': _socketClient.id
        });
      }
    });

    _socketClient.on('reconnect', (_) {
      print('Socket reconnected');
      tryReconnect(context);
    });

    // Обработчик успешного восстановления сессии
    _socketClient.on('reconnection_successful', (data) {
      print('Reconnection successful: $data');
      if (context.mounted) {
        var roomDataProvider =
            Provider.of<RoomDataProvider>(context, listen: false);
        roomDataProvider.updateRoomData(data['room']);
      }
    });
  }

  // Запрос времени сервера для синхронизации
  void requestServerTime() {
    _socketClient.emit('request_server_time');

    _socketClient.on('server_time', (data) {
      int serverTime = data['timestamp'];
      int localTime = DateTime.now().millisecondsSinceEpoch;
      _timeDifference = serverTime - localTime;
    });
  }

  // Регистрация клиента с информацией о платформе
  void registerClient() {
    final String platform =
        Theme.of(Get.context!).platform == TargetPlatform.iOS
            ? "ios"
            : "android";

    _socketClient.emit("register_client", {
      "platform": platform,
      "deviceInfo": {
        "appVersion": "1.0.0", // Здесь можно добавить больше информации
        "reconnectAttempt":
            _originalRoomId.isNotEmpty, // Флаг, что это попытка переподключения
        "persistentRoomId": _originalRoomId,
        "persistentPlayerId": _originalPlayerId
      }
    });
  }

  // Настройка обработки ошибок
  void setupErrorHandling(BuildContext context) {
    _socketClient.on("error_occurred", (data) {
      String errorMessage = data["errorMessage"] ?? "Неизвестная ошибка";
      String errorCode = data["errorCode"] ?? "UNKNOWN";

      print("Socket error: $errorCode - $errorMessage");

      // Показать пользователю
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Ошибка: $errorMessage"),
        backgroundColor: Colors.red,
      ));

      // Обработка специфических ошибок
      if (errorCode == "ROOM_NOT_FOUND" ||
          errorCode == "GAME_ALREADY_STARTED") {
        Get.back(); // Вернуться на предыдущий экран
      }
    });
  }

  // Попытка переподключения при потере соединения
  void tryReconnect(BuildContext context) {
    // Используем сохраненные ID если они есть
    String roomId = _originalRoomId;
    String playerId = _originalPlayerId;

    // Если нет сохраненных ID, попробуем получить из провайдера
    if (roomId.isEmpty || playerId.isEmpty) {
      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);

      if (roomDataProvider.roomData.isNotEmpty &&
          roomDataProvider.playerId.isNotEmpty) {
        roomId = roomDataProvider.roomData['_id'] ?? '';
        playerId = roomDataProvider.playerId;
      }
    }

    // Если есть ID комнаты и игрока, отправляем запрос на переподключение
    if (roomId.isNotEmpty && playerId.isNotEmpty) {
      print(
          'Emitting reconnect_attempt with roomId: $roomId, playerId: $playerId');
      _socketClient.emit("reconnect_attempt", {
        "roomId": roomId,
        "playerId": playerId,
        "socketId": _socketClient.id
      });
    }
  }

  // Создание комнаты
  void createRoom(String nickname, String response) {
    if (nickname.isNotEmpty) {
      _socketClient.emit('createRoom', {
        'nickname': nickname,
        'response': response,
      });
    }
  }

  // Присоединение к комнате
  void joinRoom(String nickname, String roomId, String playerId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      _socketClient.emit('joinRoom', {
        'nickname': nickname,
        'roomId': roomId,
        'playerId': playerId,
      });
    }
  }

  // Запрос на обновление состояния комнаты
  void requestRoomState(String roomId) {
    // Если передан пустой roomId, используем сохраненный
    if (roomId.isEmpty && _originalRoomId.isNotEmpty) {
      roomId = _originalRoomId;
    }

    if (roomId.isNotEmpty) {
      _socketClient.emit('requestRoomState', {'roomId': roomId});
    }
  }

  // Начало игры
  void startGame(String roomId) {
    // Если передан пустой roomId, используем сохраненный
    if (roomId.isEmpty && _originalRoomId.isNotEmpty) {
      roomId = _originalRoomId;
    }

    if (roomId.isNotEmpty) {
      _socketClient.emit('startGame', {
        'roomId': roomId,
      });
    }
  }

  // Отправка ответа
  void tapGrid(int points, String roomId, String playerId, bool correct,
      dynamic question, List<String> answer, List correctAnswer) {
    // If empty roomId or playerId, use saved values
    if (roomId.isEmpty && _originalRoomId.isNotEmpty) {
      roomId = _originalRoomId;
    }
    if (playerId.isEmpty && _originalPlayerId.isNotEmpty) {
      playerId = _originalPlayerId;
    }

    // Get room data provider to access current question index
    var roomDataProvider =
        Provider.of<RoomDataProvider>(Get.context!, listen: false);

    // Determine current question index
    int questionIndex = roomDataProvider.roomData['currentQuestion'] ?? 0;

    // Generate unique request ID to prevent duplication
    String requestId =
        "${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(10000)}";

    print("Sending answer for question $questionIndex");

    _socketClient.emit('tap', {
      'points': points,
      'roomId': roomId,
      'playerId': playerId,
      'correct': correct,
      'question': question,
      'answer': answer,
      'correctAnswer': correctAnswer,
      'requestId': requestId,
      'questionIndex': questionIndex,
      'socketId': _socketClient.id
    });

    // Set up a timeout to handle potential server non-response
    // var responseTimeout = Future.delayed(Duration(seconds: 3), () {
    //   print("No server response for answer request $requestId after 3 seconds");
    // });

    // // Listen for different response types
    // var answerProcessed = _socketClient.once('answer_processed', (data) {
    //   if (data['requestId'] == requestId) {
    //     print(
    //         'Answer successfully processed: ${data['correct'] ? 'Correct' : 'Incorrect'}');
    //   }
    // });

    // var requestProcessed =
    //     _socketClient.once('request_already_processed', (data) {
    //   if (data['requestId'] == requestId) {
    //     print('Answer request was already processed');
    //   }
    // });

    // var answerRejected = _socketClient.once('answer_rejected', (data) {
    //   String reason = data['reason'] ?? 'unknown';
    //   print('Answer rejected: $reason');

    //   // More informative error messages
    //   if (reason == 'already_answered') {
    //     showSnackBar(Get.context!, 'Вы уже ответили на этот вопрос');
    //   } else {
    //     showSnackBar(Get.context!, 'Ответ отклонен: $reason');
    //   }
    // });
  }

// Запрос на проверку ответов
  void hasAnswers(String roomId) {
    // Если передан пустой roomId, используем сохраненный
    if (roomId.isEmpty && _originalRoomId.isNotEmpty) {
      roomId = _originalRoomId;
    }

    if (roomId.isNotEmpty) {
      _socketClient.emit('hasAnswers', {'roomId': roomId});
    }
  }

  // Завершение игры
  void endGame(String roomId, bool endGame, String playerId) {
    // Если передан пустой roomId или playerId, используем сохраненные
    if (roomId.isEmpty && _originalRoomId.isNotEmpty) {
      roomId = _originalRoomId;
    }
    if (playerId.isEmpty && _originalPlayerId.isNotEmpty) {
      playerId = _originalPlayerId;
    }

    _socketClient.emit(
        'end', {'roomId': roomId, 'endGame': endGame, 'playerId': playerId});
  }

  // Обработчик успешного создания комнаты
  void createRoomSuccessListener(BuildContext context) {
    _socketClient.on('createRoomSuccess', (roomData) {
      if (!context.mounted) return;

      String roomId = roomData[0]['_id'] ?? '';
      String playerId = roomData[0]['creator'] ?? '';

      // Сохраняем ID для последующего использования
      _savePersistentIds(roomId, playerId);

      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(roomData[0]);
      Provider.of<RoomDataProvider>(context, listen: false)
          .updatePlayerIdData(roomData[0]);

      Navigator.pushNamed(context, GameScreen.routeName,
          arguments: {'isAuthor': true});
    });
  }

  // Обработчик успешного присоединения к комнате
  void joinRoomSuccessListener(BuildContext context) {
    _socketClient.on('joinRoomSuccess', (roomData) {
      if (!context.mounted) return;

      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);

      String roomId = roomData[0]['_id'] ?? '';
      String playerId = '';

      // Находим ID текущего игрока
      if (roomData[0]['players'] != null) {
        for (var player in roomData[0]['players']) {
          // Находим игрока, который соответствует текущему socketId
          if (player['socketID'] == _socketClient.id) {
            playerId = player['playerId'] ?? '';
            break;
          }
        }
      }

      // Сохраняем ID для последующего использования
      if (roomId.isNotEmpty && playerId.isNotEmpty) {
        _savePersistentIds(roomId, playerId);
      }

      if (roomDataProvider.playerId.isEmpty) {
        roomDataProvider.updateRoomData(roomData[0]);
        roomDataProvider.updatePlayerIdData(roomData[0]);
      }

      Navigator.pushNamed(context, GameScreen.routeName,
          arguments: {'isAuthor': false});
    });
  }

  // Обработчик обновления состояния комнаты
  void roomStateListener(BuildContext context) {
    _socketClient.on('roomState', (roomData) {
      if (!context.mounted) return;

      String receivedRoomId = roomData[0]['_id'] ?? '';

      // Проверяем, соответствует ли полученный ID нашему сохраненному ID
      if (_originalRoomId.isNotEmpty && receivedRoomId != _originalRoomId) {
        print(
            'Warning: Received roomId ($receivedRoomId) differs from original ($_originalRoomId)');

        // Если это другая комната и у нас есть сохраненный ID, запрашиваем правильную комнату
        requestRoomState(_originalRoomId);
        return;
      }

      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(roomData[0]);

      // Обновляем разницу во времени
      if (roomData[0]['serverTime'] != null) {
        int serverTime = roomData[0]['serverTime'];
        int localTime = DateTime.now().millisecondsSinceEpoch;
        _timeDifference = serverTime - localTime;

        Provider.of<RoomDataProvider>(context, listen: false)
            .updateTimeDifference(_timeDifference);
      }
    });
  }

  // Обработчик ошибок
  void errorOccuredListener(BuildContext context) {
    _socketClient.on('errorOccured', (data) {
      if (!context.mounted) return;
      showSnackBar(context, data);
    });
  }

  // Обработчик обновления комнаты
  void updateRoomListener(BuildContext context) {
    _socketClient.on('updateRoom', (data) {
      if (!context.mounted) return;

      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);

      // Проверяем, что data не null
      if (data == null) {
        print("Получены пустые данные в событии updateRoom");
        return;
      }

      // Обработка разных форматов данных
      if (data is Map<String, dynamic>) {
        if (data.containsKey('room') && data['room'] != null) {
          // Проверяем, соответствует ли ID комнаты нашему сохраненному ID
          String receivedRoomId = data['room']['_id'] ?? '';
          if (_originalRoomId.isNotEmpty && receivedRoomId != _originalRoomId) {
            print(
                'Warning: Received roomId ($receivedRoomId) differs from original ($_originalRoomId)');
            // Если ID не совпадает, игнорируем обновление
            return;
          }

          // Новый формат: данные в поле 'room'
          int newVersion = data['version'] ?? 0;
          int currentVersion = roomDataProvider.currentVersion;

          if (newVersion >= currentVersion) {
            roomDataProvider.updateRoomData(data['room']);
            roomDataProvider.updateVersion(newVersion);

            // Обновляем разницу во времени
            if (data['serverTime'] != null) {
              int serverTime = data['serverTime'];
              int localTime = DateTime.now().millisecondsSinceEpoch;
              _timeDifference = serverTime - localTime;
              roomDataProvider.updateTimeDifference(_timeDifference);
            }
          }
        } else {
          // Проверяем, соответствует ли ID комнаты нашему сохраненному ID
          String receivedRoomId = data['_id'] ?? '';
          if (_originalRoomId.isNotEmpty && receivedRoomId != _originalRoomId) {
            print(
                'Warning: Received roomId ($receivedRoomId) differs from original ($_originalRoomId)');
            // Если ID не совпадает, игнорируем обновление
            return;
          }

          // Старый формат: данные напрямую
          roomDataProvider.updateRoomData(data);
        }
      } else {
        print("Получены данные неверного формата: ${data.runtimeType}");
      }
    });
  }

  // Обработчик отключения игрока
  void playerDisconnectedListener(BuildContext context) {
    _socketClient.on('player_disconnected', (data) {
      if (!context.mounted) return;

      // Проверяем, соответствует ли ID комнаты нашему сохраненному ID
      String receivedRoomId = data['room']['_id'] ?? '';
      if (_originalRoomId.isNotEmpty && receivedRoomId != _originalRoomId) {
        print(
            'Warning: Received roomId ($receivedRoomId) differs from original ($_originalRoomId)');
        // Если ID не совпадает, игнорируем обновление
        return;
      }

      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);
      roomDataProvider.updateRoomData(data['room']);

      // Показать уведомление о том, что игрок отключился
      String playerNickname = "Игрок";
      for (var player in data['room']['players']) {
        if (player['socketID'] == data['playerId']) {
          playerNickname = player['nickname'];
          break;
        }
      }

      showSnackBar(context, "$playerNickname отключился");
    });
  }

  // Обработчик запуска игры
  void gameStartingListener(BuildContext context) {
    _socketClient.on('game_starting', (data) {
      if (!context.mounted) return;

      // Проверяем, соответствует ли ID комнаты нашему сохраненному ID
      String receivedRoomId = data['room']['_id'] ?? '';
      if (_originalRoomId.isNotEmpty && receivedRoomId != _originalRoomId) {
        print(
            'Warning: Received roomId ($receivedRoomId) differs from original ($_originalRoomId)');
        // Если ID не совпадает, игнорируем обновление
        return;
      }

      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);
      roomDataProvider.updateRoomData(data['room']);

      // Сохраняем время начала игры
      int gameStartTime = data['startTime'];
      int serverTime = data['serverTime'];
      int localTime = DateTime.now().millisecondsSinceEpoch;
      _timeDifference = serverTime - localTime;

      roomDataProvider.updateTimeDifference(_timeDifference);
      roomDataProvider.updateGameStartTime(gameStartTime);
    });
  }

  // Обработчик автоматического завершения игры
  void gameAutoEndedListener(BuildContext context) {
    _socketClient.on('game_auto_ended', (data) {
      if (!context.mounted) return;

      // Проверяем, соответствует ли ID комнаты нашему сохраненному ID
      String receivedRoomId = data['room']['_id'] ?? '';
      if (_originalRoomId.isNotEmpty && receivedRoomId != _originalRoomId) {
        print(
            'Warning: Received roomId ($receivedRoomId) differs from original ($_originalRoomId)');
        // Если ID не совпадает, игнорируем обновление
        return;
      }

      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);
      roomDataProvider.updateRoomData(data['room']);
      roomDataProvider.updateGameEnd();

      // Показать уведомление и перейти к результатам
      showSnackBar(context, "Игра автоматически завершена из-за неактивности");
      Get.off(() => ScoreBoard(true, true));
    });
  }

  // Обработчик завершения игры
  void endGameListener(BuildContext context) {
    _socketClient.on('endGame', (data) {
      if (!context.mounted) return;

      // Проверяем, соответствует ли ID комнаты нашему сохраненному ID
      String receivedRoomId = data['room']['_id'] ?? '';
      if (_originalRoomId.isNotEmpty && receivedRoomId != _originalRoomId) {
        print(
            'Warning: Received roomId ($receivedRoomId) differs from original ($_originalRoomId)');
        // Если ID не совпадает, игнорируем обновление
        return;
      }

      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);
      roomDataProvider.updateRoomData(data['room']);
      roomDataProvider.updateGameEnd();

      Get.off(() => ScoreBoard(true, true));
    });
  }

  // Вспомогательная функция для обновления зависимых данных
  void _updateDependentData(BuildContext context, dynamic roomData) {
    var roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    // Обновление игроков
    if (roomData['players'] != null) {
      for (var player in roomData['players']) {
        if (player['playerType'] == 'X') {
          roomDataProvider.updatePlayer1(player);
        } else if (player['playerType'] == 'O') {
          roomDataProvider.updatePlayer2(player);
        }
      }
    }
  }

  // Очистка сохраненных ID при выходе из игры
  Future<void> clearPersistentIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_persistentRoomIdKey);
      await prefs.remove(_persistentPlayerIdKey);
      _originalRoomId = '';
      _originalPlayerId = '';
      print('Cleared persistent room and player IDs');
    } catch (e) {
      print('Error clearing persistent IDs: $e');
    }
  }
}
