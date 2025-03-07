import 'dart:convert';

class Course {
  final String id;
  final String title;
  final String duration;
  final String description;
  final int price;
  final String previewImgUrl;
  final String previewVideoUrl;
  final String modules;
  final String courseId;
  final String bgImage;
  Course({
    required this.id,
    required this.title,
    required this.duration,
    required this.description,
    required this.price,
    required this.previewImgUrl,
    required this.previewVideoUrl,
    required this.modules,
    required this.courseId,
    required this.bgImage,
  });

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

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
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

  factory Course.fromJson(String source) => Course.fromMap(json.decode(source));
}
