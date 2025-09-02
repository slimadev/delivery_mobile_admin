import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/model/AddressModel.dart';

import 'package:emartdriver/model/OrderModel.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String rideType;
  String email;
  String firstName;
  String lastName;
  UserSettings settings;
  String phoneNumber;
  bool active;
  bool isActive;
  bool isReady;
  Timestamp lastOnlineTimestamp;
  String userID;
  String profilePictureURL;
  String carProofPictureURL;
  String driverProofPictureURL;
  String criminalRecordPictureURL;
  String nuitPictureURL;
  String appIdentifier;
  String fcmToken;
  String authToken; // Token de autenticação da API
  UserLocation location;
  List<AddressModel>? shippingAddress = [];
  String role;
  String carName;
  String carNumber;
  String carColor;
  String carPictureURL;
  String? inProgressOrderID;
  OrderModel? orderRequestData;

  UserBankDetails userBankDetails;
  GeoFireData geoFireData;
  GeoPoint coordinates;
  String serviceType;
  String vehicleType;
  String vehicleId;
  String carMakes;
  num walletAmount;
  num rechargeBalance;
  num earningsBalance;
  List<WalletTransaction> rechargeHistory;
  List<WalletTransaction> earningsHistory;
  num? rotation;
  num reviewsCount;
  num reviewsSum;
  String driverRate;
  String carRate;
  String criminalRecordStatus;
  String nuitStatus;
  String carProofStatus;
  String driverProofStatus;
  String profilePictureStatus;
  String? sectionId;
  CarInfo? carInfo;
  List<dynamic>? rentalBookingDate;
  Timestamp? createdAt;
  int? completedTrips;
  bool consentCheck;
  String? deleteReason;
  String? deletedAt;
  String carProofRejectionReason;
  String profilePictureRejectionReason;
  String driverProofRejectionReason;
  String criminalRecordRejectionReason;
  String nuitRejectionReason;
  // String vehicleProfileImageUrl;
  String carPictureStatus;
  String carPictureRejectionReason;

  User({
    this.email = '',
    this.rideType = '',
    this.userID = '',
    this.profilePictureURL = '',
    this.carProofPictureURL = '',
    this.driverProofPictureURL = '',
    this.criminalRecordPictureURL = '',
    this.nuitPictureURL = '',
    this.firstName = '',
    this.phoneNumber = '',
    this.lastName = '',
    this.active = false,
    this.isActive = false,
    this.isReady = false,
    lastOnlineTimestamp,
    settings,
    this.fcmToken = '',
    this.authToken = '',
    location,
    this.shippingAddress,
    this.role = USER_ROLE_DRIVER,
    this.carName = 'Uber Car',
    this.carNumber = 'No Plates',
    this.carColor = '',
    this.carPictureURL = DEFAULT_CAR_IMAGE,
    this.inProgressOrderID,
    this.rechargeBalance = 0.0,
    this.earningsBalance = 0.0,
    this.rechargeHistory = const [],
    this.earningsHistory = const [],
    this.walletAmount = 0.0,
    this.serviceType = "",
    this.vehicleType = "",
    this.vehicleId = "",
    this.carMakes = "",
    this.rotation,
    this.rentalBookingDate,
    this.reviewsCount = 0,
    this.reviewsSum = 0,
    this.driverRate = "0",
    this.carRate = "0",
    this.criminalRecordStatus = 'Pendente',
    this.nuitStatus = 'Pendente',
    this.carProofStatus = 'Pendente',
    this.driverProofStatus = 'Pendente',
    this.profilePictureStatus = 'Pendente',
    userBankDetails,
    geoFireData,
    coordinates,
    carInfo,
    this.orderRequestData,
    this.createdAt,
    this.sectionId,
    this.completedTrips = 0,
    this.consentCheck = false,
    this.deleteReason,
    this.deletedAt,
    this.carProofRejectionReason = '',
    this.profilePictureRejectionReason = '',
    this.driverProofRejectionReason = '',
    this.criminalRecordRejectionReason = '',
    this.nuitRejectionReason = '',
    // this.vehicleProfileImageUrl = '',
    this.carPictureStatus = '',
    this.carPictureRejectionReason = '',
  })  : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.settings = settings ?? UserSettings(),
        this.appIdentifier = 'eMart Driver ${Platform.operatingSystem}',
        this.userBankDetails = userBankDetails ?? UserBankDetails(),
        this.location = location ?? UserLocation(),
        this.coordinates = coordinates ?? GeoPoint(0.0, 0.0),
        this.carInfo = carInfo ?? CarInfo(),
        this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );

  String fullName() {
    return '$firstName $lastName';
  }

  // Getter para saldo total (recarga + ganhos)
  num get totalBalance => rechargeBalance + earningsBalance;

  // Método para adicionar recarga
  void addRecharge(double amount, String paymentMethod) {
    rechargeBalance += amount;
    rechargeHistory.add(WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'recharge',
      date: DateTime.now(),
      status: 'completed',
      description: 'Recarga da carteira',
      paymentMethod: paymentMethod,
    ));
  }

  // Método para adicionar ganhos
  void addEarnings(double amount, String description) {
    earningsBalance += amount;
    earningsHistory.add(WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'earnings',
      date: DateTime.now(),
      status: 'completed',
      description: description,
    ));
  }

  // Método para levantar dinheiro (apenas da carteira de ganhos)
  bool withdrawEarnings(double amount) {
    if (earningsBalance >= amount) {
      earningsBalance -= amount;
      earningsHistory.add(WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: -amount,
        type: 'withdrawal',
        date: DateTime.now(),
        status: 'completed',
        description: 'Levantamento de ganhos',
      ));
      return true;
    }
    return false;
  }

  // Método para verificar se pode levantar
  bool canWithdraw(double amount) {
    return earningsBalance >= amount;
  }

  // Método para obter saldo disponível para levantamento
  num get withdrawableBalance => earningsBalance;

  // String firstName() {
  //   return '$firstName';
  // }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    print('DEBUG: parsedJson[active]: ${parsedJson['active']}');
    print('DEBUG: parsedJson[isActive]: ${parsedJson['isActive']}');

    // Função auxiliar para padronizar status para inglês
    String normalizeStatus(dynamic status) {
      if (status == null) return 'Pending';
      switch (status.toString().toLowerCase()) {
        case 'aprovado':
          return 'Approved';
        case 'pendente':
          return 'Pending';
        case 'em análise':
        case 'em analise':
          return 'Under review';
        case 'rejeitado':
          return 'Rejected';
        case 'approved':
          return 'Approved';
        case 'pending':
          return 'Pending';
        case 'under review':
          return 'Under review';
        case 'rejected':
          return 'Rejected';
        default:
          return status.toString();
      }
    }

    List<AddressModel>? shippingAddressList = [];
    if (parsedJson['shippingAddress'] != null) {
      shippingAddressList = <AddressModel>[];
      parsedJson['shippingAddress'].forEach((v) {
        shippingAddressList!.add(AddressModel.fromJson(v));
      });
    }

    // Converter histórico de transações
    List<WalletTransaction> rechargeHistoryList = [];
    if (parsedJson['rechargeHistory'] != null) {
      rechargeHistoryList = <WalletTransaction>[];
      parsedJson['rechargeHistory'].forEach((v) {
        rechargeHistoryList.add(WalletTransaction.fromJson(v));
      });
    }

    List<WalletTransaction> earningsHistoryList = [];
    if (parsedJson['earningsHistory'] != null) {
      earningsHistoryList = <WalletTransaction>[];
      parsedJson['earningsHistory'].forEach((v) {
        earningsHistoryList.add(WalletTransaction.fromJson(v));
      });
    }

    return User(
      email: parsedJson['email'] ?? '',
      rideType: parsedJson['rideType'] ?? '',
      rechargeBalance: parsedJson['recharge_balance'] ?? 0.0,
      earningsBalance: parsedJson['earnings_balance'] ?? 0.0,
      rechargeHistory: rechargeHistoryList,
      earningsHistory: earningsHistoryList,
      userBankDetails: parsedJson.containsKey('userBankDetails')
          ? UserBankDetails.fromJson(parsedJson['userBankDetails'])
          : UserBankDetails(),
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      geoFireData: parsedJson.containsKey('g')
          ? GeoFireData.fromJson(parsedJson['g'])
          : GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            ),
      coordinates: parsedJson['coordinates'] ?? GeoPoint(0.0, 0.0),
      isActive: parsedJson['isActive'] ?? false,
      isReady: parsedJson['isReady'] ?? false,
      rotation: parsedJson['rotation'] ?? 0.0,
      active: parsedJson['active'] ?? true,
      vehicleType: parsedJson['vehicleType'] ?? '',
      vehicleId: parsedJson['vehicleId'] ?? '',
      carMakes: parsedJson['carMakes'] ?? '',
      lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
      settings: parsedJson.containsKey('settings')
          ? UserSettings.fromJson(parsedJson['settings'])
          : UserSettings(),
      phoneNumber: parsedJson['phoneNumber'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      profilePictureURL: parsedJson['profilePictureURL'] ?? '',
      driverProofPictureURL: parsedJson['driverProofPictureURL'] ?? '',
      carProofPictureURL: parsedJson['carProofPictureURL'] ?? '',
      criminalRecordPictureURL: parsedJson['criminalRecordPictureURL'] ?? '',
      nuitPictureURL: parsedJson['nuitPictureURL'] ?? '',
      criminalRecordStatus: normalizeStatus(parsedJson['criminalRecordStatus']),
      nuitStatus: normalizeStatus(parsedJson['nuitStatus']),
      carProofStatus: normalizeStatus(parsedJson['carProofStatus']),
      driverProofStatus: normalizeStatus(parsedJson['driverProofStatus']),
      profilePictureStatus: normalizeStatus(parsedJson['profilePictureStatus']),
      fcmToken: parsedJson['fcmToken'] ?? '',
      serviceType: parsedJson['serviceType'] ?? '',
      driverRate: parsedJson['driverRate'] ?? '0',
      carRate: parsedJson['carRate'] ?? '0',
      rentalBookingDate: parsedJson['rentalBookingDate'] ?? [],
      carInfo: parsedJson.containsKey('carInfo')
          ? CarInfo.fromJson(parsedJson['carInfo'])
          : CarInfo(),
      location: parsedJson.containsKey('location')
          ? UserLocation.fromJson(parsedJson['location'])
          : UserLocation(),
      shippingAddress: shippingAddressList,
      role: parsedJson['role'] ?? '',
      carName: parsedJson['carName'] ?? '',
      carNumber: parsedJson['carNumber'] ?? '',
      carColor: parsedJson['carColor'] ?? '',
      carPictureURL: parsedJson['carPictureURL'] ?? '',
      inProgressOrderID: parsedJson['inProgressOrderID'],
      reviewsCount: parsedJson['reviewsCount'] ?? 0,
      reviewsSum: parsedJson['reviewsSum'] ?? 0,
      sectionId: parsedJson['sectionId'] ?? '',
      createdAt: parsedJson['createdAt'],
      completedTrips: parsedJson['completedTrips'] as int? ?? 0,
      orderRequestData: parsedJson.containsKey('orderRequestData') &&
              parsedJson['orderRequestData'] != null
          ? OrderModel.fromJson(parsedJson['orderRequestData'])
          : null,

      carProofRejectionReason: parsedJson['carProofRejectionReason'] ?? '',
      profilePictureRejectionReason:
          parsedJson['profilePictureRejectionReason'] ?? '',
      driverProofRejectionReason:
          parsedJson['driverProofRejectionReason'] ?? '',
      criminalRecordRejectionReason:
          parsedJson['criminalRecordRejectionReason'] ?? '',
      nuitRejectionReason: parsedJson['nuitRejectionReason'] ?? '',
      // vehicleProfileImageUrl: parsedJson['vehicleProfileImageUrl'] ?? '',
      carPictureStatus: parsedJson['carPictureStatus'] ?? '',
      carPictureRejectionReason: parsedJson['carPictureRejectionReason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'recharge_balance': this.rechargeBalance,
      'earnings_balance': this.earningsBalance,
      'rechargeHistory': this.rechargeHistory.map((v) => v.toJson()).toList(),
      'earningsHistory': this.earningsHistory.map((v) => v.toJson()).toList(),
      "userBankDetails": this.userBankDetails.toJson(),
      'id': this.userID,
      'isActive': this.isActive,
      'active': this.active,
      'isReady': this.isReady,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'shippingAddress': shippingAddress != null
          ? shippingAddress!.map((v) => v.toJson()).toList()
          : null,
      'role': this.role,
      "g": this.geoFireData.toJson(),
      'coordinates': this.coordinates,
      'createdAt': this.createdAt,
      'completedTrips': this.completedTrips,
      'criminalRecordPictureURL': this.criminalRecordPictureURL,
      'nuitPictureURL': this.nuitPictureURL,
      'criminalRecordStatus': this.criminalRecordStatus,
      'nuitStatus': this.nuitStatus,
      'carProofStatus': this.carProofStatus,
      'driverProofStatus': this.driverProofStatus,
      'carProofRejectionReason': this.carProofRejectionReason,
      'profilePictureRejectionReason': this.profilePictureRejectionReason,
      'driverProofRejectionReason': this.driverProofRejectionReason,
      'criminalRecordRejectionReason': this.criminalRecordRejectionReason,
      'nuitRejectionReason': this.nuitRejectionReason,
      // 'vehicleProfileImageUrl': this.vehicleProfileImageUrl,
      'carPictureStatus': this.carPictureStatus,
      'carPictureRejectionReason': this.carPictureRejectionReason,
      // Campos para soft delete e auditoria
      'deletedAt': this.deletedAt,
      'deleteReason': this.deleteReason,
    };
    if (this.role == USER_ROLE_DRIVER) {
      json.addAll({
        'rideType': this.rideType,
        'role': this.role,
        'carName': this.carName,
        'carNumber': this.carNumber,
        'carColor': this.carColor,
        'carPictureURL': this.carPictureURL,
        'vehicleType': this.vehicleType,
        'vehicleId': this.vehicleId,
        'carMakes': this.carMakes,
        'rotation': this.rotation,
        'reviewsCount': this.reviewsCount,
        'reviewsSum': this.reviewsSum,
        'serviceType': this.serviceType,
        'driverRate': this.driverRate,
        'carRate': this.carRate,
        'carInfo': this.carInfo!.toJson(),
        'rentalBookingDate': this.rentalBookingDate,
        'driverProofPictureURL': this.driverProofPictureURL,
        'carProofPictureURL': this.carProofPictureURL,
        'sectionId': this.sectionId,
        if (orderRequestData != null)
          'orderRequestData': orderRequestData!.toJson(),
      });
    }
    if (this.inProgressOrderID != null) {
      json.addAll({'inProgressOrderID': this.inProgressOrderID});
    }
    return json;
  }

  // ... resto do código (toPayload, fullName, etc.) permanece igual ...
}

