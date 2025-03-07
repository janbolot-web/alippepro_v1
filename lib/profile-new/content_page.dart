// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  var user;

  @override
  void initState() {
    super.initState();
    getUserLocalData();
  }

  Future getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    user = jsonDecode(response!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Контент',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
