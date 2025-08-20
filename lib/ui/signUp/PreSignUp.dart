import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:easy_localization/easy_localization.dart' as Easy;

import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/SectionModel.dart';
import 'package:emartdriver/model/VehicleMake.dart';
import 'package:emartdriver/model/VehicleModel.dart';
import 'package:emartdriver/model/VehicleTypeModel.dart';

import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';

import 'package:emartdriver/ui/signUp/SignUpScreen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:emartdriver/theme/app_them_data.dart';

import 'package:emartdriver/ui/signUp/FirstStepsScreen.dart';
import 'package:emartdriver/repositories/vehicle_type_repository.dart';
import 'package:emartdriver/repositories/vehicle_make_repository.dart';
import 'package:emartdriver/repositories/section_repository.dart';

class PreSignUpScreen extends StatefulWidget {
  final bool waiting;

  const PreSignUpScreen({Key? key, this.waiting = false}) : super(key: key);

  @override
  _PreSignUpScreenState createState() => _PreSignUpScreenState();
}

class _PreSignUpScreenState extends State<PreSignUpScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _carMakeController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  final GlobalKey<FormState> _deliveryKey = GlobalKey();

  bool isUserImage = true;
  AutovalidateMode _validate = AutovalidateMode.disabled;
  bool _codeSent = false;
  String _verificationID = "";
  bool _isInitialized = false;

  File? _image;
  File? _carImage;
  File? _carProofPictureFile;
  File? _driverProofPictureURLFile;

  final List<String> _locations = [
    'Delivery service',
    'Cab service',
    'Parcel service',
    'Rental Service'
  ];
  String? _selectedServiceType;

  List<VehicleTypeModel> vehiclesList = [];
  List<VehicleMake> carMakesList = [];
  List<VehicleModel> carModelList = [];

  VehicleMake? selectedCarMakes;
  VehicleModel? selectedCarModel;
  VehicleTypeModel? selectedVehicle;
  List<VehicleTypeModel> vehicleType = [];
  List<VehicleTypeModel> rentalVehicleType = [];
  VehicleTypeModel? selectedRentalVehicleType;
  VehicleTypeModel? selectedVehicleType;

  List<SectionModel>? sectionsVal = [];
  SectionModel? selectedSection;

  bool _consentChecked = false;

  @override
  void initState() {
    super.initState();
    getCarMakes();
    getVehicles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && Platform.isAndroid) {
      _isInitialized = true;
    }
  }

  getVehicles() async {
    await VehicleTypeRepository.getVehicleTypes().then((value) {
      if (mounted) {
        setState(() {
          vehiclesList = value;
        });
      }
    });
  }

  getCarMakes() async {
    await VehicleMakeRepository.getVehicleMakes().then((value) {
      if (mounted) {
        setState(() {
          carMakesList = value;
        });
      }
    });

    await FireStoreUtils.getRentalVehicleType().then((value) {
      if (mounted) {
        setState(() {
          rentalVehicleType = value;
        });
      }
    });

    await SectionRepository.getSections().then((value) {
      if (mounted) {
        setState(() {
          sectionsVal = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.20),
          Container(
            height: MediaQuery.of(context).size.height * 0.80,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppThemeData.lightgrey.withOpacity(0.7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: Color(COLOR_PRIMARY),
                    ),
                    SizedBox(height: 32),
                    Text(
                      widget.waiting
                          ? 'We have your data'.tr()
                          : 'We received your data'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppThemeData.black,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      widget.waiting
                          ? 'Now, we will need a few more pieces of information to activate your account.'
                              .tr()
                          : 'Now, we will need a few more pieces of information to activate your account'
                              .tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppThemeData.black,
                      ),
                    ),
                    SizedBox(height: 48),
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(COLOR_PRIMARY),
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Continue'.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode(context)
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeData.newBlack,
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Continue later'.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode(context)
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FirstStepsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // _image = null;
    // _carImage = null;
    super.dispose();
  }
}
