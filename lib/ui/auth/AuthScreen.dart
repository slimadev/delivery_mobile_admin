import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/ui/login/LoginScreen.dart';
import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:emartdriver/ui/signUp/SignUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/repositories/user_repository.dart';
import 'package:emartdriver/userPrefrence.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header com logo e seletor de idioma
            _buildHeader(),

            // Formulário de autenticação
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Título
                      Text(
                        'Welcome to eMart Driver'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(COLOR_PRIMARY),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Authenticate to continue'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40),

                      // Campo de número de celular
                      _buildPhoneField(),

                      SizedBox(height: 20),

                      // Campo de OTP
                      _buildOTPField(),

                      SizedBox(height: 20),

                      // Campo de senha
                      _buildPasswordField(),

                      SizedBox(height: 40),

                      // Botão de entrar
                      _buildLoginButton(),

                      SizedBox(height: 20),

                      // Links alternativos
                      _buildAlternativeLinks(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: [
        // Logo
        Expanded(
          child: Center(
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.contain,
              width: 120,
              height: 120,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Phone Number'.tr(),
        hintText: '8X XXX XXXX',
        prefixIcon: Icon(Icons.phone, color: Color(COLOR_PRIMARY)),
        prefix: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text(
            '+258 ',
            style: TextStyle(
              color: Color(COLOR_PRIMARY),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required'.tr();
        }

        // Remove espaços e caracteres especiais
        String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

        // Validação para números moçambicanos
        if (cleanNumber.length < 9) {
          return 'Phone number must be at least 9 digits'.tr();
        }

        if (cleanNumber.length > 9) {
          return 'Phone number must be maximum 9 digits'.tr();
        }

        // Verifica se começa com 8 (celular) ou 2 (fixo)
        if (!cleanNumber.startsWith('8') && !cleanNumber.startsWith('2')) {
          return 'Invalid phone number format'.tr();
        }

        return null;
      },
      onChanged: (value) {
        // Formata o número automaticamente
        String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanNumber.length > 9) {
          cleanNumber = cleanNumber.substring(0, 9);
        }

        // Formata: 8X XXX XXX
        // if (cleanNumber.length > 0) {
        //   String formatted = '';
        //   for (int i = 0; i < cleanNumber.length; i++) {
        //     if (i == 1 || i == 4) {
        //       formatted += ' ';
        //     }
        //     formatted += cleanNumber[i];
        //   }

        //   // Atualiza o controller apenas se o valor for diferente
        //   if (value != '+258 $formatted') {
        //     _phoneController.value = TextEditingValue(
        //       text: formatted,
        //       selection: TextSelection.collapsed(offset: formatted.length),
        //     );
        //   }
        // }
      },
    );
  }

  Widget _buildOTPField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: 'OTP Code'.tr(),
        hintText: 'Enter 6-digit OTP'.tr(),
        prefixIcon: Icon(Icons.security, color: Color(COLOR_PRIMARY)),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'OTP is required'.tr();
        }
        if (value.length != 6) {
          return 'OTP must be 6 digits'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Password'.tr(),
        hintText: 'Enter your password'.tr(),
        prefixIcon: Icon(Icons.lock, color: Color(COLOR_PRIMARY)),
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required'.tr();
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(COLOR_PRIMARY),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Sign In'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAlternativeLinks() {
    return Column(
      children: [
        // Cadastrar nova conta
        TextButton(
          onPressed: () {
            push(context, PhoneNumberInputScreen(login: false));
          },
          child: Text(
            'Create New Account'.tr(),
            style: TextStyle(
              color: Color(COLOR_PRIMARY),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String phone_number = '+258' + _phoneController.text;
        print('phone: ' + phone_number);
        User? user = await UserRepository.authenticate(
          phone_number,
          _otpController.text,
          _passwordController.text,
        );
        await Future.delayed(Duration(seconds: 2));
        if (user != null) {
          // Salva o token do usuário e vai para ContainerScreen
          UserPreference.setUserToken(token: user.userID);
          push(context, ContainerScreen(user: user));
        }
      } catch (e) {
        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
