// ignore_for_file: empty_catches, use_build_context_synchronously, duplicate_ignore

import 'dart:convert';

import 'package:alippepro_v1/providers/course_provider.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:alippepro_v1/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CourseService {
  getAllCourses(
    BuildContext context,
  ) async {
    try {
      // var courseProvider = Provider.of<CourseProvider>(context, listen: false);

      var courses = await http.get(
        Uri.parse('${Constants.uri}/getAllCourses'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var courseRes = [];

      var response = jsonDecode(courses.body);
      for (var i = 0; i < response.length; i++) {
        Map<String, dynamic> ne = {};
        ne['id'] = response[i]['id'];
        ne['title'] = response[i]['title'];
        ne['duration'] = response[i]['duration'];
        ne['price'] = response[i]['price'];
        ne['previewImgUrl'] = response[i]['previewImgUrl'];
        ne['bgImage'] = response[i]['bgImage'];
        courseRes.add(ne);
      }
      return courseRes;

      // courseProvider.setCourse(jsonEncode(courseRes));

      // Map<String, dynamic> ne = {};
      // ne['token'] = token;
      // ne['email'] = response['email'];
      // ne['id'] = response['id'];
      // ne['name'] = response['name'];
      // ne['roles'] = response['roles'];
      // ne['courses'] = response['courses'];
      // ne['createdAt'] = response['createdat'];
      // ne['updatedAt'] = response['updatedAt'];
      // var userRes = jsonEncode(ne);
    } catch (e) {
      // showSnackBar(context, e.toString());
    }
  }

  void getCourse({
    required BuildContext context,
    required String id,
  }) async {
    try {
      var courseDetailProvider =
          Provider.of<CourseDetailProvider>(context, listen: false);

      var course = await http.get(
        Uri.parse('${Constants.uri}/getCourse/${id.toString()}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var response = json.decode(course.body);

      Map<String, dynamic> ne = {};
      ne['id'] = response['_id'];
      ne['title'] = response['title'];
      ne['duration'] = response['duration'];
      ne['description'] = response['description'];
      ne['price'] = response['price'];
      ne['previewImgUrl'] = response['previewImgUrl'];
      ne['previewVideoUrl'] = response['previewVideoUrl'];
      ne['modules'] = response['modules'];
      ne['courseId'] = response['courseId'];
      var courseDetailRes = jsonEncode(ne);
      courseDetailProvider.setCourseDetail(courseDetailRes);

      // Map<String, dynamic> ne = {};
      // ne['token'] = token;
      // ne['email'] = response['email'];
      // ne['id'] = response['id'];
      // ne['name'] = response['name'];
      // ne['roles'] = response['roles'];
      // ne['courses'] = response['courses'];
      // ne['createdAt'] = response['createdat'];
      // ne['updatedAt'] = response['updatedAt'];
      // var userRes = jsonEncode(ne);
    } catch (e) {
      // ignore: use_build_context_synchronously
      // showSnackBar(context, e.toString());
    }
  }

  searchCourse({
    required BuildContext context,
    required String key,
  }) async {
    try {
      var data = {"key": key};

      var response = await http.post(Uri.parse('${Constants.uri}/searchCourse'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data));
      var courseRes = [];
      var courses = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (var i = 0; i < courses.length; i++) {
          Map ne = {};
          ne['id'] = courses[i]['_id'];
          ne['title'] = courses[i]['title'];
          ne['duration'] = courses[i]['duration'];
          ne['price'] = courses[i]['price'];
          ne['bgImage'] = courses[i]['bgImage'];
          courseRes.add(ne);
        }
      }
      return courseRes;
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  getLesson(params) async {
    try {
      var response = await http.get(
        Uri.parse(
            '${Constants.uri}/getLesson/${params["courseId"]}?idLesson=${params['lessonId']}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  void addModuleToUser({
    moduleId,
    userId,
    courseId,
  }) async {
    try {
      await http.patch(Uri.parse('${Constants.uri}/addCourseToUser'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "params": {
              "moduleId": moduleId,
              "userId": userId,
              "courseId": courseId
            }
          }));
    } catch (e) {}
  }
}