class UserSettings {
  bool pushNewMessages;

  bool orderUpdates;

  bool newArrivals;

  bool promotions;

  UserSettings(
      {this.pushNewMessages = true,
      this.orderUpdates = true,
      this.newArrivals = true,
      this.promotions = true});

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserSettings(
      pushNewMessages: parsedJson['pushNewMessages'] ?? true,
      orderUpdates: parsedJson['orderUpdates'] ?? true,
      newArrivals: parsedJson['newArrivals'] ?? true,
      promotions: parsedJson['promotions'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNewMessages': this.pushNewMessages,
      'orderUpdates': this.orderUpdates,
      'newArrivals': this.newArrivals,
      'promotions': this.promotions,
    };
  }
}

class UserLocation {
  double latitude;

  double longitude;

  UserLocation({this.latitude = 0.01, this.longitude = 0.01});

  factory UserLocation.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserLocation(
      latitude: parsedJson['latitude'] ?? 00.1,
      longitude: parsedJson['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
    };
  }
}

class GeoFireData {
  String? geohash;
  GeoPoint? geoPoint;

  GeoFireData({this.geohash, this.geoPoint});

  factory GeoFireData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeoFireData(
      geohash: parsedJson['geohash'] ?? '',
      geoPoint: parsedJson['geopoint'] ?? GeoPoint(0.0, 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': this.geohash,
      'geopoint': this.geoPoint,
    };
  }
}

