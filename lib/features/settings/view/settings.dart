import 'dart:convert';

import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var user;

  @override
  void initState() {
    super.initState();
    getUserLocalData();
    loadData();
  }

  Future getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    user = jsonDecode(response!);
    setState(() {});
  }

  var privacy_policy = '';
  Future loadData() async {
    // Чтение данных из assets
    String jsonString =
        await rootBundle.loadString('lib/utils/privacy_policy.json');
    // Десериализация JSON в объект
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    privacy_policy = jsonMap['content'];

    // return DataModel.fromJson(jsonMap);
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Не удается открыть $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    void signOutUser(BuildContext context) {
      AuthService().signOut(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Политика конфиденциальности'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      _launchURL('https://privacy.dpa.gov.kg/download/1060');
                    },
                  ),
                  ListTile(
                    title: const Text('Публичная оферта'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      _launchURL(
                          'https://drive.google.com/file/d/10tMvg7Fg98ZgaaQIEWzEkw5DiBwj7-gI/view?usp=sharing');
                    },
                  ),
                  ListTile(
                    title: const Text('Правила возврата и описание оплаты банковской карты'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      _launchURL(
                          'https://drive.google.com/file/d/1Zb3KqtcA3367P-3N2cCAS4tL-1mkTwF_/view?usp=sharing');
                    },
                  ),
                ],
              ),
            ),
            TextButton(
                onPressed: () => signOutUser(context),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.redAccent),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(color: Colors.white),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(80, 30),
                  ),
                ),
                child: const SizedBox(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Чыгуу",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(
                        Icons.logout_outlined,
                        color: Colors.white,
                      )
                    ],
                  ),
                )),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                _showAlertDialog(context, user['id']);
              },
              child: const Text(
                'Удалить аккаунт',
                style: TextStyle(color: Colors.black45),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DocumentScreen extends StatelessWidget {
  final String title;
  // final String content;
  final String pdfPath;

  const DocumentScreen({super.key, required this.pdfPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontSize: 18)),
        ),
        body: FutureBuilder<OpenResult>(
          future: OpenFile.open('assets/oferta.pdf'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(); // Replace with the desired widget to display when the file is opened
            } else {
              return const CircularProgressIndicator(); // Replace with the desired loading indicator
            }
          },
        ));
  }
}

Future<void> _showAlertDialog(BuildContext context, userId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Нельзя закрыть, касаясь вне окна
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Предупреждение'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('После удаления аккаунта ваши данные будет удалены из базы'),
              Text('Вы действительно этого хотите.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Да'),
            onPressed: () {
              AuthService().deleteUserAccount(userId);
              AuthService().signOut(context);
              Navigator.of(context).pop(); // Закрыть окно предупреждения
            },
          ),
          TextButton(
            child: const Text('Нет'),
            onPressed: () {
              Navigator.of(context).pop(); // Закрыть окно предупреждения
            },
          ),
        ],
      );
    },
  );
}
