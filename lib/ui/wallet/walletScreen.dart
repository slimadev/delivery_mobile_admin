import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/CabService/cab_order_detail_screen.dart';
import 'package:emartdriver/Parcel_service/parcel_order_detail_screen.dart';
import 'package:emartdriver/Parcel_service/parcel_order_model.dart';
import 'package:emartdriver/model/CabOrderModel.dart';
import 'package:emartdriver/model/FlutterWaveSettingDataModel.dart';
import 'package:emartdriver/model/MercadoPagoSettingsModel.dart';
import 'package:emartdriver/model/PayFastSettingData.dart';
import 'package:emartdriver/model/PayStackSettingsModel.dart';
import 'package:emartdriver/model/StripePayFailedModel.dart';
import 'package:emartdriver/model/createRazorPayOrderModel.dart';
import 'package:emartdriver/model/getPaytmTxtToken.dart';
import 'package:emartdriver/model/payStackURLModel.dart';
import 'package:emartdriver/model/payment_model/mid_trans.dart';
import 'package:emartdriver/model/payment_model/orange_money.dart';
import 'package:emartdriver/model/payment_model/xendit.dart';
import 'package:emartdriver/model/paypalSettingData.dart';
import 'package:emartdriver/model/paytmSettingData.dart';
import 'package:emartdriver/model/razorpayKeyModel.dart';
import 'package:emartdriver/model/stripeSettingData.dart';
import 'package:emartdriver/model/withdrawHistoryModel.dart';
import 'package:emartdriver/model/withdraw_method_model.dart';
import 'package:emartdriver/model/OrderModel.dart';
import 'package:emartdriver/payment/midtrans_screen.dart';
import 'package:emartdriver/payment/orangePayScreen.dart';
import 'package:emartdriver/payment/xenditModel.dart';
import 'package:emartdriver/payment/xenditScreen.dart';
import 'package:emartdriver/rental_service/model/rental_order_model.dart';
import 'package:emartdriver/rental_service/renatal_summary_screen.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/services/payStackScreen.dart';
import 'package:emartdriver/services/paystack_url_genrater.dart';
import 'package:emartdriver/services/show_toast_dialog.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/topup/TopUpScreen.dart';
import 'package:emartdriver/ui/wallet/MercadoPagoScreen.dart';
import 'package:emartdriver/ui/wallet/PayFastScreen.dart';
import 'package:emartdriver/userPrefrence.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';
import 'package:flutter_paypal_native/str_helper.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../constants.dart';
import '../../main.dart';
import '../../model/User.dart';
import 'rozorpayConroller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:mpesa_sdk_dart/mpesa_sdk_dart.dart';
import 'package:emartdriver/ui/wallet/mpesa_withdraw_screen.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// Adicionar enum para métodos de saque no topo do arquivo
enum WithdrawMethod { mpesa, bim, emola }

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? withdrawalHistoryQuery;
  Stream<QuerySnapshot>? dailyEarningQuery;
  Stream<QuerySnapshot>? monthlyEarningQuery;
  Stream<QuerySnapshot>? yearlyEarningQuery;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? userQuery;

  String? selectedRadioTile;

  GlobalKey<FormState> _globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _amountController = TextEditingController(text: "50");
  TextEditingController _noteController = TextEditingController(text: '');

  // Campo para método de saque
  WithdrawMethod? _selectedWithdrawMethod = WithdrawMethod.mpesa;

  final userId = MyAppState.currentUser!.userID;
  final driverId = MyAppState.currentUser!.userID;

  // Removido: String walletAmount = "0.0";

  // Removido: paymentCompleted, métodos de recarga

  WithdrawMethodModel? withdrawMethodModel;
  int selectedValue = 0;

  @override
  void initState() {
    getData();
    getPaymentSettingData();
    selectedRadioTile = "Stripe";
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    super.initState();
  }

  Stream<QuerySnapshot>? topupHistoryQuery;
  Razorpay _razorPay = Razorpay();
  RazorPayModel? razorPayData;
  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  PaypalSettingData? paypalSettingData;
  PayStackSettingData? payStackSettingData;
  FlutterWaveSettingData? flutterWaveSettingData;
  PayFastSettingData? payFastSettingData;
  MercadoPagoSettingData? mercadoPagoSettingData;
  MidTrans? midTransModel;
  OrangeMoney? orangeMoneyModel;
  Xendit? xenditModel;

  getPaymentSettingData() async {
    userQuery = fireStore
        .collection(USERS)
        .doc(MyAppState.currentUser!.userID)
        .snapshots();

    await UserPreference.getStripeData().then((value) async {
      stripeData = value;
      stripe1.Stripe.publishableKey = stripeData!.clientpublishableKey;
      stripe1.Stripe.merchantIdentifier = 'Foodie';
      await stripe1.Stripe.instance.applySettings();
    });

    razorPayData = await UserPreference.getRazorPayData();
    paytmSettingData = await UserPreference.getPaytmData();
    paypalSettingData = await UserPreference.getPayPalData();
    payStackSettingData = await UserPreference.getPayStackData();
    flutterWaveSettingData = await UserPreference.getFlutterWaveData();
    payFastSettingData = await UserPreference.getPayFastData();
    mercadoPagoSettingData = await UserPreference.getMercadoPago();
    midTransModel = await UserPreference.getMidTransData();
    orangeMoneyModel = await UserPreference.getOrangeData();
    xenditModel = await UserPreference.getXenditData();

    await FireStoreUtils.getWithdrawMethod().then((value) {
      if (value != null) {
        setState(() {
          withdrawMethodModel = value;
        });
      }
    });

    setRef();
    initPayPal();
  }

  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  void initPayPal() async {
    FlutterPaypalNative.isDebugMode =
        paypalSettingData!.isLive == false ? true : false;
    await _flutterPaypalNativePlugin.init(
      returnUrl: "com.emart.driver://paypalpay",
      clientID: paypalSettingData!.paypalClient,
      payPalEnvironment: paypalSettingData!.isLive == true
          ? FPayPalEnvironment.live
          : FPayPalEnvironment.sandbox,
      currencyCode: FPayPalCurrencyCode.usd,
      action: FPayPalUserAction.payNow,
    );

    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          Navigator.pop(context);
          ShowToastDialog.showToast("Payment canceled");
        },
        onSuccess: (data) {
          Navigator.pop(context);
          _flutterPaypalNativePlugin.removeAllPurchaseItems();
          ShowToastDialog.showToast("Payment Successfully");
          // Removido: paymentCompleted(paymentMethod: "Paypal");
        },
        onError: (data) {
          Navigator.pop(context);
          ShowToastDialog.showToast("error: ${data.reason}");
        },
        onShippingChange: (data) {
          Navigator.pop(context);
          ShowToastDialog.showToast(
              "shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppThemeData.grey50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('Carteira',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          automaticallyImplyLeading: true,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // CABEÇALHO - SALDO DE GANHOS
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF82C100),
                        Color.fromARGB(255, 88, 131, 3)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF82C100).withOpacity(0.18),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(16),
                          child: Icon(Icons.trending_up,
                              color: Colors.white, size: 38),
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Earnings'.tr(),
                                  style: TextStyle(
                                      color: AppThemeData.white, fontSize: 16)),
                              StreamBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                                stream: userQuery,
                                builder: (context, asyncSnapshot) {
                                  if (asyncSnapshot.hasError) {
                                    return Text('Error'.tr(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30));
                                  }
                                  if (asyncSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            color: Colors.white));
                                  }
                                  User userData = User.fromJson(
                                      asyncSnapshot.data!.data()!);
                                  return Text(
                                    '${amountShow(amount: userData.earningsBalance.toString())}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 36,
                                        letterSpacing: 1.2),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // BOTÃO DE SAQUE
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      withdrawAmountBottomSheet(context);
                    },
                    icon:
                        Icon(Icons.account_balance_wallet, color: Colors.white),
                    label: Text('Levantar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppThemeData.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF82C100),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
              ),

              // BOTÃO HISTÓRICO (apenas ganhos e saques)
              // Se quiser manter histórico, pode ajustar aqui para mostrar apenas earnings/withdrawals
              SizedBox(height: 18),
              // TABS DE HISTÓRICO
              tabController(),
              // BOTÃO FIXO GERAR PDF
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Descobrir qual aba está selecionada
                      final tabController = DefaultTabController.of(context);
                      final tabIndex = tabController?.index ?? 0;
                      String periodo = 'Diário';
                      List<Map<String, dynamic>> history = [];
                      if (tabIndex == 0) {
                        periodo = 'Diário';
                        history = await getUnifiedHistoryStream(
                                dailyEarningQuery, withdrawalHistoryQuery)
                            .first;
                      } else if (tabIndex == 1) {
                        periodo = 'Mensal';
                        history = await getUnifiedHistoryStream(
                                monthlyEarningQuery, withdrawalHistoryQuery)
                            .first;
                      } else {
                        periodo = 'Anual';
                        history = await getUnifiedHistoryStream(
                                yearlyEarningQuery, withdrawalHistoryQuery)
                            .first;
                      }
                      await generateAndDownloadPDF(history, periodo);
                    },
                    icon: Icon(
                      Icons.picture_as_pdf,
                      color: Colors.white,
                    ),
                    label: Text('Gerar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(COLOR_PRIMARY),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removido: buildTopUpButton

  // Removido: variáveis de métodos de pagamento para recarga

  // Removido: topUpBalance

  String? _ref;

  setRef() {
    Random numRef = Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      setState(() {
        _ref = "AndroidRef$year$refNumber";
      });
    } else if (Platform.isIOS) {
      setState(() {
        _ref = "IOSRef$year$refNumber";
      });
    }
  }

  // Removido: stripeMakePayment, displayStripePaymentSheet, createStripeIntent, calculateAmount

  // Adicionar método para buscar e unir os dois históricos
  Stream<List<Map<String, dynamic>>> getUnifiedHistoryStream(
      Stream<QuerySnapshot>? earningsQuery,
      Stream<QuerySnapshot>? withdrawalQuery) {
    return earningsQuery!.asyncMap((earningsSnap) async {
      final earnings = earningsSnap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['type'] = 'earning';
        data['createdAt'] = data['createdAt'] ?? data['paidDate'];
        return data;
      }).toList();
      final withdrawalSnap = await withdrawalQuery!.first;
      final withdrawals = withdrawalSnap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['type'] = 'withdrawal';
        data['createdAt'] = data['paidDate'];
        return data;
      }).toList();
      final all = [...earnings, ...withdrawals];
      all.sort((a, b) =>
          (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp));
      return all;
    });
  }

  tabController() {
    return Expanded(
      child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  height: 40,
                  child: TabBar(
                    indicatorColor: Color(COLOR_PRIMARY),
                    labelColor: Color(COLOR_PRIMARY),
                    automaticIndicatorColorAdjustment: true,
                    dragStartBehavior: DragStartBehavior.start,
                    unselectedLabelColor:
                        isDarkMode(context) ? Colors.white70 : Colors.black54,
                    indicatorWeight: 1.5,
                    enableFeedback: true,
                    tabs: [
                      Tab(text: 'Daily'.tr()),
                      Tab(text: 'Monthly'.tr()),
                      Tab(text: 'Yearly'.tr()),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: TabBarView(
                    children: [
                      showUnifiedHistory(
                          context, dailyEarningQuery, withdrawalHistoryQuery),
                      showUnifiedHistory(
                          context, monthlyEarningQuery, withdrawalHistoryQuery),
                      showUnifiedHistory(
                          context, yearlyEarningQuery, withdrawalHistoryQuery),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  // 5. Novo método showUnifiedHistory
  Widget showUnifiedHistory(
      BuildContext context,
      Stream<QuerySnapshot>? earningsQuery,
      Stream<QuerySnapshot>? withdrawalQuery) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getUnifiedHistoryStream(earningsQuery, withdrawalQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Transaction History'.tr()));
        }
        final history = snapshot.data!;
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            if (item['type'] == 'earning') {
              return buildEarningCard(orderModel: item);
            } else {
              return buildTransactionCard(
                withdrawHistory: WithdrawHistoryModel.fromJson(item),
                date: (item['createdAt'] as Timestamp).toDate(),
              );
            }
          },
        );
      },
    );
  }

  // 6. Remover buildEarningCard e showTransactionDetails relacionados a Trip Fee e bônus
  // Substituir buildEarningCard para mostrar apenas dados do pedido/ganho
  Widget buildEarningCard({required var orderModel}) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.monetization_on,
                  color: Color(COLOR_PRIMARY), size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order nr #${orderModel['orderNumber']?.toString() ?? '0'}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "Loja: ${orderModel['vendor']?['title']?.toString() ?? '-'}",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(
                          (orderModel['createdAt'] as Timestamp).toDate()),
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Text(
                '+ ${amountShow(amount: orderModel['deliveryCharge']?.toString() ?? '0')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppThemeData.green,
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showTransactionDetails({required orderModel}) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Text(
                    "Transaction Details".tr(),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Transaction ID".tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 10),
                              Opacity(
                                opacity: 0.8,
                                child: Text(
                                  orderModel.id,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 30),
                    child: Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Container(
                                color: Color(COLOR_PRIMARY).withOpacity(0.05),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                      Icons.account_balance_wallet_rounded,
                                      size: 28,
                                      color: Color(COLOR_PRIMARY)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.70,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.40,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Date in UTC Format".tr(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(orderModel.createdAt.toDate()).toUpperCase()}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Date in UTC Format".tr(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Opacity(
                                      opacity: 0.7,
                                      child: Text(
                                        "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(orderModel.createdAt.toDate()).toUpperCase()}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (MyAppState.currentUser!.serviceType ==
                                "cab-service") {
                              await FireStoreUtils.firestore
                                  .collection(RIDESORDER)
                                  .doc(orderModel.id)
                                  .get()
                                  .then((value) {
                                CabOrderModel orderModel =
                                    CabOrderModel.fromJson(value.data()!);
                                push(
                                    context,
                                    CabOrderDetailScreen(
                                        orderModel: orderModel));
                              });
                            } else if (MyAppState.currentUser!.serviceType ==
                                "parcel_delivery") {
                              await FireStoreUtils.firestore
                                  .collection(PARCELORDER)
                                  .doc(orderModel.id)
                                  .get()
                                  .then((value) {
                                ParcelOrderModel orderModel =
                                    ParcelOrderModel.fromJson(value.data()!);
                                push(
                                    context,
                                    ParcelOrderDetailScreen(
                                        orderModel: orderModel));
                              });
                            } else if (MyAppState.currentUser!.serviceType ==
                                "rental-service") {
                              await FireStoreUtils.firestore
                                  .collection(RENTALORDER)
                                  .doc(orderModel.id)
                                  .get()
                                  .then((value) {
                                RentalOrderModel orderModel =
                                    RentalOrderModel.fromJson(value.data()!);
                                push(
                                    context,
                                    RenatalSummaryScreen(
                                        rentalOrderModel: orderModel));
                              });
                            }
                          },
                          child: Text(
                            "View Order".tr().toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(COLOR_PRIMARY),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10)
              ],
            );
          });
        });
  }

  Widget showWithdrawalHistory(BuildContext context,
      {required Stream<QuerySnapshot>? query}) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'.tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
                  height: 35, width: 35, child: CircularProgressIndicator()));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
            "No Transaction History".tr(),
            style: TextStyle(fontSize: 18),
          ));
        } else {
          return ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final topUpData = WithdrawHistoryModel.fromJson(
                  document.data() as Map<String, dynamic>);
              return buildTransactionCard(
                withdrawHistory: topUpData,
                date: topUpData.paidDate.toDate(),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget buildTransactionCard(
      {required WithdrawHistoryModel withdrawHistory, required DateTime date}) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
      child: GestureDetector(
        onTap: () => showWithdrawalModelSheet(context, withdrawHistory),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Container(
                    color: Colors.green.withOpacity(0.06),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.account_balance_wallet_rounded,
                          size: 28, color: Color(0xFF82C100)),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: SizedBox(
                          width: size.width * 0.52,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${DateFormat('MMM dd, yyyy, KK:mma').format(withdrawHistory.paidDate.toDate()).toUpperCase()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(height: 10),
                              Opacity(
                                opacity: 0.75,
                                child: Text(
                                  withdrawHistory.paymentStatus,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: withdrawHistory.paymentStatus ==
                                            "Success"
                                        ? Colors.green
                                        : Colors.deepOrangeAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              " ${amountShow(amount: withdrawHistory.amount.toString())}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    withdrawHistory.paymentStatus == "Success"
                                        ? Colors.green
                                        : Colors.deepOrangeAccent,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 20),
                            Icon(Icons.arrow_forward_ios, size: 15)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Removido: paymentCompleted(paymentMethod: "RazorPay");
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text("Payment Processing Via".tr() + "\n" + response.walletName!),
      backgroundColor: Colors.blue.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Failed!!".tr() +
            "\n" +
            jsonDecode(response.message!)['error']['description'],
      ),
      backgroundColor: Colors.red.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  withdrawAmountBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppThemeData.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 5),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                      child: Text(
                        "Withdraw".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode(context)
                              ? Colors.white
                              : Color(DARK_COLOR),
                        ),
                      ),
                    ),
                    // NOVO: Escolha do método de saque
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Escolha o método de saque:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ListTile(
                            title: Text('M-Pesa'),
                            leading: Radio<WithdrawMethod>(
                              value: WithdrawMethod.mpesa,
                              groupValue: _selectedWithdrawMethod,
                              onChanged: (WithdrawMethod? value) {
                                setState(() {
                                  _selectedWithdrawMethod = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text('BIM'),
                            leading: Radio<WithdrawMethod>(
                              value: WithdrawMethod.bim,
                              groupValue: _selectedWithdrawMethod,
                              onChanged: (WithdrawMethod? value) {
                                setState(() {
                                  _selectedWithdrawMethod = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text('eMola'),
                            leading: Radio<WithdrawMethod>(
                              value: WithdrawMethod.emola,
                              groupValue: _selectedWithdrawMethod,
                              onChanged: (WithdrawMethod? value) {
                                setState(() {
                                  _selectedWithdrawMethod = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Opções de retirada permanecem iguais ao original
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 5),
                          child: RichText(
                            text: TextSpan(
                              text: "Amount to Withdraw".tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode(context)
                                    ? Colors.white70
                                    : Color(DARK_COLOR).withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Form(
                      key: _globalKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 8),
                          child: TextFormField(
                            controller: _amountController,
                            style: TextStyle(
                              color: Color(COLOR_PRIMARY_DARK),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "*required Field".tr();
                              } else {
                                if (double.parse(value) <= 0) {
                                  return "*Invalid Amount".tr();
                                } else if (double.parse(value) >
                                    double.parse(MyAppState
                                        .currentUser!.earningsBalance
                                        .toString())) {
                                  return "*withdraw is more then earnings balance"
                                      .tr();
                                } else {
                                  return null;
                                }
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefix: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 2),
                                child: Text(
                                  "${currencyData!.symbol}",
                                  style: TextStyle(
                                    color: isDarkMode(context)
                                        ? Colors.white
                                        : Color(DARK_COLOR),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              fillColor: Colors.grey[200],
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                      color: Color(COLOR_PRIMARY),
                                      width: 1.50)),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: buildButton(context, title: "WITHDRAW".tr(),
                          onPress: () {
                        if (_globalKey.currentState!.validate()) {
                          if (double.parse(minimumAmountToWithdrawal) >
                              double.parse(_amountController.text)) {
                            showAlertDialog(
                                context,
                                "Failed!".tr(),
                                '${"Withdraw amount must be greater or equal to".tr()} ${amountShow(amount: minimumAmountToWithdrawal)}'
                                    .tr(),
                                true);
                          } else {
                            // NOVO: Chamar método de saque conforme selecionado
                            _simulateWithdraw(context);
                          }
                        }
                      }),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  withdrawRequest() {
    Navigator.pop(context);
    showLoadingAlert();
    FireStoreUtils.createPaymentId(collectionName: driverPayouts).then((value) {
      final paymentID = value;

      WithdrawHistoryModel withdrawHistory = WithdrawHistoryModel(
        amount: double.parse(_amountController.text),
        driverId: userId,
        paymentStatus: "Pending",
        paidDate: Timestamp.now(),
        id: paymentID.toString(),
        role: 'driver',
        note: _noteController.text,
        withdrawMethod: selectedValue == 0 ? "bank" : "other",
        vendorID: '',
      );

      FireStoreUtils.withdrawWalletAmount(withdrawHistory: withdrawHistory)
          .then((value) {
        FireStoreUtils.updateEarningsBalance(
                userId: userId, amount: -double.parse(_amountController.text))
            .whenComplete(() {
          Navigator.pop(_scaffoldKey.currentContext!);
          FireStoreUtils.sendPayoutMail(
              amount: _amountController.text,
              payoutrequestid: paymentID.toString());
          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text("Payment Successful!! \n".tr()),
            backgroundColor: Colors.green,
          ));
        });
      });
    });
  }

  withdrawalHistoryBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        backgroundColor: AppThemeData.grey50,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 55),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: showWithdrawalHistory(context,
                      query: withdrawalHistoryQuery),
                ),
              ],
            );
          });
        });
  }

  buildButton(context,
      {required String title,
      double width = 0.9,
      required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * width,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Color(0xFF82C100),
        height: 45,
        elevation: 0.0,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  buildTransButton(context,
      {required String title,
      double width = 0.9,
      required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * width,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF82C100), width: 1),
            borderRadius: BorderRadius.circular(6)),
        color: Colors.transparent,
        height: 45,
        elevation: 0.0,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontSize: 15, color: Color(0xFF82C100)),
        ),
      ),
    );
  }

  showLoadingAlert() {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
              Text('Please wait!!'.tr()),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(height: 15),
                Text(
                  'Please wait!! while completing Transaction'.tr(),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> generateAndDownloadPDF(
      List<Map<String, dynamic>> history, String periodo) async {
    // // final pdf = pw.Document();
    // // Dados do usuário
    // final user = MyAppState.currentUser;
    // final userName = "${user?.firstName ?? ''} ${user?.lastName ?? ''}";
    // final userEmail = user?.email ?? '';
    // final userPhone = user?.phoneNumber ?? '';

    // pdf.addPage(
    //   pw.MultiPage(
    //     build: (context) => [
    //       // Cabeçalho com dados do usuário
    //       pw.Header(
    //         level: 0,
    //         child: pw.Column(
    //           crossAxisAlignment: pw.CrossAxisAlignment.start,
    //           children: [
    //             pw.Text('Histórico $periodo',
    //                 style: pw.TextStyle(
    //                     fontSize: 22, fontWeight: pw.FontWeight.bold)),
    //             pw.SizedBox(height: 8),
    //             pw.Text('Usuário: $userName'),
    //             pw.Text('E-mail: $userEmail'),
    //             pw.Text('Telefone: $userPhone'),
    //             pw.Divider(),
    //           ],
    //         ),
    //       ),
    //       // Tabela de transações
    //       pw.Table.fromTextArray(
    //         headers: ['Data', 'Valor', 'Loja', 'Tipo'],
    //         data: history.map((item) {
    //           final isEarning = item['type'] == 'earning';
    //           return [
    //             item['createdAt'] != null
    //                 ? (item['createdAt'] as Timestamp).toDate().toString()
    //                 : '',
    //             isEarning
    //                 ? '+${item['deliveryCharge'] ?? item['driverAmount'] ?? ''}'
    //                 : '-${item['amount'] ?? ''}',
    //             isEarning ? (item['vendor']?['title']?.toString() ?? '-') : '-',
    //             isEarning ? 'Ganho' : 'Saque',
    //           ];
    //         }).toList(),
    //       ),
    //     ],
    //   ),
    // );

    // Exibe o diálogo de impressão/download
    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    //   name: 'historico_$periodo.pdf',
    // );
  }

// NOVO: Função para simular saque conforme método
  void _simulateWithdraw(BuildContext context) async {
    if (_selectedWithdrawMethod == WithdrawMethod.mpesa) {
      Navigator.pop(context); // Fecha o modal
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MpesaWithdrawScreen()),
      );
      return;
    }
    Navigator.pop(context); // Fecha o modal
    showLoadingAlert();
    await Future.delayed(Duration(seconds: 2)); // Simula processamento
    if (_selectedWithdrawMethod == WithdrawMethod.bim) {
      Navigator.pop(_scaffoldKey.currentContext!);
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Saque BIM simulado com sucesso!')),
      );
    } else if (_selectedWithdrawMethod == WithdrawMethod.emola) {
      Navigator.pop(_scaffoldKey.currentContext!);
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Saque eMola simulado com sucesso!')),
      );
    }
  }

  // Restaurar o método getData
  getData() async {
    try {
      userQuery = fireStore.collection(USERS).doc(userId).snapshots();
    } catch (e) {
      print(e);
    }

    withdrawalHistoryQuery = fireStore
        .collection(driverPayouts)
        .where('driverID', isEqualTo: userId)
        .orderBy('paidDate', descending: true)
        .snapshots();

    DateTime nowDate = DateTime.now();

    if (MyAppState.currentUser!.serviceType == "cab-service") {
      dailyEarningQuery = fireStore
          .collection(RIDESORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(nowDate.year, nowDate.month, nowDate.day)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      monthlyEarningQuery = fireStore
          .collection(RIDESORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(nowDate.year, nowDate.month)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      yearlyEarningQuery = fireStore
          .collection(RIDESORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(nowDate.year)))
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else if (MyAppState.currentUser!.serviceType == "parcel_delivery") {
      dailyEarningQuery = fireStore
          .collection(PARCELORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(nowDate.year, nowDate.month, nowDate.day)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      monthlyEarningQuery = fireStore
          .collection(PARCELORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(nowDate.year, nowDate.month)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      yearlyEarningQuery = fireStore
          .collection(PARCELORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(nowDate.year)))
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else if (MyAppState.currentUser!.serviceType == "rental-service") {
      dailyEarningQuery = fireStore
          .collection(RENTALORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(nowDate.year, nowDate.month, nowDate.day)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      monthlyEarningQuery = fireStore
          .collection(RENTALORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(nowDate.year, nowDate.month)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      yearlyEarningQuery = fireStore
          .collection(RENTALORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(nowDate.year)))
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      dailyEarningQuery = fireStore
          .collection(ORDERS)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(nowDate.year, nowDate.month, nowDate.day)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      monthlyEarningQuery = fireStore
          .collection(ORDERS)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(nowDate.year, nowDate.month)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      yearlyEarningQuery = fireStore
          .collection(ORDERS)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(nowDate.year)))
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }
}