class UserBankDetails {
  String bankName;

  String branchName;

  String holderName;

  String accountNumber;

  String otherDetails;

  UserBankDetails({
    this.bankName = '',
    this.otherDetails = '',
    this.branchName = '',
    this.accountNumber = '',
    this.holderName = '',
  });

  factory UserBankDetails.fromJson(Map<String, dynamic> parsedJson) {
    return UserBankDetails(
      bankName: parsedJson['bankName'] ?? '',
      branchName: parsedJson['branchName'] ?? '',
      holderName: parsedJson['holderName'] ?? '',
      accountNumber: parsedJson['accountNumber'] ?? '',
      otherDetails: parsedJson['otherDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': this.bankName,
      'branchName': this.branchName,
      'holderName': this.holderName,
      'accountNumber': this.accountNumber,
      'otherDetails': this.otherDetails,
    };
  }
}

class CarInfo {
  String? passenger;
  String? doors;
  String? carName;
  String? airConditioning;
  String? gear;
  String? mileage;
  String? fuelFilling;
  String? fuelType;
  String? maxPower;
  String? mph;
  String? topSpeed;
  List<dynamic>? carImage;

  CarInfo({
    this.passenger,
    this.doors,
    this.carName,
    this.airConditioning,
    this.gear,
    this.mileage,
    this.fuelFilling,
    this.fuelType,
    this.carImage,
    this.maxPower,
    this.mph,
    this.topSpeed,
  });

