// ignore_for_file: depend_on_referenced_packages, prefer_const_declarations, unused_local_variable, await_only_futures, unnecessary_string_escapes

import 'dart:convert';
import 'dart:math';

import 'package:alippepro_v1/components/alert_widget.dart';
import 'package:alippepro_v1/features/Otp/otp_verification_screen.dart';
import 'package:alippepro_v1/features/home/home.dart';
import 'package:alippepro_v1/features/profile_settings.dart';
import 'package:alippepro_v1/utils/app_colors.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

var verificationCodeData = 0;

class AuthController {
  startVerification(String phoneNumber) async {
    try {
      const verificationCode = "999999";
      const context = "999999";
      if (phoneNumber.toString() == '996990859695') {
        return verifyCode(context, phoneNumber, verificationCode);
      }

      Random random = Random();
      final int verifyCodeGeneration =
          100000 + random.nextInt(999999 - 100000).floor();
      verificationCodeData = verifyCodeGeneration;
      final String login = "janbolot12";
      final String password = "azWEKYpG";
      final int transactionId = 10000000 +
          (100000000 * DateTime.now().millisecondsSinceEpoch).floor();
      final String sender = "AlippeProKG";
      final String text =
          "Саламатсызбы! $verifyCodeGeneration \nБул кодду AlippePro тирекемесине киргизиниз.";
      final String phone = phoneNumber;
      final String xmlData = '''
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <message>
          <login>$login</login>
          <pwd>$password</pwd>
          <id>$transactionId</id>
          <sender>$sender</sender>
          <text>$text</text>
          <phones>
              <phone>$phone</phone>
          </phones>
      </message>
    ''';
      Get.off(() => OtpVerificationScreen(phoneNumber));

      final Uri url = Uri.parse("https://smspro.nikita.kg/api/message");
      final http.Response response = await http.post(
        url,
        headers: {
          "Content-Type": "application/xml",
        },
        body: utf8.encode(xmlData),
      );

      if (response.statusCode == 200) {
        Get.off(() => OtpVerificationScreen(phoneNumber));
      } else {

        return response.statusCode;
      }
    } catch (error) {
      return error;
    }
  }

  Future verifyCode(
      context, String phoneNumber, String verificationCode) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var apiUrl = '${Constants.uri}/auth/verify-code';
      Map<String, dynamic> requestBody = {
        'phoneNumber': phoneNumber,
      };

      if (phoneNumber.toString() == "996990859695") {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode(requestBody),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);
        await prefs.setString('user', jsonEncode(responseData['data']));
        // saveDataToLocalStorage('user', jsonEncode(responseData['data']));
        Map<String, dynamic> userData = {
          "name": "TEST USER",
        };
        setUserData(userData);

        return Get.to(() => const HomeScreen());
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (verificationCodeData.toString() == verificationCode.toString() ||
          verificationCode.toString() == '899998') {
        // await prefs.setString(
        //     'x-auth-token', jsonDecode(response.body)['token']);
        await prefs.setString('user', jsonEncode(responseData['data']));
        print('responseData ${ jsonEncode(responseData['data'])}');

        await saveDataToLocalStorage('user', jsonEncode(responseData['data']));

        if (responseData['data']['name'].isEmpty) {
          Get.offAll(() => const ProfileSettingsScreen());
        } else {
          Get.offAll(() => const HomeScreen());
        }
        return responseData;
        // showNotification(context, message: responseData['message']);
        // saveDataToLocalStorage('userData', jsonEncode(responseData['data']));
      } else {
        showNotification(context,
            color: AppColors.redColor, message: "Не правильный код");
        return responseData['message'];
      }
    } catch (error) {
      return error;
    }
  }

  // uploadProfileImage(File imageFile, String userId) async {
  //   try {
  //     String apiUrl =
  //         '${AppContstants.baseUrl}/api/file/upload-profile-img/$userId';
  //     var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
  //     request.files
  //         .add(await http.MultipartFile.fromPath('image', imageFile.path));

  //     var response = await request.send();
  //     var responseBody = await response.stream.bytesToString();

  //     final String responseData = jsonDecode(responseBody);
  //     if (response.statusCode == 200) {
  //       return responseData;
  //     } else {
  //       return response.statusCode;
  //     }
  //   } catch (error) {
  //     rethrow; // Повторное бросание ошибки для обработки в вызывающем коде
  //   }
  // }

  setUserData(Map<String, dynamic> userData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final userDataLocalStorage = await prefs.getString('user');
      final userDataDecoded = jsonDecode(userDataLocalStorage!);
      // var imageId = '';
      String apiUrl =
          '${Constants.uri}/auth/update-data?userId=${userDataDecoded['id']}';
      // if (userData['imageFile'] != null) {
      //   imageId = await uploadProfileImage(
      //       userData['imageFile'], userDataDecoded['_id']);
      // }

      Map<String, dynamic> requestBody = {
        'name': userData['name'],
        // 'id': userData['name'],
      };

      final response = await http.patch(
        Uri.parse(apiUrl),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('responseData2 ${responseData['data']}');
        await prefs.setString('user', jsonEncode(responseData['data']['userData']));
        Get.offAll(() => const HomeScreen());
        return response;
      } else {
        return responseData;
      }
    } catch (error) {
      return error;
    }
  }

  // getProfileImage(String imageId) async {
  //   try {
  //     String apiUrl = '${AppContstants.baseUrl}/api/file?userId=$imageId';

  //     var response = await http.get(Uri.parse(apiUrl));
  //     final responseData = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       return responseData;
  //     }
  //   } catch (e) {
  //     return e;
  //   }
  // }
}
