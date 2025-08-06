import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/DeliveryChargeModel.dart';
import 'package:emartdriver/model/OrderModel.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/model/VendorModel.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/services/send_notification.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/chat_screen/chat_screen.dart';
import 'package:emartdriver/ui/home/pick_order.dart';
import 'package:emartdriver/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osmflutter;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:emartdriver/services/notification_service.dart';
// import 'package:emartdriver/services/event_bus.dart';
import 'package:emartdriver/ui/accountDetails/AccountDetailsScreen.dart';
import 'package:emartdriver/ui/contactUs/ContactUsScreen.dart';
// import 'package:emartdriver/ui/orderDetails/OrderDetailsScreen.dart';
import 'package:emartdriver/ui/settings/SettingsScreen.dart';
import 'package:emartdriver/ui/wallet/WalletScreen.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:emartdriver/ui/coleta/ColetaScreen.dart';
import 'package:emartdriver/ui/entrega/EntregaScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final fireStoreUtils = FireStoreUtils();

  GoogleMapController? _mapController;
  bool canShowSheet = true;

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;

  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  final Map<String, Marker> _markers = {};

  Image? departureOsmIcon; //OSM
  Image? destinationOsmIcon; //OSM
  Image? driverOsmIcon;

  late osmflutter.MapController mapOsmController;

  late Stream<OrderModel?> ordersFuture;
  OrderModel? currentOrder;

  late Stream<User> driverStream;
  User? _driverModel = User();
  double kilometer = 0.0;

  Timer? _timer;
  final AudioPlayer audioPlayer = AudioPlayer();

  bool? deliverExec = false;
  var deliveryCharges = "0.0";
  VendorModel? vendorModel;

  StreamSubscription? _eventSubscription;

  int? acceptedRidesCount;
  int? completedRidesCount;
  int? rejectedRidesCount;

  late BuildContext rootContext;

  void getDriver() {
    // Implementação da lógica para obter dados do motorista
    FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
      _driverModel = value;
    });
  }

  void getOSMPolyline() {
    // Implementação da lógica para obter polylines para OSM
  }

  void getDirections() {
    // Implementação da lógica para obter direções (Google Maps)
  }

  setIcons() async {
    if (selectedMapType == 'google') {
      BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(10, 10)),
              "assets/images/pickup.png")
          .then((value) {
        departureIcon = value;
      });

      BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(10, 10)),
              "assets/images/dropoff.png")
          .then((value) {
        destinationIcon = value;
      });

      BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(10, 10)),
              "assets/images/food_delivery.png")
          .then((value) {
        taxiIcon = value;
      });
    } else {
      departureOsmIcon =
          Image.asset("assets/images/pickup.png", width: 40, height: 40); //OSM
      destinationOsmIcon =
          Image.asset("assets/images/dropoff.png", width: 40, height: 40); //OSM
      driverOsmIcon = Image.asset("assets/images/food_delivery.png",
          width: 100, height: 100); //OSM
    }
  }

  updateDriverOrder() async {
    Timestamp startTimestamp = Timestamp.now();
    DateTime currentDate = startTimestamp.toDate();
    currentDate = currentDate.subtract(Duration(hours: 3));
    startTimestamp = Timestamp.fromDate(currentDate);

    List<OrderModel> orders = [];

    print('-->startTime${startTimestamp.toDate()}');
    await FirebaseFirestore.instance
        .collection(ORDERS)
        .where('status',
            whereIn: [ORDER_STATUS_ACCEPTED, ORDER_STATUS_DRIVER_REJECTED])
        .where('createdAt', isGreaterThan: startTimestamp)
        .get()
        .then((value) async {
          print('---->${value.docs.length}');
          await Future.forEach(value.docs,
              (QueryDocumentSnapshot<Map<String, dynamic>> element) {
            try {
              orders.add(OrderModel.fromJson(element.data()));
            } catch (e, s) {
              print('watchOrdersStatus parse error ${element.id}$e $s');
            }
          });
        });

    orders.forEach((element) {
      OrderModel orderModel = element;
      print('---->${orderModel.id}');
      orderModel.trigger_delevery = Timestamp.now();
      FirebaseFirestore.instance
          .collection(ORDERS)
          .doc(element.id)
          .set(orderModel.toJson(), SetOptions(merge: true))
          .then((order) {
        print('Done.');
      });
    });
  }

  @override
  void initState() {
    super.initState();

    if (selectedMapType == 'osm') {
      setState(() {
        mapOsmController = osmflutter.MapController(
            initPosition:
                osmflutter.GeoPoint(latitude: -25.0000, longitude: 32.7439),
            useExternalTracking: false); //OSM
      });
    }
    getDriver();
    setIcons();
    updateDriverOrder();
    getCurrentOrder(); // Garantir que currentOrder seja inicializado
    fetchRideStats();
    // Escuta eventos de notificação
    _eventSubscription = eventBus.on<ShowOrderDetailsEvent>().listen((event) {
      showOrderDetailsPopup(event.orderId);
    });
  }

  getDeliveryCharges(num km, String vendorID) async {
    deliverExec = true;

    await FireStoreUtils().getVendorByVendorID(vendorID).then((value) {
      vendorModel = value;
    });
    await FireStoreUtils().getDeliveryCharges().then((value) {
      if (value != null) {
        DeliveryChargeModel deliveryChargeModel = value;
        if (!deliveryChargeModel.vendor_can_modify) {
          if (km > deliveryChargeModel.minimum_delivery_charges_within_km) {
            deliveryCharges = (km * deliveryChargeModel.delivery_charges_per_km)
                .toDouble()
                .toStringAsFixed(currencyData!.decimal);
            setState(() {});
          } else {
            deliveryCharges = deliveryChargeModel.minimum_delivery_charges
                .toDouble()
                .toStringAsFixed(currencyData!.decimal);
            setState(() {});
          }
        } else {
          if (vendorModel != null && vendorModel!.DeliveryCharge != null) {
            if (km >
                vendorModel!
                    .DeliveryCharge!.minimum_delivery_charges_within_km) {
              deliveryCharges =
                  (km * vendorModel!.DeliveryCharge!.delivery_charges_per_km)
                      .toDouble()
                      .toStringAsFixed(currencyData!.decimal);
              setState(() {});
            } else {
              deliveryCharges = vendorModel!
                  .DeliveryCharge!.minimum_delivery_charges
                  .toDouble()
                  .toStringAsFixed(currencyData!.decimal);
              setState(() {});
            }
          }
        }
      }
    });
  }

  getCurrentOrder() async {
    ordersFuture = FireStoreUtils()
        .getOrderByID(MyAppState.currentUser!.inProgressOrderID.toString());
    ordersFuture.listen((event) {
      print("------->${event!.status}");
      setState(() {
        currentOrder = event;
        if (selectedMapType == "osm") {
          getOSMPolyline();
        } else {
          getDirections();
        }
      });
    });
  }

  void startTimer(User _driverModel) {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) async {
        print("startTimer00000");
        print(driverOrderAcceptRejectDuration);
        if (driverOrderAcceptRejectDuration == 0) {
          if (MyAppState.currentUser!.inProgressOrderID != '') {
            audioPlayer.stop();
            OrderModel? order = await FireStoreUtils()
                .getOrderByID(
                    MyAppState.currentUser!.inProgressOrderID.toString())
                .first; // Usar .first para obter um Future do Stream

            if (order == null ||
                order.status == ORDER_STATUS_COMPLETED ||
                order.status == ORDER_STATUS_REJECTED) {
              timer.cancel();
              audioPlayer.stop();
              MyAppState.currentUser!.inProgressOrderID = '';
              FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
              setState(() {});
            } else if (order.status == ORDER_STATUS_ACCEPTED) {
              audioPlayer.stop();
              timer.cancel();
              pushAndRemoveUntil(
                  context, PickOrder(currentOrder: order), false);
            }
          } else {
            audioPlayer.stop();
            timer.cancel();
          }
        } else {
          driverOrderAcceptRejectDuration--;
        }
      },
    );
  }

  sendNotification(OrderModel orderModel, User driverModel) async {
    await SendNotification.sendFcmMessage(
        "new_order", // type
        driverModel.fcmToken, // token
        null // payload
        );
  }

  playSound() async {
    final path = await rootBundle
        .load("assets/audio/mixkit-happy-bells-notification-937.mp3");
    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        volume: 5,
        ctx: AudioContext(
            android: AudioContextAndroid(
                contentType: AndroidContentType.music,
                isSpeakerphoneOn: true,
                stayAwake: true,
                usageType: AndroidUsageType.alarm,
                audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(category: AVAudioSessionCategory.playback)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  // Adicionando função para testar envio de notificação
  Future<void> testSendNotification() async {
    try {
      // Obtém o token FCM do usuário atual
      String token = await NotificationService.getToken();

      // Prepara os dados da notificação
      Map<String, dynamic> payload = {
        'type': 'new_order',
        'orderId': 'test_order_${DateTime.now().millisecondsSinceEpoch}',
        'customerId': 'test_customer',
        'customerName': 'Cliente Teste',
        'customerProfileImage': 'https://example.com/image.jpg',
        'restaurantId': 'test_restaurant',
        'restaurantName': 'Restaurante Teste',
        'restaurantProfileImage': 'https://example.com/restaurant.jpg',
        'token': token,
        'chatType': 'order'
      };

      // Envia a notificação
      bool success = await SendNotification.sendFcmMessage(
          'new_order', // tipo da notificação
          token, // token do dispositivo
          payload // dados adicionais
          );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notification'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showOrderDetailsPopup(String orderId) async {
    // playSound();
    // Buscar o pedido pelo orderId
    final orderDoc =
        await FirebaseFirestore.instance.collection(ORDERS).doc(orderId).get();
    if (!orderDoc.exists) return;
    final order = OrderModel.fromJson(orderDoc.data()!);

    final loja = order.vendor.title;
    final enderecoLoja = order.vendor.location;
    final enderecoCliente = order.address.locality ?? '';
    final numeroPedido = order.id;
    final status = order.status;
    final customerId = order.authorID;
    final valor = order.vendor.price.isNotEmpty ? order.vendor.price : '';
    final reviewsCount = order.vendor.reviewsCount;
    final reviewsSum = order.vendor.reviewsSum;
    final rating = (reviewsCount > 0)
        ? (reviewsSum / reviewsCount).toStringAsFixed(1)
        : '-';

    final double width = MediaQuery.of(context).size.width * 0.92;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: width,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF82C100),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NEW ORDER!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do local e selo
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              loja,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rating != '-')
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFF82C100),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    rating,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Valor
                      if (valor.isNotEmpty)
                        Text(
                          valor,
                          style: TextStyle(
                            color: Color(0xFF82C100),
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                      SizedBox(height: 18),
                      // Origem
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.store, color: Color(0xFF82C100), size: 28),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enderecoLoja,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Destino
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on,
                              color: Color(0xFF82C100), size: 28),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enderecoCliente,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Botão Aceitar (Slide)
                      SizedBox(
                        width: double.infinity,
                        child: SlideAction(
                            text: 'Slide to Accept',
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            outerColor: Color(0xFF82C100),
                            innerColor: Colors.white,
                            elevation: 2,
                            sliderButtonIcon: Icon(Icons.arrow_forward,
                                color: Color(0xFF82C100)),
                            onSubmit: () async {
                              Navigator.pop(
                                  context); // Fechar o diálogo imediatamente
                              audioPlayer.stop();
                              updateOrder(
                                  orderId, ORDER_STATUS_DRIVER_ACCEPTED);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ColetaScreen(
                                    order: order,
                                    vendor: order.vendor,
                                    customer: order.author,
                                    orderNumber:
                                        int.tryParse(numeroPedido) ?? 0,
                                    onMap: () {},
                                    // bottomButtonText:
                                    //     'I arrived at pickup location',
                                    // bottomButtonColor: AppThemeData.newBlack,
                                    onBottomButton: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DeliveryScreen(
                                              order: order,
                                              vendor: order.vendor,
                                              orderNumber:
                                                  int.tryParse(numeroPedido) ??
                                                      0),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  updateOrder(String orderId, String status) {
    FireStoreUtils.updateOrderDriverId(
        orderId: orderId,
        driverId: MyAppState.currentUser?.userID ?? '',
        driverStatus: status);
  }
  //

  Future<double> getDailyEarnings() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(ORDERS)
        .where('driverID', isEqualTo: MyAppState.currentUser!.userID)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc['driverAmount'] ?? 0).toDouble();
    }
    return total;
  }

  Future<void> fetchRideStats() async {
    final userId = MyAppState.currentUser!.userID;
    final firestore = FirebaseFirestore.instance;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    // Aceites
    final accepted = await firestore
        .collection(ORDERS)
        .where('driverID', isEqualTo: userId)
        .where('status', isEqualTo: ORDER_STATUS_ACCEPTED)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();
    // Finalizadas
    final completed = await firestore
        .collection(ORDERS)
        .where('driverID', isEqualTo: userId)
        .where('status', isEqualTo: ORDER_STATUS_COMPLETED)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();
    // Recusadas
    final rejected = await firestore
        .collection(ORDERS)
        .where('driverID', isEqualTo: userId)
        .where('status', isEqualTo: ORDER_STATUS_REJECTED)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    setState(() {
      acceptedRidesCount = accepted.size;
      completedRidesCount = completed.size;
      rejectedRidesCount = rejected.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    rootContext = context;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          top: 16.0,
          bottom:
              16.0), // Padding ajustado para ser o conteúdo de uma folha arrastável
      child: Column(
        children: [
          // Greeting: Auxene Joaquim! with sun icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auxene\n${MyAppState.currentUser?.firstName ?? 'User'}!',
                  style: TextStyle(
                    color: AppThemeData.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                Icon(
                  Icons.wb_sunny,
                  color: Colors.amberAccent,
                  size: 70,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Statistic Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Daily earnings'.tr(),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                            SizedBox(height: 8),
                            FutureBuilder<double>(
                              future: getDailyEarnings(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Text('...',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(COLOR_PRIMARY)));
                                }
                                return Text(
                                  '${snapshot.data!.toStringAsFixed(2)} MZN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Total Balance: ${MyAppState.currentUser!.walletAmount.toStringAsFixed(2)} MT'
                                  .tr(),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Accepted Rides: ' +
                                  (acceptedRidesCount == null
                                      ? '...'
                                      : acceptedRidesCount.toString()),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Completed: ' +
                                  (completedRidesCount == null
                                      ? '...'
                                      : completedRidesCount.toString()),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                            Text(
                              'Rejected: ' +
                                  (rejectedRidesCount == null
                                      ? '...'
                                      : rejectedRidesCount.toString()),
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Discount Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/puma_banner.png'), // Assuming a banner image
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '10% discount\nif you refuel at\nPUMA!'.tr(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
