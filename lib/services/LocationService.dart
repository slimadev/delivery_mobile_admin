// // import '';
// import 'dart:async';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:emartdriver/constants.dart';
// import 'package:emartdriver/main.dart';
// import 'package:emartdriver/model/CurrencyModel.dart';
// import 'package:emartdriver/model/User.dart';
// import 'package:emartdriver/services/FirebaseHelper.dart';
// import 'package:emartdriver/services/helper.dart';
// import 'package:emartdriver/theme/app_them_data.dart';
// import 'package:emartdriver/ui/Language/language_choose_screen.dart';
// import 'package:emartdriver/ui/auth/AuthScreen.dart';
// import 'package:emartdriver/ui/bank_details/bank_details_Screen.dart';
// import 'package:emartdriver/ui/chat/SupportChatScreen.dart';
// import 'package:emartdriver/ui/chat_screen/inbox_screen.dart';
// import 'package:emartdriver/ui/home/HomeScreen.dart';
// import 'package:emartdriver/ui/ordersScreen/OrdersScreen.dart';
// import 'package:emartdriver/ui/privacy_policy/privacy_policy.dart';
// import 'package:emartdriver/ui/profile/ProfileScreen.dart';
// import 'package:emartdriver/ui/signUp/FirstStepsScreen.dart';
// import 'package:emartdriver/ui/termsAndCondition/terms_and_codition.dart';
// import 'package:emartdriver/ui/wallet/walletScreen.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:location/location.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:emartdriver/ui/faq/FaqScreen.dart';
// import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// // Serviço de localização para rodar em background e foreground
// Future<void> updateCurrentLocation() async {
//   Location location = Location();
//   PermissionStatus permissionStatus = await location.hasPermission();

//   if (permissionStatus == PermissionStatus.granted) {
//     location.enableBackgroundMode(enable: true);
//     location.changeSettings(
//         accuracy: LocationAccuracy.navigation, distanceFilter: 50);

//     LocationData locationData = await location.getLocation();

//     // Atualiza no Firestore
//     var user =
//         await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID);
//     if (user != null && user.isActive == true) {
//       user.location = UserLocation(
//         latitude: locationData.latitude ?? 0.0,
//         longitude: locationData.longitude ?? 0.0,
//       );
//       user.rotation = locationData.heading;
//       await FireStoreUtils.updateCurrentUser(user);
//     }
//   } else {
//     await location.requestPermission();
//   }
// }

// // Função para inicializar o serviço de background
// void onStart(ServiceInstance service) {
//   service.on('setAsForeground').listen((event) {
//     service.setAsForegroundService();
//   });

//   service.on('setAsBackground').listen((event) {
//     service.setAsBackgroundService();
//   });

//   Timer.periodic(Duration(minutes: 1), (timer) async {
//     await updateCurrentLocation();
//   });
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await FlutterBackgroundService.initialize(onStart);
//   runApp(MyApp());
// }
