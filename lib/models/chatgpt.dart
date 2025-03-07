// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

class Chatgpt {
  String? response;

  Chatgpt({this.response});

  Map<String, dynamic> toMap() {
    return {
      'response': response,
    };
  }

  factory Chatgpt.fromMap(Map<String, dynamic> map) {
    return Chatgpt(response: map['response']);
  }

  String toJson() => json.encode(toMap());

  factory Chatgpt.fromJson(String source) =>
      Chatgpt.fromMap(json.decode(source));
}

class Quiz {
  var response;

  Quiz({this.response});

  Map<String, dynamic> toMap() {
    return {
      'response': response,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(response: map['response']);
  }

  String toJson() => json.encode(toMap());

  factory Quiz.fromJson(String source) => Quiz.fromMap(json.decode(source));
}
