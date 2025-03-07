import 'dart:convert';
import 'dart:developer';

import 'package:alippepro_v1/features/home/home.dart';
import 'package:alippepro_v1/features/loginNew/login_screen.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:alippepro_v1/models/user.dart';
import 'package:alippepro_v1/providers/user_provider.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:alippepro_v1/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String token,
    required String avatarUrl,
    required String roles,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        avatarUrl: 'avatarUrl',
        token: '',
        roles: roles,
      );

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/auth/register'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      void onSucces() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final userData = jsonDecode(res.body);

        userProvider.setUser(jsonEncode(userData));
        await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
        // saveDataToLocalStorage('user', jsonEncode(userData));
        await prefs.setString('user', jsonEncode(userData));
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      }

      var error = jsonDecode(res.body);

      if (res.statusCode == 200) {
        onSucces();
      } else {
        // ignore: use_build_context_synchronously
        showSnackBar(context, error['message'].toString());
      }
// await prefs.setString('user', userData);

      // ignore: use_build_context_synchronously
      // httpErrorHandle(
      //   response: res,
      //   context: context,
      //   onSuccess:
      // );
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/auth/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var error = jsonDecode(res.body);

      void onSucces() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final userData = jsonDecode(res.body)['data'];

        userProvider.setUser(jsonEncode(userData));
        await prefs.setString(
            'x-auth-token', jsonDecode(res.body)['data']['token']);
        await prefs.setString('user', jsonEncode(userData));
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      }

      if (res.statusCode == 200) {
        onSucces();
      } else {
        // ignore: use_build_context_synchronously
        showSnackBar(context, error['message'].toString());
      }

      // ignore: use_build_context_synchronously
      // httpErrorHandle(
      //   response: res,
      //   context: context,
      //   onSuccess: () async {

      //   },

      // );
    } catch (e) {
      // ignore: use_build_context_synchronously
      // showSnackBar(context, e.toString());
    }
  }

  // get user data
  // void getUserData(
  //   BuildContext context,
  // ) async {
  //   try {
  //     var userProvider = Provider.of<UserProvider>(context, listen: false);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString('x-auth-token');

  //     if (token == null) {
  //       prefs.setString('x-auth-token', '');
  //     }

  //     var tokenRes = await http.get(
  //       Uri.parse('${Constants.uri}/auth/me'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': token!,
  //       },
  //     );

  //     var response = jsonDecode(tokenRes.body);
  //     Map<String, dynamic> ne = {};
  //     ne['token'] = token;
  //     ne['email'] = response['email'];
  //     ne['id'] = response['id'];
  //     ne['name'] = response['name'];
  //     ne['avatarUrl'] = response['avatarUrl'];
  //     ne['roles'] = response['roles'];
  //     ne['courses'] = response['courses'];
  //     ne['createdAt'] = response['createdat'];
  //     ne['updatedAt'] = response['updatedAt'];
  //     // response.add(ne);
  //     var userRes = jsonEncode(ne);

  //     userProvider.setUser(userRes);
  //     await prefs.setString('user', userRes);
  //     // if (response == true) {
  //     //   http.Response userRes = await http.get(
  //     //     Uri.parse('${Constants.uri}/auth/me'),
  //     //     headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': token},
  //     //   );
  //     //
  //     // }
  //   } catch (e) {
  //     // ignore: use_build_context_synchronously
  //     // showSnackBar(context, e.toString());
  //   }
  // }

  void signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', '');
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void getAllUsers(BuildContext context) async {
    try {
      var usersProvider = Provider.of<UsersProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }
      var users = await http.get(
        Uri.parse('${Constants.uri}/getUsers'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!
        },
      );
      var response = jsonDecode(users.body);
      Map<String, dynamic> ne = {};
      ne['users'] = response;
      var userRes = jsonEncode(ne);
      usersProvider.setUsers(userRes);
      // ignore: empty_catches
    } catch (e) {}
  }

  void deleteUserAccount(userId) async {
    try {
      await http.delete(
        Uri.parse('${Constants.uri}/removeUser/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('user');
    } catch (e) {
      log(e.toString());
    }
  }

  getMe(userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/auth/getMe?userId=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print('response.statusCode ${response.statusCode}');
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await saveDataToLocalStorage('user', jsonEncode(userData));
        return {"statusCode": response.statusCode, "userData": userData};
      } else {
        return {
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
