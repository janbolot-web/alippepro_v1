import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CoursesItemCard extends StatelessWidget {
  const CoursesItemCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color.fromARGB(217, 227, 227, 201), Color(0xff088273)],
            ),
          ),
          child: Image.asset(
            'assets/png/Vector.png',
            width: 80,
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(42, 11, 10, 43),
          child: Text(
            'ШАР ОКУУ\nМУГАЛИМИ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const Gap(3),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 40, 73, 10),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 15,
            child: Image.asset(
              'assets/png/Vector.png',
              width: 20,
            ),
          ),
        )
      ],
    );
  }
}
