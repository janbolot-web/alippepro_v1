import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var playmarket = Uri.parse(
        "https://play.google.com/store/apps/details?id=com.alippe.alippepro_v1");

    var appstore = Uri.parse("https://apps.apple.com/us/app/alippepro-%D0%B0%D0%BB%D0%B8%D0%BF%D0%BF%D0%B5%D0%BF%D1%80%D0%BE/id6483004173");
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 83, 83, 83),
      body: CupertinoAlertDialog(
        title: const Text('Обновите приложения'),
        content: const Text('Вышла новая версия приложения '),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as deletion, and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () async {
              if (Platform.isAndroid) {
                if (await canLaunchUrl(playmarket)) {
                  await launchUrl(playmarket);
                } else {
                  // can't launch url
                }
              } else {
                if (await canLaunchUrl(appstore)) {
                  await launchUrl(appstore);
                } else {
                  // can't launch url
                }
              }
            },
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }
}

class AlertDialogExample extends StatelessWidget {
  const AlertDialogExample({super.key});

  // This shows a CupertinoModalPopup which hosts a CupertinoAlertDialog.
  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Alert'),
        content: const Text('Proceed with destructive action?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            /// This parameter indicates this action is the default,
            /// and turns the action's text to bold text.
            isDefaultAction: true,
            onPressed: () async {
              Uri.parse("https://www.instagram.com/username/");
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('CupertinoAlertDialog Sample'),
      ),
      child: Center(
        child: CupertinoButton(
          onPressed: () => _showAlertDialog(context),
          child: const Text('CupertinoAlertDialog'),
        ),
      ),
    );
  }
}
