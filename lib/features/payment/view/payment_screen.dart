import 'dart:convert';

import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/services/payment_service.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomSheet extends StatefulWidget {
  final product;
  const CustomBottomSheet({super.key, required String this.product});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with TickerProviderStateMixin {
  bool isLoading = false;
  bool isLoadingPayment = false;
  bool showPaymentMethods = false;
  final PaymentService paymentServices = PaymentService();
  final AuthService authService = AuthService();
  var user;

  @override
  void initState() {
    super.initState();
    getUserLocalData();
  }

  // Future<void> _refresh() async {
  //   // await Future.delayed(Duration(seconds: 2)); // Имитация загрузки данных
  //   user = await authService.getMe(user['id']);
  //   saveDataToLocalStorage('user', jsonEncode(user));
  //   getUserLocalData();

  //   setState(() {});
  // }

  Future getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    user = jsonDecode(response!);
    // print();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 400,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              width: 100,
            ),
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // vsync: this,
              child: showPaymentMethods
                  ? _buildPaymentMethods()
                  : isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child:
                              const Center(child: CircularProgressIndicator()))
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildRate()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRate() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffFF0099), Color(0xff1387F2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 24,
                        child: Icon(Icons.star, color: Colors.amber, size: 28),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Негизги план",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Биздин кызматтар:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "\u2022 Айына 120 сабактын план-конспектисин түзүү.\n"
                    "\u2022 30 викторина оюнун түзүүгө мүмкүнчүлүк.\n"
                    "\u2022 Түз эфир аркылуу окуучулар менен онлайн сабак өтүү жана материалдарды бөлүшүү мүмкүнчүлүгү.\n"
                    "\u2022 План-конспекттерди Word жана PDF форматында жүктөп алуу.\n",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Стиль для цены
                      const Row(
                        children: [
                          Text(
                            '480 сом',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      // Новый стиль кнопки
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              isLoading = false;
                              showPaymentMethods = true;
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Сатып алуу',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return isLoadingPayment
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategory(
                  title: 'Банк карталары',
                  // icons: [
                  //   'https://alippebucket.s3.eu-north-1.amazonaws.com/payment/logo/Visa.png',
                  //   'https://alippebucket.s3.eu-north-1.amazonaws.com/payment/logo/MasterCard.png',
                  //   'https://alippebucket.s3.eu-north-1.amazonaws.com/payment/logo/elcard.png',
                  //   'https://alippebucket.s3.eu-north-1.amazonaws.com/payment/logo/Maestro.png',
                  // ],
                  icons: [
                    'assets/img/Visa.png',
                    'assets/img/MasterCard.png',
                    'assets/img/elcard.png',
                    'assets/img/Maestro.png',
                  ],
                  amount: '480',
                  description: 'AlippeAi',
                  paymentMethod: "bankcard"),
              _buildCategory(
                title: 'Мобилдик банк',
                icons: [
                  'assets/img/MBank.png',
                ],
                amount: '480',
                description: 'AlippeAi',
                paymentMethod: "internetbank",
              ),
              _buildCategory(
                  title: 'Электрондук капчыктар',
                  icons: [
                    'assets/img/odengi.png',
                    // 'assets/img/elsom.png',
                    'assets/img/MegaPay.png',
                    // 'assets/img/Balance.png',
                  ],
                  amount: '480',
                  description: 'AlippeAi',
                  paymentMethod: "wallet"),
              _buildCategory(
                  title: 'Терминалдар',
                  icons: [
                    'assets/img/onoi.png',
                    'assets/img/UMAI.png',
                  ],
                  amount: '480',
                  description: 'AlippeAi',
                  paymentMethod: "other"),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width * 0.3,
                child: Image.asset(
                  'assets/img/freedom.png',
                ),
              ),
            ],
          );
  }

  Widget _buildCategory(
      {required String title,
      required List<String> icons,
      required String amount,
      required String description,
      required String paymentMethod}) {
    return GestureDetector(
      onTap: () async {
        isLoadingPayment = true;
        var response = await paymentServices.createToPayment(
            amount: amount,
            description: description,
            paymentMethod: paymentMethod,
            userId: user['id'],
            product: widget.product,
            context: context);
        if (response?['data']['jsonResponse']?['pg_status']?[0] == 'ok') {
          print(response?['refreshedUser']);
          Navigator.pop(context, true);
          isLoadingPayment = false;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xffFF0099), Color(0xff1387F2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: icons
                    .map(
                      (icon) => Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * .01),
                        child: Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Image.asset(
                            icon,
                            width: 60,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentSuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback onRedirect;

  const PaymentSuccessDialog({
    super.key,
    this.message = 'Төлөм ийгиликтүү аяктады!',
    required this.onRedirect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(91, 0, 85, 88),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(124, 0, 85, 88),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xff005558),
                      borderRadius: BorderRadius.circular(50),
                      border:
                          Border.all(width: 5, color: const Color(0xff005558))),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ийгилик!',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xff1B434D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: const Color(0xff1B434D),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xff08B3B9),
                        Color.fromARGB(196, 0, 0, 0)
                      ])),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Закрыть модальное окно
                  onRedirect(); // Выполнить перенаправление
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text(
                      'Улантуу',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
