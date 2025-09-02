import 'package:emartdriver/constants.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/theme/responsive.dart';
import 'package:emartdriver/theme/round_button_fill.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:flutter/material.dart';
import 'package:emartdriver/ui/signUp/PreSignUp.dart';
import 'package:emartdriver/userPrefrence.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Container(
        color: AppThemeData.green,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 220),
                child: Image.asset(
                  'assets/images/delivery1.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: RoundedButtonFill(
                title: "Next",
                width: 20,
                height: 5,
                color: Colors.white,
                textColor: Colors.green,
                onPress: () async {
                  // Marca o onboarding como finalizado
                  await UserPreference.setFinishedOnBoarding(finished: true);
                  // Navega para a tela de registro
                  pushReplacement(
                      context, PhoneNumberInputScreen(login: false));
                },
              ),
            ),
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Center(
                child: Text(
                  'Faz as tuas entregas e aumenta tua renda todos os dias',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 190,
              left: 20,
              right: 20,
              child: Image.asset(
                'assets/images/app_logo.png',
                color: Colors.white,
                width: 100,
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
