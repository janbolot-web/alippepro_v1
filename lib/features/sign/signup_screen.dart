import 'package:flutter/material.dart';
import 'package:alippepro_v1/custom_textfield.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final AuthService authService = AuthService();

  void signupUser() {
    authService.signUpUser(
      context: context,
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      avatarUrl: '',
      token: '',
      roles: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Мугалимдерди өнүктүрүүчү аянтча",
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Comfortaa',
                    fontWeight: FontWeight.w700,
                    color: Color(0xff054e45)),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              SvgPicture.asset(
                'assets/img/user.svg',
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: CustomTextField(
                    controller: nameController,
                    hintText: '',
                    labelText: 'Аты-жөнүңүз',
                    type: 'name'),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: CustomTextField(
                    controller: emailController,
                    hintText: '',
                    labelText: 'Электрондук почтаңыз',
                    type: 'email'),
                // decoration: BoxDecoration(
                //     border: Border.all(
                //       color: Color(0xff088273),
                //       width: 2,
                //     ),
                //     borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: CustomTextField(
                    controller: passwordController,
                    hintText: '',
                    labelText: 'Сыр сөзүңүз (6 символдон жогору)',
                    type: 'password'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: signupUser,
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xff088273)),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(color: Colors.white),
                    ),
                    minimumSize: WidgetStateProperty.all(
                      Size(MediaQuery.of(context).size.width / 2.5, 50),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ))),
                child: const Text(
                  "КАТТАЛУУ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'RobotoFlex',
                      fontWeight: FontWeight.w900),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Эгер аккаунтуңуз бар болсо, анда'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('кирүү! '),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