  CarInfo.fromJson(Map<String, dynamic> json) {
    passenger = json['passenger'] ?? "";
    doors = json['doors'] ?? "";
    carName = json['carName'] ?? "";
    airConditioning = json['air_conditioning'] ?? "";
    gear = json['gear'] ?? "";
    mileage = json['mileage'] ?? "";
    fuelFilling = json['fuel_filling'] ?? "";
    fuelType = json['fuel_type'] ?? "";
    carImage = json['car_image'] ?? [];
    maxPower = json['maxPower'] ?? "";
    mph = json['mph'] ?? "";
    topSpeed = json['topSpeed'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['passenger'] = this.passenger;
    data['doors'] = this.doors;
    data['carName'] = this.carName;
    data['air_conditioning'] = this.airConditioning;
    data['gear'] = this.gear;
    data['mileage'] = this.mileage;
    data['fuel_filling'] = this.fuelFilling;
    data['fuel_type'] = this.fuelType;
    data['car_image'] = this.carImage;
    data['maxPower'] = this.maxPower;
    data['mph'] = this.mph;
    data['topSpeed'] = this.topSpeed;
    return data;
  }
}

// Classe para transações da carteira
class WalletTransaction {
  String id;
  double amount;
  String type; // 'recharge', 'withdrawal', 'earnings'
  DateTime date;
  String status;
  String? description;
  String? paymentMethod;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.status,
    this.description,
    this.paymentMethod,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: json['type'] ?? '',
      date: json['date'] != null
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      status: json['status'] ?? '',
      description: json['description'],
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'amount': this.amount,
      'type': this.type,
      'date': Timestamp.fromDate(this.date),
      'status': this.status,
      'description': this.description,
      'paymentMethod': this.paymentMethod,
    };
  }
}
