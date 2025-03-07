class Player {
  final String nickname;
  final String socketID;
  final double points;
  final String playerType;
  final int correctAnswer; // Изменено на int для согласованности с сервером
  final bool isConnected; // Добавлено для отслеживания состояния подключения
  final List<dynamic> result; // Результаты ответов игрока
  final List<int>? answeredQuestions; // Для отслеживания отвеченных вопросов
  final DateTime? lastDisconnectTime; // Время последнего отключения
  final DateTime? lastActivityTime; // Время последней активности
  
  Player({
    required this.nickname,
    required this.socketID,
    required this.points,
    required this.playerType,
    required this.correctAnswer,
    this.isConnected = true,
    required this.result,
    this.answeredQuestions,
    this.lastDisconnectTime,
    this.lastActivityTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'socketID': socketID,
      'points': points,
      'playerType': playerType,
      'correctAnswer': correctAnswer,
      'isConnected': isConnected,
      'result': result,
      'answeredQuestions': answeredQuestions,
      'lastDisconnectTime': lastDisconnectTime?.toIso8601String(),
      'lastActivityTime': lastActivityTime?.toIso8601String(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    // Безопасное преобразование correctAnswer в int
    int correctAnswerInt;
    if (map['correctAnswer'] is String) {
      correctAnswerInt = int.tryParse(map['correctAnswer']) ?? 0;
    } else {
      correctAnswerInt = map['correctAnswer'] ?? 0;
    }
    
    // Парсинг дат
    DateTime? lastDisconnect;
    if (map['lastDisconnectTime'] != null) {
      try {
        lastDisconnect = DateTime.parse(map['lastDisconnectTime']);
      } catch (e) {
        print("Error parsing lastDisconnectTime: $e");
      }
    }
    
    DateTime? lastActivity;
    if (map['lastActivityTime'] != null) {
      try {
        lastActivity = DateTime.parse(map['lastActivityTime']);
      } catch (e) {
        print("Error parsing lastActivityTime: $e");
      }
    }
    
    return Player(
      nickname: map['nickname'] ?? '',
      socketID: map['socketID'] ?? '',
      points: (map['points'] is int || map['points'] is double) 
          ? (map['points'] ?? 0).toDouble()
          : double.tryParse(map['points']?.toString() ?? '0') ?? 0.0,
      playerType: map['playerType'] ?? '',
      correctAnswer: correctAnswerInt,
      isConnected: map['isConnected'] ?? true,
      result: map['result'] ?? [],
      answeredQuestions: map['answeredQuestions'] != null 
          ? List<int>.from(map['answeredQuestions'])
          : null,
      lastDisconnectTime: lastDisconnect,
      lastActivityTime: lastActivity,
    );
  }

  Player copyWith({
    String? nickname,
    String? socketID,
    double? points,
    String? playerType,
    int? correctAnswer,
    bool? isConnected,
    List<dynamic>? result,
    List<int>? answeredQuestions,
    DateTime? lastDisconnectTime,
    DateTime? lastActivityTime,
  }) {
    return Player(
      nickname: nickname ?? this.nickname,
      socketID: socketID ?? this.socketID,
      points: points ?? this.points,
      playerType: playerType ?? this.playerType,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      isConnected: isConnected ?? this.isConnected,
      result: result ?? this.result,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      lastDisconnectTime: lastDisconnectTime ?? this.lastDisconnectTime,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
    );
  }
}