import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/CurrencyModel.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/Language/language_choose_screen.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/ui/bank_details/bank_details_Screen.dart';
import 'package:emartdriver/ui/chat/SupportChatScreen.dart';
import 'package:emartdriver/ui/chat_screen/inbox_screen.dart';
import 'package:emartdriver/ui/home/HomeScreen.dart';
import 'package:emartdriver/ui/ordersScreen/OrdersScreen.dart';
import 'package:emartdriver/ui/privacy_policy/privacy_policy.dart';
import 'package:emartdriver/ui/profile/ProfileScreen.dart';
import 'package:emartdriver/ui/signUp/FirstStepsScreen.dart';
import 'package:emartdriver/ui/termsAndCondition/terms_and_codition.dart';
import 'package:emartdriver/ui/wallet/walletScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emartdriver/ui/faq/FaqScreen.dart';
import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';

enum DrawerSelection {
  Home,
  Cuisines,
  Search,
  Cart,
  Drivers,
  rideSetting,
  Profile,
  Orders,
  Logout,
  Wallet,
  Faq,
  Help,
  Tutoriais,
  BankInfo,
  termsCondition,
  privacyPolicy,
  inbox,
  chooseLanguage,
}

class ContainerScreen extends StatefulWidget {
  final User user;

  ContainerScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _ContainerScreen createState() {
    return _ContainerScreen();
  }
}

class _ContainerScreen extends State<ContainerScreen> {
  String _appBarTitle = 'Home'.tr();
  final fireStoreUtils = FireStoreUtils();
  late Widget _currentWidget;
  DrawerSelection _drawerSelection = DrawerSelection.Home;

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _currentWidget = HomeScreen();
    setCurrency();
    updateCurrentLocation();
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  setCurrency() async {
    /*FireStoreUtils().getCurrency().then((value) => value.forEach((element) {
          if (element.isactive = true) {
            currencyData = element;
          }
        }));*/
    await FireStoreUtils().getRazorPayDemo();
    await FireStoreUtils.getPaypalSettingData();
    await FireStoreUtils.getStripeSettingData();
    await FireStoreUtils.getPayStackSettingData();
    await FireStoreUtils.getFlutterWaveSettingData();
    await FireStoreUtils.getPaytmSettingData();
    await FireStoreUtils.getWalletSettingData();
    await FireStoreUtils.getPayFastSettingData();
    await FireStoreUtils.getMercadoPagoSettingData();
    await FireStoreUtils.getDriverOrderSetting();
    await FireStoreUtils.getOrangeMoneySettingData();
    await FireStoreUtils.getXenditSettingData();
    await FireStoreUtils.getMidTransSettingData();

    setState(() {
      isLoading = false;
    });
  }

  Location location = Location();
  LatLng? _currentLatLng;
  GoogleMapController? _mapController;

