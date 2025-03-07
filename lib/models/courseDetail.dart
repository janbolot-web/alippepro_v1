// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'dart:convert';

class CourseDetail {
  final String id;
  final String title;
  final String duration;
  final String description;
  final int price;
  final String previewImgUrl;
  final String previewVideoUrl;
  final modules;
  final courseId;
  final bgImage;

  CourseDetail(
      {required this.id,
      required this.title,
      required this.duration,
      required this.description,
      required this.price,
      required this.previewImgUrl,
      required this.previewVideoUrl,
      required this.modules,
      required this.courseId,
      required this.bgImage});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'description': description,
      'price': price,
      'previewImgUrl': previewImgUrl,
      'previewVideoUrl': previewVideoUrl,
      'modules': modules,
      'courseId': courseId,
      'bgImage': bgImage,
    };
  }

  factory CourseDetail.fromMap(Map<String, dynamic> map) {
    return CourseDetail(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      previewImgUrl: map['previewImgUrl'] ?? '',
      previewVideoUrl: map['previewVideoUrl'] ?? '',
      modules: map['modules'] ?? '',
      courseId: map['courseId'] ?? '',
      bgImage: map['bgImage'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CourseDetail.fromJson(String source) =>
      CourseDetail.fromMap(json.decode(source));
}
