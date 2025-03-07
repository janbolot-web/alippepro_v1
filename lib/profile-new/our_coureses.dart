// ignore_for_file: library_private_types_in_public_api

import 'package:alippepro_v1/profile-new/widgets/courses_item_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class OurCoureses extends StatefulWidget {
  const OurCoureses({super.key});

  @override
  _OurCoursesState createState() => _OurCoursesState();
}

class _OurCoursesState extends State<OurCoureses> {
  bool _showGridView = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Менин курстарым',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const Gap(67),
        const Text(
          'Сиздин кабинетиңизде азыр эч бир \n курска доступ жок! ',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const Gap(20),
        const Text(
          'Курстар тууралуу маалымат алуу үчүн',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const Gap(53),
        SizedBox(
          height: 30,
          width: 200,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showGridView = !_showGridView;
              });
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text(
              'Курстар',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Gap(15),
        Visibility(
          visible: _showGridView,
          child: Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 33.0,
              padding: const EdgeInsets.symmetric(horizontal: 44),
              children: List.generate(
                4,
                (index) => const CoursesItemCard(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
