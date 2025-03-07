import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: prefer_typing_uninitialized_variables
var phoneNumber;

Widget loginWidget(Function onCountryChange, Function onSubmit) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // textWidget(
        //   text: "Биз менен бирге бол",
        //   fontSize: 24,
        //   fontWeight: FontWeight.bold,
        // ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xffAC046A), width: 1, style: BorderStyle.solid),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    spreadRadius: 1,
                    blurRadius: 2)
              ],
              borderRadius: BorderRadius.circular(8),
              color: Colors.white),
          child: Row(
            children: [
              Container(
                width: 80,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffAC046A),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8)),
                ),
                child: InkWell(
                  onTap: () => onCountryChange(),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      // Expanded(
                      //   child: Container(
                      //     child: Text("+996"),
                      //   ),
                      // ),
                      Text(
                        "+996",
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      // const Icon(Icons.keyboard_arrow_down_rounded)
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 55,
                color: Colors.black.withOpacity(0.2),
              ),
              Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      onChanged: (input) => phoneNumber = input,
                      onSubmitted: (String? input) => onSubmit(input),
                      // onTap: () {
                      //   Get.to(() =>  OtpVerificationScreen());
                      // },
                      style: GoogleFonts.montserrat(
                        color: const Color(0xffAC046A),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                          hintStyle: GoogleFonts.montserrat(
                              fontSize: 14, fontWeight: FontWeight.w300),
                          hintText: 'Телефон номеринизди жазыныз',
                          helperStyle: const TextStyle(color: Color(0xff005D67)),
                          border: InputBorder.none),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        MaterialButton(
          minWidth: Get.width,
          height: 50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: const Color(0xffAC046A),
          onPressed: () => {onSubmit(phoneNumber)},
          child: Text(
            'Кирүү',
            style: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        // MaterialButton(
        //   minWidth: Get.width,
        //   height: 50,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        //   color: AppColors.whiteColor,
        //   onPressed: () => {},
        //   child: Text(
        //     'Почта аркылуу кошулуу',
        //     style: TextStyle(
        //         fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        //   ),
        // ),
        const SizedBox(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: GoogleFonts.montserrat(color: const Color(0xff005D67)),
                  children: [
                    const TextSpan(
                      text: 'Аккаунт түзүү менен, сиз биздин \n',
                    ),
                    TextSpan(
                        text: 'Колдонуу шарттарыбыз ',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold)),
                    const TextSpan(
                      text: 'жана \n',
                    ),
                    TextSpan(
                        text: 'Купуялык саясатыбыздын шарттарына ',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold)),
                    const TextSpan(
                      text: 'макулдугуңузду бересиз.',
                    ),
                  ])),
        )
      ],
    ),
  );
}
