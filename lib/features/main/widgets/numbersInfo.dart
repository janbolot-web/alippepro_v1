// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class NumbersInfo extends StatelessWidget {
  const NumbersInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        Center(
            heightFactor: 1,
            child: GradientText(
              'САНДАР\n \t \t \t \t \t \t \t \t \t СҮЙЛӨСҮН',
              style: const TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto'),
              gradientType: GradientType.linear,
              colors: const [
                Color(0xffba0f43),
                Color(0xff157d97),
              ],
            )),
        const SizedBox(
          height: 25,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.asset('assets/img/numbers.png'),
        )

        // Container(
        //   alignment: Alignment.center,
        //   margin: const EdgeInsets.symmetric(horizontal: 40.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Column(
        //         children: [
        //           Row(
        //             children: [
        //               SizedBox(
        //                 height: 65,
        //                 child: SvgPicture.asset('assets/img/Document.svg'),
        //               ),
        //               const SizedBox(
        //                 width: 10,
        //               ),
        //               Countup(
        //                 begin: 0,
        //                 end: 2,
        //                 duration: const Duration(seconds: 3),
        //                 separator: '',
        //                 style: const TextStyle(
        //                     fontSize: 32,
        //                     color: Color(0xff1b434d),
        //                     fontWeight: FontWeight.w900,
        //                     fontFamily: 'Roboto'),
        //               ),
        //             ],
        //           ),
        //           const Text(
        //             'Автордук\nкитеп',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //                 fontWeight: FontWeight.w700,
        //                 fontSize: 12,
        //                 color: Color(0xff1b434d),
        //                 fontFamily: 'Comfortaa'),
        //           ),
        //         ],
        //       ),
        //       Column(
        //         children: [
        //           Row(
        //             children: [
        //               SizedBox(
        //                 height: 65,
        //                 child: SvgPicture.asset('assets/img/NProfile.svg'),
        //               ),
        //               const SizedBox(
        //                 width: 10,
        //               ),
        //               Countup(
        //                 begin: 0,
        //                 end: 10000,
        //                 duration: const Duration(seconds: 3),
        //                 separator: '',
        //                 style: const TextStyle(
        //                     fontSize: 28,
        //                     color: Color(0xff1b434d),
        //                     fontWeight: FontWeight.w900,
        //                     fontFamily: 'Roboto'),
        //               ),
        //             ],
        //           ),
        //           const Text(
        //             'Мугалим менен\nкызматташтык',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //                 fontWeight: FontWeight.w700,
        //                 fontSize: 12,
        //                 color: Color(0xff1b434d),
        //                 fontFamily: 'Comfortaa'),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(
        //   height: 50,
        // ),
        // Container(
        //   alignment: Alignment.center,
        //   margin: const EdgeInsets.symmetric(horizontal: 40.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Column(
        //         children: [
        //           Row(
        //             children: [
        //               SizedBox(
        //                 height: 65,
        //                 child: SvgPicture.asset('assets/img/Edit.svg'),
        //               ),
        //               const SizedBox(
        //                 width: 10,
        //               ),
        //               Countup(
        //                 begin: 0,
        //                 end: 400,
        //                 duration: const Duration(seconds: 3),
        //                 separator: '',
        //                 style: const TextStyle(
        //                     fontSize: 32,
        //                     color: Color(0xff1b434d),
        //                     fontWeight: FontWeight.w900,
        //                     fontFamily: 'Roboto'),
        //               ),
        //             ],
        //           ),
        //           const Text(
        //             'Мугалим жаны\nметодикаларды\nөздөштүрүштү',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //                 fontWeight: FontWeight.w700,
        //                 fontSize: 12,
        //                 color: Color(0xff1b434d),
        //                 fontFamily: 'Comfortaa'),
        //           ),
        //         ],
        //       ),
        //       Column(
        //         children: [
        //           Row(
        //             children: [
        //               SizedBox(
        //                 height: 65,
        //                 child: Image.asset('assets/img/Sharokuu.png'),
        //               ),
        //               Countup(
        //                 begin: 0,
        //                 end: 57,
        //                 duration: const Duration(seconds: 3),
        //                 separator: '',
        //                 style: const TextStyle(
        //                     fontSize: 28,
        //                     color: Color(0xff1b434d),
        //                     fontWeight: FontWeight.w900,
        //                     fontFamily: 'Roboto'),
        //               ),
        //             ],
        //           ),
        //           const Text(
        //             'Шар окуу\nборбору',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //                 fontWeight: FontWeight.w700,
        //                 fontSize: 12,
        //                 color: Color(0xff1b434d),
        //                 fontFamily: 'Comfortaa'),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(
        //   height: 50,
        // ),
        // Container(
        //   alignment: Alignment.center,
        //   margin: const EdgeInsets.symmetric(horizontal: 40.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Column(
        //         children: [
        //           Row(
        //             children: [
        //               SizedBox(
        //                 height: 65,
        //                 child: Image.asset('assets/img/Calendar.png'),
        //               ),
        //               const SizedBox(
        //                 width: 10,
        //               ),
        //               Countup(
        //                 begin: 0,
        //                 end: 5,
        //                 duration: const Duration(seconds: 3),
        //                 separator: '',
        //                 style: const TextStyle(
        //                     fontSize: 32,
        //                     color: Color(0xff1b434d),
        //                     fontWeight: FontWeight.w900,
        //                     fontFamily: 'Roboto'),
        //               ),
        //             ],
        //           ),
        //           const Text(
        //             'Жылдык\nтажырыйба',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //                 fontWeight: FontWeight.w700,
        //                 fontSize: 12,
        //                 color: Color(0xff1b434d),
        //                 fontFamily: 'Comfortaa'),
        //           ),
        //         ],
        //       ),
        //       Column(
        //         children: [
        //           Row(
        //             children: [
        //               SizedBox(
        //                 height: 65,
        //                 child: Image.asset('assets/img/Location.png'),
        //               ),
        //               Countup(
        //                 begin: 0,
        //                 end: 2,
        //                 duration: const Duration(seconds: 3),
        //                 separator: '',
        //                 style: const TextStyle(
        //                     fontSize: 28,
        //                     color: Color(0xff1b434d),
        //                     fontWeight: FontWeight.w900,
        //                     fontFamily: 'Roboto'),
        //               ),
        //             ],
        //           ),
        //           const Text(
        //             'Филиал',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //                 fontWeight: FontWeight.w700,
        //                 fontSize: 12,
        //                 color: Color(0xff1b434d),
        //                 fontFamily: 'Comfortaa'),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(
        //   height: 50,
        // ),
        // Container(
        //   alignment: Alignment.center,
        //   margin: const EdgeInsets.symmetric(horizontal: 40.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Column(
        //         children: [
        //           Row(
        //             children: [
        //               SizedBox(
        //                 height: 65,
        //                 child: Image.asset('assets/img/Activity.png'),
        //               ),
        //               Countup(
        //                 begin: 0,
        //                 end: 100,
        //                 duration: const Duration(seconds: 3),
        //                 separator: '',
        //                 style: const TextStyle(
        //                     fontSize: 28,
        //                     color: Color(0xff1b434d),
        //                     fontWeight: FontWeight.w900,
        //                     fontFamily: 'Roboto'),
        //               ),
        //             ],
        //           ),
        //           const Text(
        //             'Мугалим\nкомпьютердик\nсабаттуулугун\nарттырды',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //                 fontWeight: FontWeight.w700,
        //                 fontSize: 12,
        //                 color: Color(0xff1b434d),
        //                 fontFamily: 'Comfortaa'),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ],
    ));
  }
}
