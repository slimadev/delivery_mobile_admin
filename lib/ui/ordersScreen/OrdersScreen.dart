import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/OrderModel.dart';
import 'package:emartdriver/model/ProductModel.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emartdriver/ui/coleta/ColetaScreen.dart';
import 'package:emartdriver/ui/entrega/EntregaScreen.dart';
import 'package:emartdriver/ui/entrega/DeliverySuccessScreen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderModel>> ordersFuture;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<OrderModel> ordersList = [];

  @override
  void initState() {
    super.initState();
    ordersFuture =
        _fireStoreUtils.getDriverOrders(MyAppState.currentUser!.userID);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'aceito':
      case ORDER_STATUS_DRIVER_ACCEPTED:
        return Colors.orange;
      case 'em_andamento':
      case ORDER_STATUS_DRIVER_ARRIVED_AT_STORE:
        return const Color.fromARGB(255, 57, 61, 65);
      case 'entregue':
      case ORDER_STATUS_DRIVER_DELIVERED:
        return Colors.green;
      case ORDER_STATUS_DRIVER_PICKED_UP:
        return Colors.yellowAccent;
      case 'cancelado':
      case 'cancelled':
        return Colors.red;
      case ORDER_STATUS_DRIVER_ARRIVED:
        return AppThemeData.newBlack;
      default:
        return Colors.grey;
    }
  }

  bool isOrderActionable(String status) {
    // Ajuste conforme seus status de ação
    return status.toLowerCase() == 'aceito' ||
        status.toLowerCase() == 'accepted' ||
        status.toLowerCase() == 'em_andamento' ||
        status.toLowerCase() == 'in_progress';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('My Orders',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: FutureBuilder<List<OrderModel>>(
          future: ordersFuture,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(
                      Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
              );
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: showEmptyState('No Previous Orders'.tr(),
                    description: "Let's deliver food!".tr()),
              );
            } else {
              ordersList = snapshot.data!;
              return ListView.builder(
                  itemCount: ordersList.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) =>
                      buildOrderItem(ordersList[index]));
            }
          }),
    );
  }

  Widget buildOrderItem(OrderModel orderModel) {
    final bool isActive = isOrderActionable(orderModel.status);
    return InkWell(
      onTap: MyAppState.currentUser!.active
          ? () {
              switch (orderModel.driver_status) {
                case ORDER_STATUS_DRIVER_ACCEPTED:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ColetaScreen(
                        order: orderModel,
                        vendor: orderModel.vendor,
                        customer: orderModel.author,
                        orderNumber: orderModel.orderNumber,
                        arrivedAtPickup: false,
                      ),
                    ),
                  );
                  break;
                case ORDER_STATUS_DRIVER_ARRIVED_AT_STORE:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ColetaScreen(
                        order: orderModel,
                        vendor: orderModel.vendor,
                        customer: orderModel.author,
                        orderNumber: orderModel.orderNumber,
                        arrivedAtPickup: true,
                      ),
                    ),
                  );
                  break;
                case ORDER_STATUS_DRIVER_PICKED_UP:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliveryScreen(
                        order: orderModel,
                        vendor: orderModel.vendor,
                        orderNumber: orderModel.orderNumber,
                      ),
                    ),
                  );
                  break;
                case ORDER_STATUS_DRIVER_DELIVERED:
                  // Navigator.push(
                  //   context,
                  //   // MaterialPageRoute(
                  //   //   builder: (_) => DeliverySuccessScreen(order: orderModel,
                  //   //   earnings: orderModel.deliveryCharge ?? ,
                  //   //   bonus: orderModel.adminCommission,
                  //   //   to),
                  //   // ),
                  // );
                  break;
                case ORDER_STATUS_DRIVER_ARRIVED:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliveryScreen(
                        order: orderModel,
                        vendor: orderModel.vendor,
                        orderNumber: orderModel.orderNumber ?? 1,
                        arrived: true,
                      ),
                    ),
                  );
                  break;
                default:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: orderModel),
                    ),
                  );
              }
            }
          : null,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loja origem
              Row(
                children: [
                  Icon(Icons.store, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orderModel.vendor.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              // Endereço de entrega
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orderModel.address.locality ?? '',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              // Delivery charge e status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Entrega: ' +
                        amountShow(
                            amount: orderModel.deliveryCharge.toString()),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Chip(
                    label: Text(orderModel.driver_status,
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: getStatusColor(orderModel.driver_status),
                  ),
                ],
              ),
              SizedBox(height: 6),
              // Data/hora
              Text(
                'Data: ' + orderDate(orderModel.createdAt),
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final audioPlayer = AudioPlayer(playerId: "playerId");
  bool isPlaying = false;

  playSound() async {
    final path = await rootBundle
        .load("assets/audio/mixkit-happy-bells-notification-937.mp3");

    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        volume: 15,
        ctx: AudioContext(
            android: AudioContextAndroid(
                contentType: AndroidContentType.music,
                isSpeakerphoneOn: true,
                stayAwake: true,
                usageType: AndroidUsageType.alarm,
                audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(category: AVAudioSessionCategory.playback)));
  }
}

// Placeholder para tela de detalhes do pedido
class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loja: ${order.vendor.title}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Endereço de entrega: ${order.address.locality ?? ''}'),
            SizedBox(height: 8),
            Text('Valor da entrega: ' +
                amountShow(amount: order.deliveryCharge.toString())),
            SizedBox(height: 8),
            Text('Status: ${order.driver_status}'),
            SizedBox(height: 8),
            Text('Data: ' + orderDate(order.createdAt)),
            // Adicione mais detalhes relevantes se necessário
          ],
        ),
      ),
    );
  }
}

Widget _buildChip(String label, int attributesOptionIndex) {
  return Container(
    decoration: BoxDecoration(
        color: const Color(0xffEEEDED), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  );
}
