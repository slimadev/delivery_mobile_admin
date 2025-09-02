import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/services/session_service.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:emartdriver/ui/fullScreenVideoViewer/FullScreenVideoViewer.dart';
import 'package:emartdriver/ui/signUp/FirstStepsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:emartdriver/model/conversation_model.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:emartdriver/ui/profile/ProfileScreen.dart';
import 'package:emartdriver/ui/wallet/walletScreen.dart';
import 'package:emartdriver/ui/faq/FaqScreen.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';

class SupportChatScreen extends StatefulWidget {
  final bool fromDrawer;
  const SupportChatScreen({Key? key, this.fromDrawer = false})
      : super(key: key);

  @override
  _SupportChatScreenState createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  TextEditingController _messageController = TextEditingController();
  late Stream<List<SupportMessage>> chatStream;
  LocalConversation? homeConversationModel;
  // final bool fromDrawer;

  final String supportId = 'admin_support'; // ID fixo do suporte

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  Future<void> _initConversation() async {
    // Busca o usuário do suporte
    User? supportUser = await FireStoreUtils.getCurrentUser(supportId);
    if (supportUser == null) {
      // Cria um usuário fake se não existir
      supportUser = User(
        userID: supportId,
        firstName: 'Suporte',
        lastName: '',
        profilePictureURL: '',
        isActive: true,
        lastOnlineTimestamp: Timestamp.now(),
      );
    }
    homeConversationModel = LocalConversation(
      members: [supportUser, MyAppState.currentUser!],
      conversationModel: null,
    );
    chatStream = getSupportMessages(MyAppState.currentUser!.userID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (homeConversationModel == null) {
      return Scaffold(
        extendBodyBehindAppBar:
            widget.fromDrawer, // Esconde AppBar quando vem do drawer
        appBar: widget.fromDrawer
            ? null // Sem AppBar quando vem do drawer
            : AppBar(
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF7ED321)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'CHAT COM SUPORTE',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.menu, color: Color(0xFF7ED321)),
                    onPressed: () {},
                  ),
                ],
              ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppThemeData.newBlack,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF7ED321)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CHAT COM SUPORTE',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Color(0xFF7ED321)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
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
              title: Text('Home', style: TextStyle(color: Colors.white)).tr(),
              onTap: () {
                Navigator.pop(context);
                pushAndRemoveUntil(context,
                    ContainerScreen(user: MyAppState.currentUser!), false);
              },
            ),
            Divider(
                color: Colors.white24, height: 0, indent: 10, endIndent: 100),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title:
                  Text('Profile', style: TextStyle(color: Colors.white)).tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(user: MyAppState.currentUser!)));
              },
            ),
            Divider(
                color: Colors.white24, height: 0, indent: 10, endIndent: 100),
            ListTile(
              leading: Icon(Icons.history, color: Colors.white),
              title:
                  Text('Histórico', style: TextStyle(color: Colors.white)).tr(),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar tela de histórico
              },
            ),
            Divider(
                color: Colors.white24, height: 0, indent: 10, endIndent: 100),
            ListTile(
              leading: Icon(Icons.money, color: Colors.white),
              title:
                  Text('Carteira', style: TextStyle(color: Colors.white)).tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WalletScreen()));
              },
            ),
            Divider(
                color: Colors.white24, height: 0, indent: 10, endIndent: 100),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.white),
              title:
                  Text('Ajuda e Suporte', style: TextStyle(color: Colors.white))
                      .tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SupportChatScreen(
                              fromDrawer: false,
                            )));
              },
            ),
            Divider(
                color: Colors.white24, height: 0, indent: 10, endIndent: 100),
            ListTile(
              leading: Icon(Icons.school, color: Colors.white),
              title:
                  Text('Tutoriais', style: TextStyle(color: Colors.white)).tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FirstStepsScreen()));
              },
            ),
            Divider(
                color: Colors.white24, height: 0, indent: 10, endIndent: 100),
            ListTile(
              leading: Icon(Icons.question_answer, color: Colors.white),
              title: Text('FAQ', style: TextStyle(color: Colors.white)).tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FaqScreen()));
              },
            ),
            Divider(
                color: Colors.white24, height: 0, indent: 10, endIndent: 100),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title:
                  Text('Log out', style: TextStyle(color: Colors.white)).tr(),
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
                // Limpa a sessão do usuário
                await SessionService.clearUserSession();
                MyAppState.currentUser = null;
                pushAndRemoveUntil(
                    context, PhoneNumberInputScreen(login: false), false);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<SupportMessage>>(
                stream: chatStream,
                initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma mensagem ainda',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  // Agrupar por data
                  List<Widget> chatWidgets = [];
                  String? lastDate;
                  for (int i = 0; i < messages.length; i++) {
                    final msg = messages[i];
                    final msgDate = _formatDate(msg.createdAt);
                    if (msgDate != lastDate) {
                      chatWidgets.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                msgDate,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      );
                      lastDate = msgDate;
                    }
                    chatWidgets.add(_buildChatBubble(msg));
                  }
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: chatWidgets,
                    reverse: false,
                  );
                },
              ),
            ),
            _buildInputBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(SupportMessage msg) {
    final isMe = msg.senderId == MyAppState.currentUser!.userID;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFF7ED321) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Escrever...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                minLines: 1,
                maxLines: 5,
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(_messageController.text.trim());
                _messageController.clear();
                setState(() {});
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.send, color: Color(0xFF7ED321), size: 28),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hoje, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Future<bool> _checkChannelNullability(
      ConversationModel? conversationModel) async {
    if (conversationModel != null) {
      return true;
    } else {
      String channelID = MyAppState.currentUser!.userID + supportId;
      ConversationModel conversation = ConversationModel(
        id: channelID,
        senderId: MyAppState.currentUser!.userID,
        receiverId: supportId,
        orderId: channelID,
        message: '',
        messageType: '',
        videoThumbnail: '',
        url: Url(),
        createdAt: Timestamp.now(),
      );
      await FirebaseFirestore.instance
          .collection('chat_driver')
          .doc(channelID)
          .set({'id': channelID});
      homeConversationModel!.conversationModel = conversation;
      setState(() {});
      return true;
    }
  }

  void _sendMessage(String text) async {
    final msg = SupportMessage(
      id: Uuid().v4(),
      senderId: MyAppState.currentUser!.userID,
      senderType: 'driver', // ou 'customer', conforme o tipo do usuário
      text: text,
      createdAt: DateTime.now(),
    );
    await FirebaseFirestore.instance
        .collection('support_chat')
        .doc(MyAppState.currentUser!.userID)
        .set({}, SetOptions(merge: true)); // <-- ESTA LINHA

    // Agora salva a mensagem normalmente
    await FirebaseFirestore.instance
        .collection('support_chat')
        .doc(MyAppState.currentUser!.userID)
        .collection('messages')
        .doc(msg.id)
        .set({
      ...msg.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    // .set(msg.toJson());
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// Modelo mínimo para ChatModel e MessageData (ajuste conforme necessário)
class MessageData {
  String senderID;
  String senderProfilePictureURL;
  String content;
  Url url;
  String videoThumbnail;
  MessageData({
    this.senderID = '',
    this.senderProfilePictureURL = '',
    this.content = '',
    Url? url,
    this.videoThumbnail = '',
  }) : url = url ?? Url();
}

class ChatModel {
  List<MessageData> message;
  List<User> members;
  ChatModel({this.message = const [], this.members = const []});
}

// Substituir HomeConversationModel por estrutura local
class LocalConversation {
  List<User> members;
  ConversationModel? conversationModel;
  LocalConversation({required this.members, this.conversationModel});
}

// Novo modelo de mensagem para suporte
class SupportMessage {
  String id;
  String senderId;
  String senderType; // 'driver', 'customer', 'admin'
  String text;
  DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderType': senderType,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SupportMessage.fromJson(Map<String, dynamic> json) => SupportMessage(
        id: json['id'],
        senderId: json['senderId'],
        senderType: json['senderType'],
        text: json['text'],
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt']),
      );
}

// Stream para buscar mensagens do suporte
Stream<List<SupportMessage>> getSupportMessages(String userId) {
  return FirebaseFirestore.instance
      .collection('support_chat')
      .doc(userId)
      .collection('messages')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SupportMessage.fromJson(doc.data()))
          .toList());
}