  updateCurrentLocation() async {
    PermissionStatus permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.granted) {
      print("---->");
      location.enableBackgroundMode(enable: true);
      location.changeSettings(
          accuracy: LocationAccuracy.navigation, distanceFilter: 50);
      location.onLocationChanged.listen((locationData) async {
        locationDataFinal = locationData;
        if (_currentLatLng == null &&
            locationData.latitude != null &&
            locationData.longitude != null) {
          setState(() {
            _currentLatLng =
                LatLng(locationData.latitude!, locationData.longitude!);
          });
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(_currentLatLng!),
            );
          }
        }
        await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID)
            .then((value) {
          if (value != null) {
            User driverUserModel = value;
            if (driverUserModel.isActive == true) {
              driverUserModel.location = UserLocation(
                  latitude: locationData.latitude ?? 0.0,
                  longitude: locationData.longitude ?? 0.0);
              driverUserModel.rotation = locationData.heading;
              FireStoreUtils.updateCurrentUser(driverUserModel);
            }
          }
        });
      });
    } else {
      await openBackgroundLocationDialog();
      await location.requestPermission().then((permissionStatus) {
        if (permissionStatus == PermissionStatus.granted) {
          location.enableBackgroundMode(enable: true);
          location.changeSettings(
              accuracy: LocationAccuracy.navigation, distanceFilter: 50);
          location.onLocationChanged.listen((locationData) async {
            locationDataFinal = locationData;
            if (_currentLatLng == null &&
                locationData.latitude != null &&
                locationData.longitude != null) {
              setState(() {
                _currentLatLng =
                    LatLng(locationData.latitude!, locationData.longitude!);
              });
              if (_mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLng(_currentLatLng!),
                );
              }
            }
            await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID)
                .then((value) {
              if (value != null) {
                User driverUserModel = value;
                if (driverUserModel.isActive == true) {
                  driverUserModel.location = UserLocation(
                      latitude: locationData.latitude ?? 0.0,
                      longitude: locationData.longitude ?? 0.0);
                  driverUserModel.rotation = locationData.heading;
                  FireStoreUtils.updateCurrentUser(driverUserModel);
                }
              }
            });
          });
        }
      });
    }
  }

  openBackgroundLocationDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              //width: 300.0,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Text(
                      "Background Location permission".tr(),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: Text(
                        "This app collects location data to enable location fetching at the time of you are on the way to deliver order or even when the app is in background."
                            .tr()),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: AppThemeData.green,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16.0),
                            bottomRight: Radius.circular(16.0)),
                      ),
                      child: Text(
                        "Okay".tr(),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  DateTime pre_backpress = DateTime.now();

  final audioPlayer = AudioPlayer(playerId: "playerId");

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= Duration(seconds: 2);
        pre_backpress = DateTime.now();
        if (cantExit) {
          final snack = SnackBar(
            content: Text(
              'Press Back button again to Exit'.tr(),
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        drawer: Drawer(
          backgroundColor: AppThemeData.newBlack,
          child: Column(
            children: [
              Expanded(
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
                              // width: 100,
                              height: 120,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ListTileTheme(
                    //   style: ListTileStyle.drawer,
                    //   selectedColor: Color(COLOR_PRIMARY),
                    //   child: ListTile(
                    //     selected: _drawerSelection == DrawerSelection.Home,
                    //     title:
                    //         Text('Home', style: TextStyle(color: Colors.white))
                    //             .tr(),
                    //     onTap: () {
                    //       Navigator.pop(context);
                    //       setState(() {
                    //         _drawerSelection = DrawerSelection.Home;
                    //         _appBarTitle = 'Home'.tr();
                    //         _currentWidget = HomeScreen();
                    //       });
                    //     },
                    //     leading: Icon(CupertinoIcons.home, color: Colors.white),
                    //   ),
                    // ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Orders,
                        leading: Image.asset(
                          'assets/images/truck.png',
                          color: Colors.white,
                          width: 24,
                          height: 24,
                        ),
                        title: Text('Orders',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                        onTap: () {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdersScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Profile,
                        leading:
                            Icon(CupertinoIcons.person, color: Colors.white),
                        title: Text('Profile',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(user: MyAppState.currentUser!),
                            ),
                          );
                        },
                      ),
                    ),

                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),
                    // ListTileTheme(
                    //   style: ListTileStyle.drawer,
                    //   selectedColor: Color(COLOR_PRIMARY),
                    //   child: ListTile(
                    //     leading: Icon(Icons.history, color: Colors.white),
                    //     title: Text('Histórico',
                    //             style: TextStyle(color: Colors.white))
                    //         .tr(),
                    //     onTap: () {
                    //       Navigator.pop(context);
                    //       // TODO: Implementar tela de histórico
                    //     },
                    //   ),
                    // ),

                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),

                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Wallet,
                        leading: Icon(Icons.account_balance_wallet_rounded,
                            color: Colors.white),
                        title: Text('Wallet',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalletScreen()),
                          );
                        },
                      ),
                    ),
                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),

                    // ListTileTheme(
                    //   style: ListTileStyle.drawer,
                    //   selectedColor: Color(COLOR_PRIMARY),
                    //   child: ListTile(
                    //     leading: Icon(Icons.help_outline, color: Colors.white),
                    //     title: Text('Ajuda e Suporte',
                    //             style: TextStyle(color: Colors.white))
                    //         .tr(),
                    //     onTap: () {
                    //       Navigator.pop(context);
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => SupportChatScreen()),
                    //       );
                    //       // TODO: Implementar tela de ajuda e suporte
                    //     },
                    //   ),
                    // ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Help,
                        leading: Icon(Icons.help_outline, color: Colors.white),
                        title: Text('Help & Support',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                        onTap: () {
                          Navigator.pop(context);
                          // setState(() {
                          //   _drawerSelection = DrawerSelection.Help;
                          //   // _appBarTitle = 'FAQ'.tr();
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SupportChatScreen(fromDrawer: true
                                        // user: MyAppState.currentUser!,
                                        )),
                          );
                        },
                      ),
                    ),

                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),
                    // ListTileTheme(
                    //   style: ListTileStyle.drawer,
                    //   selectedColor: Color(COLOR_PRIMARY),
                    //   child: ListTile(
                    //     leading: Icon(Icons.school, color: Colors.white),
                    //     title: Text('Tutoriais',
                    //             style: TextStyle(color: Colors.white))
                    //         .tr(),
                    //     onTap: () {
                    //       Navigator.pop(context);
                    //       // TODO: Implementar tela de tutoriais
                    //     },
                    //   ),
                    // ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Tutoriais,
                        leading: Icon(Icons.school, color: Colors.white),
                        title: Text('Tutorials',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FirstStepsScreen(fromDrawer: true),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),

                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Faq,
                        leading:
                            Icon(Icons.question_answer, color: Colors.white),
                        title:
                            Text('FAQ', style: TextStyle(color: Colors.white))
                                .tr(),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FaqScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected:
                            _drawerSelection == DrawerSelection.termsCondition,
                        leading: Icon(Icons.description, color: Colors.white),
                        title: Text('Terms and Conditions',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsAndCondition(),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected:
                            _drawerSelection == DrawerSelection.privacyPolicy,
                        leading: Icon(Icons.privacy_tip, color: Colors.white),
                        title: Text('Privacy Policy',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(
                      color: Colors.white24,
                      height: 0,
                      indent: 10,
                      endIndent: 100,
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Logout,
                        leading: Icon(Icons.logout, color: Colors.white),
                        title: Text('Log out',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                        onTap: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Logout'),
                              content: Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text('Logout'),
                                ),
                              ],
                            ),
                          );
                          if (shouldLogout != true) return;
                          audioPlayer.stop();
                          Navigator.pop(context);
                          await FireStoreUtils.getCurrentUser(
                                  MyAppState.currentUser!.userID)
                              .then((value) {
                            MyAppState.currentUser = value;
                          });
                          MyAppState.currentUser!.isActive = false;
                          MyAppState.currentUser!.lastOnlineTimestamp =
                              Timestamp.now();
                          await FireStoreUtils.updateCurrentUser(
                              MyAppState.currentUser!);
                          await auth.FirebaseAuth.instance.signOut();
                          MyAppState.currentUser = null;
                          location.enableBackgroundMode(enable: false);
                          pushAndRemoveUntil(context,
                              PhoneNumberInputScreen(login: false), false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("V : $appVersion",
                    style: TextStyle(color: Colors.white70)),
              )
            ],
          ),
        ),
        appBar: _drawerSelection == DrawerSelection.Profile ||
                _currentWidget is FirstStepsScreen ||
                _currentWidget is SupportChatScreen ||
                _drawerSelection == DrawerSelection.Orders
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 110,
                leading: Container(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    scale: 100,
                    width: 100,
                    fit: BoxFit.contain,
                    height: 100,
                  ),
                ),
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: isDarkMode(context)
                            ? Colors.white
                            : Color(DARK_COLOR),
                        size: 28,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
        body: _drawerSelection == DrawerSelection.Home
            ? Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLatLng ?? LatLng(-25.550520, 32.633308),
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_currentLatLng != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLng(_currentLatLng!),
                        );
                      }
                    },
                  ),
                  // Contêiner "Disponível" fixo
                  Positioned(
                    top: kToolbarHeight +
                        35.0, // Ajuste para posicionar abaixo do AppBar
                    left: 16.0,
                    right: 16.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppThemeData.newBlack,
                        borderRadius: BorderRadius.circular(
                            10), // Conforme sua preferência
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(COLOR_PRIMARY),
                              shape: BoxShape.circle,
                            ),
                            child: (MyAppState.currentUser != null &&
                                    MyAppState.currentUser!.profilePictureURL
                                        .isNotEmpty)
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: MyAppState
                                          .currentUser!.profilePictureURL,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 24),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.person,
                                              color: Colors.white, size: 24),
                                    ),
                                  )
                                : Icon(Icons.person,
                                    color: Colors.white, size: 24),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(COLOR_PRIMARY),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Available'.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Switch(
                            value: MyAppState.currentUser?.isActive ?? false,
                            onChanged: (bool value) {
                              if (value &&
                                  !(MyAppState.currentUser?.isReady ?? false)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Your registration must be approved before you can become available.'
                                            .tr()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                MyAppState.currentUser?.isActive = value;
                              });
                              FireStoreUtils.updateCurrentUser(
                                  MyAppState.currentUser!);
                            },
                            activeColor: Color(COLOR_PRIMARY),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Draggable green sheet
                  DraggableScrollableSheet(
                    initialChildSize: 0.65,
                    minChildSize: 0.2,
                    maxChildSize: 0.9,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppThemeData.green,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : _currentWidget,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            : _currentWidget,
      ),
    );
  }
}
