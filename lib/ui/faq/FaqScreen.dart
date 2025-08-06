import 'package:flutter/material.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/ui/chat/SupportChatScreen.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:emartdriver/main.dart';

class FaqScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = const [
    {
      'question': 'Como funciona o app?',
      'answer':
          'O app conecta motoristas a clientes para entregas rápidas e seguras.'
    },
    {
      'question': 'Como recebo meus pagamentos?',
      'answer':
          'Os pagamentos são feitos diretamente na sua carteira digital do app.'
    },
    {
      'question': 'O que fazer em caso de problema com uma entrega?',
      'answer': 'Entre em contato com o suporte pelo menu de Ajuda e Suporte.'
    },
    {
      'question': 'Como alterar meus dados cadastrais?',
      'answer': 'Acesse o menu Perfil e edite suas informações.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppThemeData.lightgrey.withOpacity(0.7),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12),
                          Center(
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor:
                                  Color(COLOR_PRIMARY).withOpacity(0.12),
                              child: Icon(
                                Icons.live_help_rounded,
                                size: 54,
                                color: Color(COLOR_PRIMARY),
                              ),
                            ),
                          ),
                          SizedBox(height: 18),
                          Center(
                            child: Text(
                              'Perguntas Frequentes',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppThemeData.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          ...faqs.map((faq) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                      splashColor: Color(COLOR_PRIMARY)
                                          .withOpacity(0.08),
                                      highlightColor: Color(COLOR_PRIMARY)
                                          .withOpacity(0.04),
                                      colorScheme: Theme.of(context)
                                          .colorScheme
                                          .copyWith(
                                            secondary: Color(COLOR_PRIMARY),
                                          ),
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 2),
                                      childrenPadding: EdgeInsets.only(
                                          left: 16, right: 16, bottom: 16),
                                      title: Text(
                                        faq['question']!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(COLOR_PRIMARY),
                                        ),
                                      ),
                                      iconColor: Color(COLOR_PRIMARY),
                                      collapsedIconColor: Color(COLOR_PRIMARY),
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            faq['answer']!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          SizedBox(height: 32),
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(COLOR_PRIMARY),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              icon: Icon(Icons.support_agent,
                                  color: Colors.white),
                              label: Text(
                                'Ainda com dúvidas? Fale conosco',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SupportChatScreen(
                                            fromDrawer: false,
                                          )),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
