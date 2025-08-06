import 'package:emartdriver/model/OrderModel.dart';
import 'package:emartdriver/model/VendorModel.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:emartdriver/ui/chat_screen/chat_screen.dart';
import 'package:emartdriver/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emartdriver/ui/entrega/DeliverySuccessScreen.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:emartdriver/constants.dart';
import 'dart:io';

class DeliveryScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onChat;
  final VoidCallback? onCheguei;
  final VendorModel vendor;
  final int orderNumber;
  final arrived;
  final String chatType;
  final String? token;
  static final ImagePicker _picker = ImagePicker();

  const DeliveryScreen({
    Key? key,
    required this.order,
    required this.vendor,
    required this.orderNumber,
    this.arrived = false,
    this.onChat,
    this.onCheguei,
    this.chatType = 'Driver',
    this.token,
  }) : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  LatLng? _currentPosition;
  Polyline? _routePolyline;
  GoogleMapController? _mapController;

  bool arrived = false;
  XFile? deliveryImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  Future<void> _initRoute() async {
    // 1. Obtenha localização atual
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    // 2. Calcule rota usando PolylinePoints
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(pos.latitude, pos.longitude),
        destination: PointLatLng(
          widget.order.address.location!.latitude,
          widget.order.address.location!.longitude,
        ),
        mode: TravelMode.driving,
      ),
      googleApiKey: GOOGLE_API_KEY,
    );

    List<LatLng> polylineCoordinates = result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    setState(() {
      _routePolyline = Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: polylineCoordinates,
      );
    });
  }

  Future<void> _onArrived() async {
    setState(() => isLoading = true);
    await FireStoreUtils.updateOrderDriverId(
      orderId: widget.order.id,
      driverId: MyAppState.currentUser?.userID ?? '',
      driverStatus: ORDER_STATUS_DRIVER_ARRIVED,
    );
    if (mounted) {
      setState(() {
        arrived = true;
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? img =
          await DeliveryScreen._picker.pickImage(source: ImageSource.camera);
      if (img != null) {
        if (mounted) {
          setState(() {
            deliveryImage = img;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao capturar imagem: ' + e.toString());
    }
  }

  void _onDelivered() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DeliverySuccessScreen(
          earnings: 94,
          bonus: 16,
          total: 110,
          onRate: () {
            // handle rating tap
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_logo.png', height: 45),
            SizedBox(width: 8),
            Text('ENTREGA',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF82C100)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF82C100)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa de fundo com rota
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition ??
                    LatLng(widget.order.address.location!.latitude,
                        widget.order.address.location!.longitude),
                zoom: 14,
              ),
              polylines: _routePolyline != null ? {_routePolyline!} : {},
              markers: {
                if (_currentPosition != null)
                  Marker(
                    markerId: MarkerId('driver'),
                    position: _currentPosition!,
                    infoWindow: InfoWindow(title: 'You'),
                  ),
                Marker(
                  markerId: MarkerId('destination'),
                  position: LatLng(widget.order.address.location!.latitude,
                      widget.order.address.location!.longitude),
                  infoWindow: InfoWindow(title: 'Delivery'),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
          // Card verde na parte inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF82C100),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(20, 18, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Endereço da entrega',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            SizedBox(height: 4),
                            Text(widget.order.address.locality ?? '',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chat_bubble_outline,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreens(
                                orderId: widget.order.id,
                                customerId: widget.order.authorID,
                                customerName: widget.order.author.firstName +
                                    " " +
                                    widget.order.author.lastName,
                                customerProfileImage:
                                    widget.order.author.profilePictureURL,
                                restaurantId:
                                    MyAppState.currentUser?.userID ?? '',
                                restaurantName:
                                    MyAppState.currentUser?.fullName() ?? '',
                                restaurantProfileImage:
                                    MyAppState.currentUser?.profilePictureURL ??
                                        '',
                                token: widget.token,
                                chatType: widget.chatType,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  if (!arrived)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onArrived,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF82C100)),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Arrived at delivery location',
                                style: TextStyle(
                                  color: Color(0xFF82C100),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                      ),
                    )
                  else if (deliveryImage == null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Carregar foto',
                          style: TextStyle(
                            color: Color(0xFF82C100),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (deliveryImage != null &&
                            File(deliveryImage!.path).existsSync())
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              image: DecorationImage(
                                image: FileImage(
                                  File(deliveryImage!.path),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        if (deliveryImage != null &&
                            !File(deliveryImage!.path).existsSync())
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Erro ao carregar a imagem. O arquivo não existe.',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        SizedBox(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onDelivered,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Encomenda Entregue',
                              style: TextStyle(
                                color: Color(0xFF82C100),
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
