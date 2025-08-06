import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:emartdriver/ui/profile/ProfileScreen.dart';
import 'package:emartdriver/ui/wallet/walletScreen.dart';
import 'package:emartdriver/ui/faq/FaqScreen.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/main.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';

class DeliverySuccessScreen extends StatelessWidget {
  final double earnings;
  final double bonus;
  final double total;
  final String currency;
  final VoidCallback? onRate;

  const DeliverySuccessScreen({
    Key? key,
    required this.earnings,
    required this.bonus,
    required this.total,
    this.currency = 'MZN',
    this.onRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeData.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Color(0xFF82C100)),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Color(0xFF82C100)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 18, left: 18, right: 18),
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 18),
              decoration: BoxDecoration(
                color: Color(0xFFEFEFEF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF82C100),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(32),
                      child: Icon(Icons.check, color: Colors.white, size: 64),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Entrega feita\ncom sucesso!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _row('Ganhos',
                              '${earnings.toStringAsFixed(0)} $currency',
                              bold: true),
                          Divider(height: 1),
                          _row('Bônus de Entrega Rápida',
                              '${bonus.toStringAsFixed(0)} $currency'),
                          Divider(height: 1),
                          _row('Total', '${total.toStringAsFixed(0)} $currency',
                              color: Color(0xFF82C100), bold: true),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    GestureDetector(
                      onTap: onRate,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Avaliação do Cliente',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.thumb_up,
                                color: Color(0xFF82C100), size: 28),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppThemeData.newBlack,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.all(0.0),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppThemeData.newBlack,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    scale: 100,
                    width: 120,
                    fit: BoxFit.contain,
                    height: 120,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              pushAndRemoveUntil(context,
                  ContainerScreen(user: MyAppState.currentUser!), false);
            },
          ),
          Divider(color: Colors.white24, height: 0, indent: 10, endIndent: 100),
          ListTile(
            leading: Icon(Icons.person, color: Colors.white),
            title: Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(user: MyAppState.currentUser!)));
            },
          ),
          Divider(color: Colors.white24, height: 0, indent: 10, endIndent: 100),
          ListTile(
            leading: Icon(Icons.money, color: Colors.white),
            title: Text('Carteira', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WalletScreen()));
            },
          ),
          Divider(color: Colors.white24, height: 0, indent: 10, endIndent: 100),
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.white),
            title:
                Text('Ajuda e Suporte', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Pode navegar para a tela de suporte se desejar
            },
          ),
          Divider(color: Colors.white24, height: 0, indent: 10, endIndent: 100),
          ListTile(
            leading: Icon(Icons.school, color: Colors.white),
            title: Text('Tutoriais', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Pode navegar para a tela de tutoriais se desejar
            },
          ),
          Divider(color: Colors.white24, height: 0, indent: 10, endIndent: 100),
          ListTile(
            leading: Icon(Icons.question_answer, color: Colors.white),
            title: Text('FAQ', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FaqScreen()));
            },
          ),
          Divider(color: Colors.white24, height: 0, indent: 10, endIndent: 100),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white),
            title: Text('Log out', style: TextStyle(color: Colors.white)),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Sair'),
                  content: Text('Tem certeza que deseja sair?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Sair'),
                    ),
                  ],
                ),
              );
              if (shouldLogout != true) return;
              Navigator.pop(context);
              await auth.FirebaseAuth.instance.signOut();
              MyAppState.currentUser = null;
              pushAndRemoveUntil(
                  context, PhoneNumberInputScreen(login: false), false);
            },
          ),
        ],
      ),
    );
  }
}
