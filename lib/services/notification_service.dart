import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:emartdriver/main.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/ui/chat_screen/chat_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';

// Evento para mostrar detalhes da ordem
class ShowOrderDetailsEvent {
  final String orderId;
  ShowOrderDetailsEvent(this.orderId);
}

// EventBus para comunicação entre componentes
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _eventController = StreamController<dynamic>.broadcast();
  Stream<T> on<T>() =>
      _eventController.stream.where((event) => event is T).cast<T>();
  void fire(event) => _eventController.add(event);
  void dispose() => _eventController.close();
}

final eventBus = EventBus();

Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
}

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer audioPlayer = AudioPlayer();

  initInfo() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized ||
        request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: (payload) {});
      setupInteractedMessage();
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onBackgroundMessage(
          (message) => firebaseMessageBackgroundHandle(message));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("::::::::::::onMessage:::::::::::::::::");
      if (message.notification != null) {
        log(message.notification.toString());
        log(message.data.toString());
        display(message);

        // if (message.data['type'] == 'new_order' ||
        //     message.data['subject'] == 'New Order') {
        // if (navigatorKey.currentContext != null) {
        //   log("new order");
        // Garante que está na HomeScreen
        Navigator.of(navigatorKey.currentContext!)
            .popUntil((route) => route.isFirst);
        String? orderId;
        if (message.data is Map && message.data['id'] != null) {
          orderId = message.data['id'];
        }
        if (orderId != null) {
          eventBus.fire(ShowOrderDetailsEvent(orderId));
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("::::::::::::onMessageOpenedApp:::::::::::::::::");
      // Parar o som quando a notificação é clicada
      audioPlayer.stop();

      if (message.notification != null) {
        log(message.notification.toString());

        String orderId = message.data['orderId'];
        if (message.data['subject'] == 'New Order') {
          // Em vez de navegar para uma nova tela, vamos mostrar o popup no HomeScreen
          if (navigatorKey.currentContext != null) {
            // Encontra o HomeScreen na pilha de navegação
            Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    ContainerScreen(user: MyAppState.currentUser!),
              ),
              (route) => false,
            );
            log("sla");
            // Aguarda a HomeScreen montar antes de disparar o evento
            Future.delayed(Duration(milliseconds: 500), () {
              eventBus.fire(ShowOrderDetailsEvent(orderId));
            });
          }
        } else if (message.data['type'] == 'cab_parcel_chat' ||
            message.data['type'] == 'vendor_chat') {
          push(
              navigatorKey.currentContext!,
              ChatScreens(
                orderId: orderId,
                customerId: message.data['customerId'],
                customerName: message.data['customerName'],
                customerProfileImage: message.data['customerProfileImage'],
                restaurantId: message.data['restaurantId'],
                restaurantName: message.data['restaurantName'],
                restaurantProfileImage: message.data['restaurantProfileImage'],
                token: message.data['token'],
                chatType: message.data['chatType'],
                type: message.data['type'],
              ));
        } else {
          /// receive message through inbox
          push(
              navigatorKey.currentContext!,
              ChatScreens(
                orderId: orderId,
                customerId: message.data['customerId'],
                customerName: message.data['customerName'],
                customerProfileImage: message.data['customerProfileImage'],
                restaurantId: message.data['restaurantId'],
                restaurantName: message.data['restaurantName'],
                restaurantProfileImage: message.data['restaurantProfileImage'],
                token: message.data['token'],
                chatType: message.data['chatType'],
              ));
        }
      }
    });
    log("::::::::::::Permission authorized:::::::::::::::::");
    await FirebaseMessaging.instance.subscribeToTopic("eMart_driver");
  }

  static getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        "01",
        "emart_driver",
        description: 'Show Emart Notification',
        importance: Importance.max,
      );
      AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: 'your channel Description',
              importance: Importance.high,
              priority: Priority.high,
              ticker: 'ticker');
      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
              presentAlert: true, presentBadge: true, presentSound: true);
      NotificationDetails notificationDetailsBoth = NotificationDetails(
          android: notificationDetails, iOS: darwinNotificationDetails);
      await FlutterLocalNotificationsPlugin().show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
