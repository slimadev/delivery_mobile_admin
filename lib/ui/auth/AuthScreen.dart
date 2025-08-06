import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/ui/login/LoginScreen.dart';
import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:emartdriver/ui/signUp/SignUpScreen.dart';
import 'package:flutter/material.dart';


class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(

        child: Stack(
          children: [
            // Conteúdo principal centralizado
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.contain,
                    width: 150,
                    height: 150,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 32, right: 16, bottom: 8),
                    child: Text(
                      'Welcome to eMart Driver'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(COLOR_PRIMARY),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    child: Text(
                      'Make extra cash by delivery orders to our customers.'.tr(),
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: double.infinity),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(COLOR_PRIMARY),
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: Color(COLOR_PRIMARY)),
                          ),
                        ),
                        child: Text(
                          'Log In'.tr(),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        onPressed: () {
                          push(context, LoginScreen());
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20, bottom: 20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: double.infinity),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: Color(COLOR_PRIMARY)),
                          ),
                        ),
                        child: Text(
                          'Sign Up'.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(COLOR_PRIMARY),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Choose Sign Up Method'.tr()),
                                content: Text('Would you like to sign up with your phone number or email?'.tr()),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Fecha o popup
                                      push(context, PhoneNumberInputScreen(login: false));
                                    },
                                    child: Text('Phone Number'.tr()),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Fecha o popup
                                      push(context, SignUpScreen());
                                    },
                                    child: Text('Email'.tr()),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Seletor de idioma no topo direito
            Positioned(
              top: 16,
              right: 16,
              child: DropdownButton<Locale>(
                icon: Icon(
                  Icons.language,
                  color: Color(COLOR_PRIMARY),
                  size: 30,
                ),
                underline: SizedBox(), // Remove a linha padrão do dropdown
                items: [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Row(
                      children: [
                        Text('🇬🇧', style: TextStyle(fontSize: 24)), // Bandeira maior
                        SizedBox(width: 8),
                        Text('English'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Locale('ar'),
                    child: Row(
                      children: [
                        Text('🇸🇦', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text('العربية'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Locale('pt'),
                    child: Row(
                      children: [
                        Text('🇧🇷', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text('Português'),
                      ],
                    ),
                  ),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    context.setLocale(newLocale); // Altera o idioma
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}