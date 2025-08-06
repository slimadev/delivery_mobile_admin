import 'package:emartdriver/model/OrderModel.dart';
import 'package:emartdriver/model/VendorModel.dart';
import 'package:emartdriver/model/User.dart';
import 'package:flutter/material.dart';
import 'package:emartdriver/ui/entrega/EntregaScreen.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:emartdriver/constants.dart';

class ColetaScreen extends StatefulWidget {
  final OrderModel order;
  final VendorModel vendor;
  final User customer;
  final int orderNumber;
  final bool arrivedAtPickup;
  final VoidCallback? onMap;
  // bottomButtonText e bottomButtonColor agora são definidos pelo estado
  final VoidCallback? onBottomButton;

  const ColetaScreen({
    Key? key,
    required this.order,
    required this.vendor,
    required this.customer,
    required this.orderNumber,
    this.arrivedAtPickup = false,
    this.onMap,
    this.onBottomButton,
  }) : super(key: key);

  @override
  State<ColetaScreen> createState() => _ColetaScreenState();
}

class _ColetaScreenState extends State<ColetaScreen> {
  bool showMap = false;
  LatLng? _currentPosition;
  Polyline? _routePolyline;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    //
  }

  Future<void> _showRouteOnMap() async {
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(pos.latitude, pos.longitude),
        destination:
            PointLatLng(widget.vendor.latitude, widget.vendor.longitude),
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
      showMap = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('PICKUP',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vendor.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Store address: ${widget.vendor.location}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Customer address: ${widget.order.address.locality}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _showRouteOnMap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF82C100)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.navigation, color: Color(0xFF82C100)),
                      SizedBox(height: 2),
                      Text('Map',
                          style: TextStyle(
                              color: Color(0xFF82C100),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            if (showMap && _currentPosition != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 14,
                    ),
                    polylines: _routePolyline != null ? {_routePolyline!} : {},
                    markers: {
                      Marker(
                        markerId: MarkerId('vendor'),
                        position: LatLng(
                            widget.vendor.latitude, widget.vendor.longitude),
                        infoWindow: InfoWindow(title: widget.vendor.title),
                      ),
                      Marker(
                        markerId: MarkerId('driver'),
                        position: _currentPosition!,
                        infoWindow: InfoWindow(title: 'You'),
                      ),
                    },
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                ),
              ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 12),
            Text('Order status: ${widget.order.status}',
                style: TextStyle(color: Colors.grey[700], fontSize: 15)),
            SizedBox(height: 18),
            Divider(),
            SizedBox(height: 18),
            Center(
              child: Column(
                children: [
                  Text('Order',
                      style: TextStyle(
                          color: Color(0xFF82C100),
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  SizedBox(height: 4),
                  Text('#${widget.orderNumber}',
                      style: TextStyle(
                          color: Color(0xFF82C100),
                          fontWeight: FontWeight.bold,
                          fontSize: 48)),
                ],
              ),
            ),
            SizedBox(height: 18),
            Divider(),
            SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!widget.arrivedAtPickup) {
                    // Atualiza status para DRIVER_ARRIVED
                    updateOrder();
                    // Primeira vez: recarrega a tela com arrivedAtPickup = true
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ColetaScreen(
                          order: widget.order,
                          vendor: widget.vendor,
                          customer: widget.customer,
                          orderNumber: widget.orderNumber,
                          arrivedAtPickup: true,
                        ),
                      ),
                    );
                  } else {
                    // Atualiza status para PICKED_UP
                    updateOrder();
                    // Segunda vez: vai para a tela de entrega
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryScreen(
                          order: widget.order,
                          vendor: widget.vendor,
                          orderNumber: widget.orderNumber,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.arrivedAtPickup ? Color(0xFF82C100) : Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  widget.arrivedAtPickup
                      ? 'Confirmo recebimento'
                      : 'I arrived at pickup location',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  updateOrder() {
    if (widget.arrivedAtPickup) {
      FireStoreUtils.updateOrderDriverId(
        orderId: widget.order.id,
        driverId: MyAppState.currentUser?.userID ?? '',
        driverStatus: ORDER_STATUS_DRIVER_PICKED_UP,
      );
    } else {
      FireStoreUtils.updateOrderDriverId(
        orderId: widget.order.id,
        driverId: MyAppState.currentUser?.userID ?? '',
        driverStatus: ORDER_STATUS_DRIVER_ARRIVED_AT_STORE,
      );
    }
  }
}
