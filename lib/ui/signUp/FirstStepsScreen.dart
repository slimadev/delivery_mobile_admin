import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:flutter/material.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/theme/app_them_data.dart';

class FirstStepsScreen extends StatelessWidget {
  final bool fromDrawer; // Novo parâmetro para detectar origem

  const FirstStepsScreen({Key? key, this.fromDrawer = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.22; // 25% of screen height

    final User? user = MyAppState.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: fromDrawer, // Esconde AppBar quando vem do drawer
      appBar: fromDrawer
          ? null // Sem AppBar quando vem do drawer
          : AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: Text(
                'PRIMEIROS PASSOS'.tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Título e botão voltar quando vem do drawer (sem AppBar)
              if (fromDrawer) ...[
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ContainerScreen(user: MyAppState.currentUser!),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Text(
                        'PRIMEIROS PASSOS'.tr(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Para centralizar o título
                  ],
                ),
                SizedBox(height: 20),
              ],
              SizedBox(
                height: cardHeight,
                child: _buildInfoCard(
                  context,
                  title: 'Como usar o app?'.tr(),
                  imagePath: 'assets/images/phone.png',
                  onTap: () {
                    print('Navegar para Como usar o app?');
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: cardHeight,
                child: _buildInfoCard(
                  context,
                  title: 'Dicas de Segurança e Conduta'.tr(),
                  imagePath: 'assets/images/security.png',
                  onTap: () {
                    print('Navegar para Dicas de Segurança e Conduta');
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: cardHeight,
                child: _buildInfoCard(
                  context,
                  title: 'Política de pagamentos'.tr(),
                  imagePath: '',
                  onTap: () {
                    print('Navegar para Política de pagamentos');
                  },
                ),
              ),
              // Botão "Prosseguir" só aparece quando NÃO vem do drawer
              if (!fromDrawer) ...[
                Padding(
                  padding: const EdgeInsets.only(
                      right: 8.0, left: 8.0, top: 16.0, bottom: 16),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeData.newBlack,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Prosseguir'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (user != null) {
                          pushAndRemoveUntil(
                              context, ContainerScreen(user: user), false);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required String imagePath, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Color(COLOR_PRIMARY),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    wordSpacing: 0,
                    height: 0,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: imagePath.isNotEmpty
                      ? Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 100,
                            );
                          },
                        )
                      : Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 100,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
