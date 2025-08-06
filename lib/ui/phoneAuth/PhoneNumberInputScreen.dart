import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:easy_localization/easy_localization.dart' as Easy;
import 'package:emartdriver/CabService/dashboard_cab_service.dart';
import 'package:emartdriver/Parcel_service/parcel_service_dashboard.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/CarMakes.dart';
import 'package:emartdriver/model/CarModel.dart';
import 'package:emartdriver/model/SectionModel.dart';
import 'package:emartdriver/model/VehicleType.dart';
import 'package:emartdriver/rental_service/rental_service_dashboard.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/services/show_toast_dialog.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:emartdriver/ui/signUp/PreSignUp.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/termsAndCondition/terms_and_codition.dart';
import 'package:emartdriver/ui/privacy_policy/privacy_policy.dart';
import 'package:flutter/gestures.dart';

import '../../model/User.dart';
import '../../model/Vehicle_Types.dart';

File? _image;
File? _carImage;

class PhoneNumberInputScreen extends StatefulWidget {
  final bool login;

  const PhoneNumberInputScreen({Key? key, required this.login})
      : super(key: key);

  @override
  _PhoneNumberInputScreenState createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _carNameController = TextEditingController();
  TextEditingController _carMakeController = TextEditingController();
  TextEditingController _carPlateController = TextEditingController();
  TextEditingController _carColorController = TextEditingController();
  TextEditingController _vehicleController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  GlobalKey<FormState> _deliveryKey = GlobalKey();
  GlobalKey<FormState> _cabServiceKey = GlobalKey();
  GlobalKey<FormState> _parcelServiceKey = GlobalKey();
  GlobalKey<FormState> _rentalServiceKey = GlobalKey();
  bool isUserImage = true;
  bool _consentChecked = false;
  bool _termsAccepted = false;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  // TextEditingController _companyNameController = TextEditingController();
  // TextEditingController _companyAddressController = TextEditingController();

  List<String> _locations = [
    'Delivery service',
    'Cab service',
    'Parcel service',
    'Rental Service'
  ]; // Option 2
  String? _selectedServiceType;

  @override
  void initState() {
    getCarMakes();
    getVehicles();
    super.initState();
  } // Option 2

  List<VehicleTypes> vehiclesList = [];
  List<CarMakes> carMakesList = [];
  List<CarModel> carModelList = [];

  CarMakes? selectedCarMakes;
  CarModel? selectedCarModel;
  VehicleTypes? selectedVehicle;
  List<VehicleType> vehicleType = [];
  List<VehicleType> rentalVehicleType = [];
  VehicleType? selectedRentalVehicleType;
  VehicleType? selectedVehicleType;

  List<SectionModel>? sectionsVal = [];
  SectionModel? selectedSection;

  getVehicles() async {
    await FireStoreUtils.getVehicles().then((value) {
      setState(() {
        vehiclesList = value;
      });
    });
  }

  getCarMakes() async {
    await FireStoreUtils.getCarMakes().then((value) {
      setState(() {
        carMakesList = value;
      });
    });

    // await FireStoreUtils.getVehicleType().then((value) {
    //   setState(() {
    //     vehicleType = value;
    //   });
    // });

    await FireStoreUtils.getRentalVehicleType().then((value) {
      setState(() {
        rentalVehicleType = value;
      });
    });

    await FireStoreUtils.getSections().then((value) {
      setState(() {
        sectionsVal = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      retrieveLostData();
    }
    return Scaffold(
      appBar: (!widget.login)
          ? null // Não mostra AppBar se não enviou código
          : AppBar(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ),
      body: SingleChildScrollView(
        child: Container(
          // decoration: BoxDecoration(
          //   color: AppThemeData.lightgrey.withOpacity(0.7),
          //   borderRadius: BorderRadius.circular(25.0),
          // ),
          margin: EdgeInsets.only(left: 24.0, right: 16, bottom: 24),
          child: Column(
            children: [
              SizedBox(height: 40),
              if (widget.login) ...[
                !_codeSent
                    ? Column(
                        children: [
                          Container(
                            height: 280,
                            width: double.infinity,
                            child: Image.asset(
                              'assets/images/delivery1.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppThemeData.lightgrey.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 16.0, right: 8.0, left: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4.0, bottom: 8.0),
                                        child: Text(
                                          'Enter your phone number'.tr(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppThemeData.newBlack,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            shape: BoxShape.rectangle,
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.grey.shade200)),
                                        child: InternationalPhoneNumberInput(
                                          onInputChanged:
                                              (PhoneNumber number) =>
                                                  _mobileController.text =
                                                      number.phoneNumber
                                                          .toString(),
                                          ignoreBlank: true,
                                          autoValidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          inputDecoration: InputDecoration(
                                            hintText: 'Phone Number'.tr(),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            isDense: true,
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          inputBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          selectorConfig: SelectorConfig(
                                              selectorType:
                                                  PhoneInputSelectorType
                                                      .DIALOG),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 40.0,
                                      left: 40.0,
                                      top: 40.0,
                                      bottom: 40),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        minWidth: double.infinity),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(COLOR_PRIMARY),
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Login'.tr(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode(context)
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                      onPressed: () => _signUp(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    : Container(),
              ] else ...[
                if (!_codeSent)
                  Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: Form(
                        key: _deliveryKey,
                        autovalidateMode: _validate,
                        child: formUI(),
                      ),
                    ),
                  ),
                if (!_codeSent)
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 24.0, left: 24.0, top: 16.0),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeData.newBlack,
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            // side: BorderSide(
                            //   color: Color(COLOR_PRIMARY),
                            // ),
                          ),
                        ),
                        child: Text(
                          'Already have an Account'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode(context)
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PhoneNumberInputScreen(login: true)),
                          );
                        },
                      ),
                    ),
                  ),
              ],
              if (_codeSent) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Enter verification code'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(COLOR_PRIMARY),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'We have sent a 6-digit verification code to your phone number'
                                .tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Please enter the code below to verify your phone number'
                                .tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          PinCodeTextField(
                            length: 6,
                            appContext: context,
                            keyboardType: TextInputType.phone,
                            backgroundColor: Colors.transparent,
                            pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 40,
                                fieldWidth: 40,
                                activeColor: Color(COLOR_PRIMARY),
                                activeFillColor: isDarkMode(context)
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                                selectedFillColor: Colors.transparent,
                                selectedColor: Color(COLOR_PRIMARY),
                                inactiveColor: Colors.grey.shade600,
                                inactiveFillColor: Colors.transparent),
                            enableActiveFill: true,
                            onCompleted: (v) {
                              _submitCode(v);
                            },
                            onChanged: (value) {
                              print(value);
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code? ".tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Resend code functionality
                                  _submitPhoneNumber();
                                },
                                child: Text(
                                  'Resend'.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _submitCode(String code) async {
    ShowToastDialog.showLoader("Please wait".tr());
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(
        verificationId: _verificationID, smsCode: code);

    try {
      // Sign the user in (or link) with the credential
      auth.UserCredential userCredential =
          await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
      User? user =
          await FireStoreUtils.getCurrentUser(userCredential.user?.uid ?? '');

      print("DEBUGGGG user active? ${user!.active}");
      if (user == null) {
        ShowToastDialog.closeLoader();
        _deliveryService(userCredential.user!.uid);
      } else {
        ShowToastDialog.closeLoader();

        // Verifica se o usuário tem role de driver
        if (user.role == USER_ROLE_DRIVER) {
          // Verifica se o usuário está ativo
          if (user.active) {
            // Verifica se o usuário está pronto (isReady)
            if (user.isReady) {
              await FireStoreUtils.updateCurrentUser(user);
              MyAppState.currentUser = user;
              pushAndRemoveUntil(context, ContainerScreen(user: user), false);
            } else {
              // Usuário é driver mas não está pronto
              MyAppState.currentUser = user;

              pushAndRemoveUntil(
                  context, PreSignUpScreen(waiting: true), false);
            }
          } else {
            // Usuário não está ativo
            MyAppState.currentUser = user;
            showAlertDialog(
                context,
                "Couldn't Log In".tr(),
                'Driver is not activated yet. Please contact to admin to activate it. Thanks.'
                    .tr(),
                true);
            // pushAndRemoveUntil(
            //     context,
            //     PhoneNumberInputScreen(
            //       login: true,
            //     ),
            //     false);
          }
        } else {
          // Usuário existe mas não é driver
          showAlertDialog(
              context,
              "Phone Number Already Registered".tr(),
              'This phone number is already registered with a different account type.'
                  .tr(),
              true);
        }
      }
    } on auth.FirebaseAuthException catch (e) {
      ShowToastDialog.closeLoader();
      showAlertDialog(context, 'Failed'.tr(), e.message.toString(), true);
    } catch (e) {
      ShowToastDialog.closeLoader();
      showAlertDialog(context, 'Failed'.tr(), e.toString(), true);
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse? response = await _imagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (isUserImage) {
          _image = File(response.file!.path);
        } else {
          _carImage = File(response.file!.path);
        }
      });
    }
  }

  File? _carProofPictureFile;
  File? _driverProofPictureURLFile;

  _onPickupCarProofAndDriverProof(bool isDriver) {
    final action = CupertinoActionSheet(
      message: const Text(
        'Add your Vehicle image.',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            if (isDriver) {
              XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (singleImage != null) {
                setState(() {
                  _driverProofPictureURLFile = File(singleImage.path);
                });
              }
            } else {
              XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (singleImage != null) {
                setState(() {
                  _carProofPictureFile = File(singleImage.path);
                });
              }
            }
          },
          child: const Text('Choose image from gallery').tr(),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            if (isDriver) {
              final XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (singleImage != null) {
                setState(() {
                  _driverProofPictureURLFile = File(singleImage.path);
                });
              }
            } else {
              final XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (singleImage != null) {
                setState(() {
                  _carProofPictureFile = File(singleImage.path);
                });
              }
            }
          },
          child: const Text('Take a picture').tr(),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ).tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _onCameraClick(bool isUserImage) {
    isUserImage = isUserImage;
    final action = CupertinoActionSheet(
      message: Text(
        isUserImage ? 'Add profile picture'.tr() : 'Add Car Image'.tr(),
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                isUserImage
                    ? _image = File(image.path)
                    : _carImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                isUserImage
                    ? _image = File(image.path)
                    : _carImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isUserImage ? _image = null : _carImage = null;
            });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Widget formUI() {
    return Column(
      children: [
        Image.asset(
          'assets/images/app_logo.png',
          height: MediaQuery.of(context).size.height * 0.13,
          width: MediaQuery.of(context).size.width * 0.4,
          fit: BoxFit.contain,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
          decoration: BoxDecoration(
            color: AppThemeData.lightgrey.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.only(top: 6.0, right: 8.0, left: 8.0),
          child: Column(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                  child: TextFormField(
                    controller: _fullNameController,
                    cursorColor: Color(COLOR_PRIMARY),
                    textAlignVertical: TextAlignVertical.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Full name is required'.tr();
                      }
                      if (value.trim().split(' ').length < 2) {
                        return 'Please enter your full name (first and last name)'
                            .tr();
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Full Name'.tr(),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 1.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: FormField<String>(
                    validator: (value) => _mobileController.text.isEmpty
                        ? 'Phone number required'.tr()
                        : null,
                    builder: (FormFieldState<String> state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              border: Border.all(
                                color: state.hasError
                                    ? Theme.of(context).colorScheme.error
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: InternationalPhoneNumberInput(
                              onInputChanged: (PhoneNumber number) {
                                _mobileController.text =
                                    number.phoneNumber.toString();
                                state.didChange(number
                                    .phoneNumber); // Atualiza o estado do campo
                              },
                              ignoreBlank: true,
                              autoValidateMode: AutovalidateMode.disabled,
                              inputDecoration: InputDecoration(
                                hintText: 'Phone Number'.tr(),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                isDense: true,
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                              ),
                              inputBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              selectorConfig: SelectorConfig(
                                  selectorType: PhoneInputSelectorType.DIALOG),
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 4.0),
                              child: Text(
                                state.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.next,
                    cursorColor: Color(COLOR_PRIMARY),
                    validator: validateEmailNull,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Email Address'.tr(),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 1.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: DropdownButtonFormField<VehicleTypes>(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            BorderSide(color: Color(COLOR_PRIMARY), width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'field required'.tr() : null,
                    value: selectedVehicle,
                    onChanged: (VehicleTypes? value) async {
                      setState(() {
                        selectedVehicle = value;
                        carMakesList.clear();
                        selectedCarMakes = null;
                        carModelList.clear();
                        selectedCarModel = null;
                      });
                      if (value != null) {
                        try {
                          await FireStoreUtils.getCarMakes(value.name)
                              .then((makes) {
                            setState(() {
                              carMakesList = makes;
                            });
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error loading brands: $e'.tr())),
                          );
                        }
                      }
                    },
                    hint: Text('Select Vehicle Type'.tr()),
                    items: vehiclesList.map((VehicleTypes item) {
                      return DropdownMenuItem<VehicleTypes>(
                        child: Text(item.name.toString()),
                        value: item,
                      );
                    }).toList(),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: DropdownButtonFormField<CarMakes>(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            BorderSide(color: Color(COLOR_PRIMARY), width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'field required'.tr() : null,
                    value: selectedCarMakes,
                    onChanged: (CarMakes? value) async {
                      setState(() {
                        selectedCarMakes = value;
                        carModelList.clear();
                        selectedCarModel = null;
                      });
                      if (value != null && value.name != null) {
                        try {
                          await FireStoreUtils.getCarModel(context, value.name!)
                              .then((models) {
                            setState(() {
                              carModelList = models;
                            });
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error loading models: $e'.tr())),
                          );
                        }
                      }
                    },
                    hint: Text('Select Vehicle Brand'.tr()),
                    items: carMakesList.map((CarMakes item) {
                      return DropdownMenuItem<CarMakes>(
                        child: Text(item.name.toString()),
                        value: item,
                      );
                    }).toList(),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: DropdownButtonFormField<CarModel>(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            BorderSide(color: Color(COLOR_PRIMARY), width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'field required'.tr() : null,
                    value: selectedCarModel,
                    onChanged: (value) {
                      setState(() {
                        selectedCarModel = value;
                      });
                    },
                    hint: Text('Select Car Model'.tr()),
                    items: carModelList.map((CarModel item) {
                      return DropdownMenuItem<CarModel>(
                        child: Text(item.name.toString()),
                        value: item,
                      );
                    }).toList(),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: TextFormField(
                    controller: _carPlateController,
                    validator: validateEmptyField,
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: Color(COLOR_PRIMARY),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Car Plate'.tr(),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 1.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Transform.translate(
              //         offset: Offset(0, -8),
              //         child: Checkbox(
              //           value: _consentChecked,
              //           onChanged: (value) {
              //             setState(() {
              //               _consentChecked = value ?? false;
              //             });
              //           },
              //           activeColor: Color(COLOR_PRIMARY),
              //         ),
              //       ),
              //       Expanded(
              //         child: Padding(
              //           padding: const EdgeInsets.only(top: 8.0),
              //           child: Text(
              //             'Concordo em fornecer meus dados para receber conteúdos e ofertas por e-mail ou outros meios.'
              //                 .tr(),
              //             style: TextStyle(
              //               fontSize: 12,
              //               color: AppThemeData.black,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Checkbox para termos e condições (apenas quando não é login)
              if (!widget.login) ...[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -8),
                        child: Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          activeColor: Color(COLOR_PRIMARY),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: AppThemeData.black,
                              ),
                              children: [
                                TextSpan(text: 'Aceito os '),
                                TextSpan(
                                  text: 'Termos e Condições',
                                  style: TextStyle(
                                    color: Color(COLOR_PRIMARY),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TermsAndCondition(),
                                        ),
                                      );
                                    },
                                ),
                                TextSpan(text: ' e '),
                                TextSpan(
                                  text: 'Política de Privacidade',
                                  style: TextStyle(
                                    color: Color(COLOR_PRIMARY),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PrivacyPolicyScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(
                    right: 8.0, left: 8.0, top: 16.0, bottom: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(COLOR_PRIMARY),
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: Color(COLOR_PRIMARY),
                        ),
                      ),
                    ),
                    child: Text(
                      'Finish Pre Sign Up'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode(context) ? Colors.black : Colors.white,
                      ),
                    ),
                    onPressed: () => _signUp(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget formCabServiceUI() {
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _firstNameController,
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: easyLocal.tr('First Name'),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _lastNameController,
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Last Name'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // Row(
        //   children: [
        //     Expanded(
        //       child: Row(
        //         children: [
        //           Radio(
        //             value: "individual",
        //             groupValue: companyOrNot,
        //             onChanged: (value) {
        //               setState(() {
        //                 companyOrNot = value.toString();
        //               });
        //             },
        //           ),
        //           Text("As an Individual").tr()
        //         ],
        //       ),
        //     ),
        //     Expanded(
        //       child: Row(
        //         children: [
        //           Radio(
        //             value: "company",
        //             groupValue: companyOrNot,
        //             onChanged: (value) {
        //               setState(() {
        //                 companyOrNot = value.toString();
        //               });
        //             },
        //           ),
        //           Text("As a Company").tr()
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        // companyOrNot == "company"
        //     ? Column(
        //         children: [
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _companyNameController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Company Name'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _companyAddressController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 maxLines: 5,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Company address'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       )
        //     : Container(),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<SectionModel>(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Select Section'.tr(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) => value == null ? 'field required' : null,
                value: selectedSection,
                onChanged: (value) async {
                  setState(() {
                    selectedSection = value;
                  });

                  if (selectedSection != null) {
                    await FireStoreUtils.getVehicleType(selectedSection!)
                        .then((value) {
                      setState(() {
                        vehicleType = value;
                      });
                    });
                  } else {}
                },
                hint: Text('Select Section'.tr()),
                items: sectionsVal!.map((SectionModel item) {
                  return DropdownMenuItem<SectionModel>(
                    child: Text(item.name.toString()),
                    value: item,
                  );
                }).toList()),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<VehicleType>(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Select vehicle type'.tr(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) =>
                    value == null ? 'field required'.tr() : null,
                value: selectedVehicleType,
                onChanged: (value) async {
                  setState(() {
                    selectedVehicleType = value;
                  });
                },
                hint: Text('Select vehicle type'.tr()),
                items: vehicleType.map((VehicleType item) {
                  return DropdownMenuItem<VehicleType>(
                    child: Text(item.name.toString()),
                    value: item,
                  );
                }).toList()),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<CarMakes>(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) =>
                    value == null ? 'field required'.tr() : null,
                value: selectedCarMakes,
                onChanged: (value) async {
                  carModelList.clear();
                  selectedCarModel = null;
                  setState(() {
                    selectedCarMakes = value;
                  });
                  await FireStoreUtils.getCarModel(
                          context, selectedCarMakes!.name.toString())
                      .then((value) {
                    setState(() {
                      carModelList = value;
                    });
                  });
                },
                hint: Text('Select Car Makes'.tr()),
                items: carMakesList.map((CarMakes item) {
                  return DropdownMenuItem<CarMakes>(
                    child: Text(item.name.toString()),
                    value: item,
                  );
                }).toList()),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<CarModel>(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) =>
                    value == null ? 'field required'.tr() : null,
                value: selectedCarModel,
                onChanged: (value) {
                  setState(() {
                    selectedCarModel = value;
                  });
                },
                hint: Text('Select Car Model'.tr()),
                items: carModelList.map((CarModel item) {
                  return DropdownMenuItem<CarModel>(
                    child: Text(item.name.toString()),
                    value: item,
                  );
                }).toList()),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carPlateController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                filled: true,
                hintText: 'Car Plate'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carColorController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Color'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.grey.shade200)),
            child: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) =>
                  _mobileController.text = number.phoneNumber.toString(),
              ignoreBlank: true,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              inputDecoration: InputDecoration(
                hintText: 'Phone Number'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              inputBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              selectorConfig:
                  SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email Address'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // companyOrNot == "company"
        //     ? Container()
        //     : Padding(
        //         padding: const EdgeInsets.only(top: 20),
        //         child: Row(
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Expanded(
        //                 child: Column(
        //               children: [
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     "Pickup Car proof".tr(),
        //                     style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //                   ),
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.all(10.0),
        //                   child: Stack(
        //                     alignment: Alignment.bottomCenter,
        //                     children: <Widget>[
        //                       SizedBox(
        //                         width: 90,
        //                         height: 90,
        //                         child: _carProofPictureFile == null
        //                             ? Image.network(
        //                                 placeholderImage,
        //                                 fit: BoxFit.cover,
        //                               )
        //                             : Image.file(
        //                                 _carProofPictureFile!,
        //                                 fit: BoxFit.cover,
        //                               ),
        //                       ),
        //                       Positioned(
        //                         left: 55,
        //                         right: 0,
        //                         child: FloatingActionButton(
        //                           heroTag: 'profileImage',
        //                           backgroundColor: Color(COLOR_ACCENT),
        //                           child: Icon(
        //                             CupertinoIcons.camera,
        //                             color: isDarkMode(context) ? Colors.black : Colors.white,
        //                           ),
        //                           mini: true,
        //                           onPressed: () => _onPickupCarProofAndDriverProof(false),
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             )),
        //             Expanded(
        //                 child: Column(
        //               children: [
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     "Pickup Driver proof",
        //                     style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //                   ),
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.all(10.0),
        //                   child: Stack(
        //                     alignment: Alignment.bottomCenter,
        //                     children: <Widget>[
        //                       SizedBox(
        //                         width: 90,
        //                         height: 90,
        //                         child: _driverProofPictureURLFile == null
        //                             ? Image.network(
        //                                 placeholderImage,
        //                                 fit: BoxFit.cover,
        //                               )
        //                             : Image.file(
        //                                 _driverProofPictureURLFile!,
        //                                 fit: BoxFit.cover,
        //                               ),
        //                       ),
        //                       Positioned(
        //                         left: 55,
        //                         right: 0,
        //                         child: FloatingActionButton(
        //                           heroTag: 'profileImage',
        //                           backgroundColor: Color(COLOR_ACCENT),
        //                           child: Icon(
        //                             CupertinoIcons.camera,
        //                             color: isDarkMode(context) ? Colors.black : Colors.white,
        //                           ),
        //                           mini: true,
        //                           onPressed: () => _onPickupCarProofAndDriverProof(true),
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             )),
        //           ],
        //         ),
        //       ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(COLOR_PRIMARY),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'Sign Up'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'OR',
              style: TextStyle(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ).tr(),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            widget.login
                ? 'Login with E-mail'.tr()
                : 'Sign up with E-mail'.tr(),
            style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1),
          ),
        )
      ],
    );
  }

  Widget formParcelServiceUI() {
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _firstNameController,
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: easyLocal.tr('First Name'),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _lastNameController,
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Last Name'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carNameController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Model'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carPlateController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Plate'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.grey.shade200)),
            child: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) =>
                  _mobileController.text = number.phoneNumber.toString(),
              ignoreBlank: true,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              inputDecoration: InputDecoration(
                hintText: 'Phone Number'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              inputBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              selectorConfig:
                  SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email Address'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Pickup Car proof".tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: _carProofPictureFile == null
                              ? Image.network(
                                  placeholderImage,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _carProofPictureFile!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          left: 55,
                          right: 0,
                          child: FloatingActionButton(
                            heroTag: 'profileImage',
                            backgroundColor: Color(COLOR_ACCENT),
                            child: Icon(
                              CupertinoIcons.camera,
                              color: isDarkMode(context)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            mini: true,
                            onPressed: () =>
                                _onPickupCarProofAndDriverProof(false),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
              Expanded(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Pickup Driver proof".tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: _driverProofPictureURLFile == null
                              ? Image.network(
                                  placeholderImage,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _driverProofPictureURLFile!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          left: 55,
                          right: 0,
                          child: FloatingActionButton(
                            heroTag: 'profileImage',
                            backgroundColor: Color(COLOR_ACCENT),
                            child: Icon(
                              CupertinoIcons.camera,
                              color: isDarkMode(context)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            mini: true,
                            onPressed: () =>
                                _onPickupCarProofAndDriverProof(true),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(COLOR_PRIMARY),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'Sign Up'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'OR',
              style: TextStyle(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ).tr(),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            widget.login
                ? 'Login with E-mail'.tr()
                : 'Sign up with E-mail'.tr(),
            style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1),
          ),
        )
      ],
    );
  }

  Widget formRentalServiceUI() {
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _firstNameController,
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: easyLocal.tr('First Name'),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _lastNameController,
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Last Name'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // Row(
        //   children: [
        //     Expanded(
        //       child: Row(
        //         children: [
        //           Radio(
        //             value: "individual",
        //             groupValue: companyOrNot,
        //             onChanged: (value) {
        //               setState(() {
        //                 companyOrNot = value.toString();
        //               });
        //             },
        //           ),
        //           Text("As an Individual").tr()
        //         ],
        //       ),
        //     ),
        //     Expanded(
        //       child: Row(
        //         children: [
        //           Radio(
        //             value: "company",
        //             groupValue: companyOrNot,
        //             onChanged: (value) {
        //               setState(() {
        //                 companyOrNot = value.toString();
        //               });
        //             },
        //           ),
        //           Text("As a Company").tr()
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        // companyOrNot == "company"
        //     ? Column(
        //         children: [
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _companyNameController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Company Name'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _companyAddressController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 maxLines: 5,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Company address'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       )
        //     : Column(
        //         children: [
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: DropdownButtonFormField<VehicleType>(
        //                   decoration: InputDecoration(
        //                     contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                     fillColor: Colors.white,
        //                     hintText: 'Select vehicle type'.tr(),
        //                     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                     errorBorder: OutlineInputBorder(
        //                       borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                       borderRadius: BorderRadius.circular(25.0),
        //                     ),
        //                     focusedErrorBorder: OutlineInputBorder(
        //                       borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                       borderRadius: BorderRadius.circular(25.0),
        //                     ),
        //                     enabledBorder: OutlineInputBorder(
        //                       borderSide: BorderSide(color: Colors.grey.shade200),
        //                       borderRadius: BorderRadius.circular(25.0),
        //                     ),
        //                   ),
        //                   validator: (value) => value == null ? 'field required' : null,
        //                   value: selectedRentalVehicleType,
        //                   onChanged: (value) async {
        //                     setState(() {
        //                       selectedRentalVehicleType = value;
        //                     });
        //                   },
        //                   hint: Text('Select vehicle type'.tr()),
        //                   items: rentalVehicleType.map((VehicleType item) {
        //                     return DropdownMenuItem<VehicleType>(
        //                       child: Text(item.name.toString()),
        //                       value: item,
        //                     );
        //                   }).toList()),
        //             ),
        //           ),
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _carNameController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Car Model'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _carPlateController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Car Plate'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.grey.shade200)),
            child: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) =>
                  _mobileController.text = number.phoneNumber.toString(),
              ignoreBlank: true,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              inputDecoration: InputDecoration(
                hintText: 'Phone Number'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              inputBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              selectorConfig:
                  SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email Address'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // companyOrNot == "company"
        //     ? Container()
        //     : Padding(
        //         padding: const EdgeInsets.only(top: 20),
        //         child: Row(
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Expanded(
        //                 child: Column(
        //               children: [
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     "Pickup Car proof".tr(),
        //                     style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //                   ),
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.all(10.0),
        //                   child: Stack(
        //                     alignment: Alignment.bottomCenter,
        //                     children: <Widget>[
        //                       SizedBox(
        //                         width: 90,
        //                         height: 90,
        //                         child: _carProofPictureFile == null
        //                             ? Image.network(
        //                                 placeholderImage,
        //                                 fit: BoxFit.cover,
        //                               )
        //                             : Image.file(
        //                                 _carProofPictureFile!,
        //                                 fit: BoxFit.cover,
        //                               ),
        //                       ),
        //                       Positioned(
        //                         left: 55,
        //                         right: 0,
        //                         child: FloatingActionButton(
        //                           heroTag: 'profileImage',
        //                           backgroundColor: Color(COLOR_ACCENT),
        //                           child: Icon(
        //                             CupertinoIcons.camera,
        //                             color: isDarkMode(context) ? Colors.black : Colors.white,
        //                           ),
        //                           mini: true,
        //                           onPressed: () => _onPickupCarProofAndDriverProof(false),
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             )),
        //             Expanded(
        //                 child: Column(
        //               children: [
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     "Pickup Driver proof",
        //                     style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //                   ),
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.all(10.0),
        //                   child: Stack(
        //                     alignment: Alignment.bottomCenter,
        //                     children: <Widget>[
        //                       SizedBox(
        //                         width: 90,
        //                         height: 90,
        //                         child: _driverProofPictureURLFile == null
        //                             ? Image.network(
        //                                 placeholderImage,
        //                                 fit: BoxFit.cover,
        //                               )
        //                             : Image.file(
        //                                 _driverProofPictureURLFile!,
        //                                 fit: BoxFit.cover,
        //                               ),
        //                       ),
        //                       Positioned(
        //                         left: 55,
        //                         right: 0,
        //                         child: FloatingActionButton(
        //                           heroTag: 'profileImage',
        //                           backgroundColor: Color(COLOR_ACCENT),
        //                           child: Icon(
        //                             CupertinoIcons.camera,
        //                             color: isDarkMode(context) ? Colors.black : Colors.white,
        //                           ),
        //                           mini: true,
        //                           onPressed: () => _onPickupCarProofAndDriverProof(true),
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             )),
        //           ],
        //         ),
        //       ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(COLOR_PRIMARY),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'Sign Up'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'OR',
              style: TextStyle(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ).tr(),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            widget.login
                ? 'Login with E-mail'.tr()
                : 'Sign up with E-mail'.tr(),
            style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1),
          ),
        )
      ],
    );
  }

  /// if the fields are validated and location is enabled we create a new user
  /// and navigate to [ContainerScreen] else we show error
  _signUp() async {
    if (widget.login) {
      await _submitPhoneNumber();
    } else {
      // Validar checkbox de termos e condições
      if (!_termsAccepted) {
        ShowToastDialog.showToast(
            "Deve aceitar os termos e condições para continuar.".tr());
        return;
      }

      if (_deliveryKey.currentState?.validate() ?? false) {
        _deliveryKey.currentState!.save();
        await _submitPhoneNumber();
      } else {
        setState(() {
          _validate = AutovalidateMode.onUserInteraction;
        });
      }
    }
  }

  _deliveryService(String uid) async {
    String profilePicUrl = '';
    String carPicUrl = DEFAULT_CAR_IMAGE;
    String driverProofUrl = '';
    String carProofUrl = '';
    if (_image != null) {
      profilePicUrl =
          await FireStoreUtils.uploadUserImageToFireStorage(_image!, uid);
    }
    if (_carImage != null) {
      carPicUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, uid);
    }

    if (_driverProofPictureURLFile != null) {
      driverProofUrl = await FireStoreUtils.uploadCarImageToFireStorage(
          _driverProofPictureURLFile!, Timestamp.now().toString() ?? "");
    }
    if (_carProofPictureFile != null) {
      carProofUrl = await FireStoreUtils.uploadCarImageToFireStorage(
          _carProofPictureFile!, Timestamp.now().toString());
    }

    String fullName = _fullNameController.text.trim();
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.first;
    String lastName = nameParts.sublist(1).join(' ');

    User user = User(
      email: _emailController.text,
      settings: UserSettings(),
      lastOnlineTimestamp: Timestamp.now(),
      isActive: false,
      active: false,
      phoneNumber: _mobileController.text,
      firstName: firstName,
      userID: uid,
      lastName: lastName,
      fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
      profilePictureURL: profilePicUrl,
      carPictureURL: carPicUrl,
      carNumber: _carPlateController.text,
      carName: _carNameController.text,
      carMakes: _carMakeController.text,
      vehicleType: _vehicleController.text,
      role: USER_ROLE_DRIVER,
      carProofPictureURL: carProofUrl,
      driverProofPictureURL: driverProofUrl,
      serviceType: "delivery-service",
      consentCheck: _consentChecked,
      createdAt: Timestamp.now(),
    );
    String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
    await hideProgress();

    if (errorMessage == null) {
      MyAppState.currentUser = user;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      // MyAppState.currentUser = null;
      pushAndRemoveUntil(context, PreSignUpScreen(), false);
    } else {
      return "Couldn't sign up for firebase, Please try again.".tr();
    }
  }

  _parcelService(String uid) async {
    String profilePicUrl = '';
    String carPicUrl = DEFAULT_CAR_IMAGE;
    String driverProofUrl = '';
    String carProofUrl = '';
    print("ABABAB");
    if (_image != null) {
      profilePicUrl =
          await FireStoreUtils.uploadUserImageToFireStorage(_image!, uid);
    }
    if (_carImage != null) {
      carPicUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, uid);
    }

    if (_driverProofPictureURLFile != null) {
      driverProofUrl = await FireStoreUtils.uploadCarImageToFireStorage(
          _driverProofPictureURLFile!, Timestamp.now().toString());
    }
    if (_carProofPictureFile != null) {
      carProofUrl = await FireStoreUtils.uploadCarImageToFireStorage(
          _carProofPictureFile!, Timestamp.now().toString());
    }

    User user = User(
        email: _emailController.text,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        active: false,
        phoneNumber: _mobileController.text,
        firstName: _firstNameController.text,
        userID: uid,
        lastName: _lastNameController.text,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        carNumber: _carNameController.text,
        carName: _carNameController.text,
        role: USER_ROLE_DRIVER,
        carProofPictureURL: carProofUrl,
        driverProofPictureURL: driverProofUrl,
        serviceType: "parcel_delivery",
        createdAt: Timestamp.now());

    print("QWERT");
    print(user.toJson());
    String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
    await hideProgress();

    if (errorMessage == null) {
      MyAppState.currentUser = user;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else {
      return "Couldn't sign up for firebase, Please try again.".tr();
    }
  }

  _rentalService(String uid) async {
    String profilePicUrl = '';
    String carPicUrl = DEFAULT_CAR_IMAGE;
    String driverProofUrl = '';
    String carProofUrl = '';
    if (_image != null) {
      profilePicUrl =
          await FireStoreUtils.uploadUserImageToFireStorage(_image!, uid);
    }
    if (_carImage != null) {
      carPicUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, uid);
    }

    if (_driverProofPictureURLFile != null) {
      driverProofUrl = await FireStoreUtils.uploadCarImageToFireStorage(
          _driverProofPictureURLFile!, Timestamp.now().toString());
    }
    if (_carProofPictureFile != null) {
      carProofUrl = await FireStoreUtils.uploadCarImageToFireStorage(
          _carProofPictureFile!, Timestamp.now().toString());
    }

    User user = User(
        email: _emailController.text,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        active: false,
        phoneNumber: _mobileController.text,
        firstName: _firstNameController.text,
        userID: uid,
        lastName: _lastNameController.text,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        carNumber: _carPlateController.text,
        carName: _carNameController.text,
        role: USER_ROLE_DRIVER,
        carProofPictureURL: carProofUrl,
        driverProofPictureURL: driverProofUrl,
        vehicleType: selectedRentalVehicleType!.name.toString(),
        serviceType: "rental-service",
        createdAt: Timestamp.now());
    String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
    await hideProgress();

    if (errorMessage == null) {
      MyAppState.currentUser = user;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else {
      return "Couldn't sign up for firebase, Please try again.".tr();
    }
  }

  _cabService(String uid) async {
    String profilePicUrl = '';
    String carPicUrl = DEFAULT_CAR_IMAGE;
    String driverProofUrl = '';
    String carProofUrl = '';
    if (_image != null) {
      profilePicUrl =
          await FireStoreUtils.uploadUserImageToFireStorage(_image!, uid);
    }
    if (_carImage != null) {
      carPicUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, uid);
    }

    if (_driverProofPictureURLFile != null) {
      driverProofUrl = await FireStoreUtils.uploadCarImageToFireStorage(
          _driverProofPictureURLFile!, Timestamp.now().toString());
    }
    if (_carProofPictureFile != null) {
      carProofUrl = await FireStoreUtils.uploadCarImageToFireStorage(
          _carProofPictureFile!, Timestamp.now().toString());
    }

    User user = User(
        email: _emailController.text,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        active: false,
        phoneNumber: _mobileController.text,
        firstName: _firstNameController.text,
        userID: uid,
        lastName: _lastNameController.text,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        carNumber: _carPlateController.text,
        carName: selectedCarModel!.name.toString(),
        carMakes: selectedCarMakes!.name.toString(),
        vehicleType: selectedVehicleType!.name.toString(),
        serviceType: "cab-service",
        carColor: _carColorController.text,
        carProofPictureURL: carProofUrl,
        driverProofPictureURL: driverProofUrl,
        role: USER_ROLE_DRIVER,
        sectionId: selectedSection!.id,
        rideType: 'ride',
        vehicleId: selectedVehicleType!.id.toString(),
        createdAt: Timestamp.now());
    String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
    await hideProgress();

    if (errorMessage == null) {
      MyAppState.currentUser = user;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else {
      return "Couldn't sign up for firebase, Please try again.".tr();
    }
  }

  //
  // _signUpWithEmailAndPasswordInRentalService() async {
  //   await showProgress(context, 'Creating new account, Please wait...'.tr(), false);
  //   dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPasswordRentalService(
  //       _emailController.text.trim(),
  //       _passwordController.text.trim(),
  //       _image,
  //       _carImage,
  //       _carNameController.text,
  //       _carPlateController.text,
  //       _firstNameController.text,
  //       _lastNameController.text,
  //       _mobileController.text,
  //       "rental-service",
  //       _companyNameController.text,
  //       _companyAddressController.text);
  //   await hideProgress();
  //   if (result != null && result is User) {
  //     MyAppState.currentUser = result;
  //     MyAppState.currentUser!.isActive = false;
  //     MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
  //     await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
  //     await auth.FirebaseAuth.instance.signOut();
  //     MyAppState.currentUser = null;
  //     pushAndRemoveUntil(context, AuthScreen(), false);
  //   } else if (result != null && result is String) {
  //     showAlertDialog(context, 'Failed'.tr(), result, true);
  //   } else {
  //     showAlertDialog(context, 'Failed'.tr(), 'Couldn\'t sign up'.tr(), true);
  //   }
  // }
  //
  // _signUpWithEmailAndPasswordInParcelService() async {
  //   await showProgress(context, 'Creating new account, Please wait...'.tr(), false);
  //   dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
  //       _emailController.text.trim(),
  //       _passwordController.text.trim(),
  //       _image,
  //       _carImage,
  //       _carNameController.text,
  //       _carPlateController.text,
  //       _firstNameController.text,
  //       _lastNameController.text,
  //       _mobileController.text,
  //       "parcel_delivery");
  //   await hideProgress();
  //   if (result != null && result is User) {
  //     MyAppState.currentUser = result;
  //     MyAppState.currentUser!.isActive = false;
  //     MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
  //     await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
  //     await auth.FirebaseAuth.instance.signOut();
  //     MyAppState.currentUser = null;
  //     pushAndRemoveUntil(context, AuthScreen(), false);
  //   } else if (result != null && result is String) {
  //     showAlertDialog(context, 'Failed'.tr(), result, true);
  //   } else {
  //     showAlertDialog(context, 'Failed'.tr(), 'Couldn\'t sign up'.tr(), true);
  //   }
  // }
  //
  // _signUpWithEmailAndPasswordInCabService() async {
  //   await showProgress(context, 'Creating new account, Please wait...'.tr(), false);
  //   dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPasswordCabService(
  //     _emailController.text.trim(),
  //     _passwordController.text.trim(),
  //     _image,
  //     _carImage,
  //     selectedVehicleType!.name.toString(),
  //     selectedCarMakes!.name.toString(),
  //     selectedCarModel!.name.toString(),
  //     _carPlateController.text,
  //     _firstNameController.text,
  //     _lastNameController.text,
  //     _mobileController.text,
  //     "cab-service",
  //   );
  //   await hideProgress();
  //   if (result != null && result is User) {
  //     MyAppState.currentUser = result;
  //     MyAppState.currentUser!.isActive = false;
  //     MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
  //     await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
  //     await auth.FirebaseAuth.instance.signOut();
  //     MyAppState.currentUser = null;
  //     pushAndRemoveUntil(context, AuthScreen(), false);
  //   } else if (result != null && result is String) {
  //     showAlertDialog(context, 'Failed'.tr(), result, true);
  //   } else {
  //     showAlertDialog(context, 'Failed'.tr(), 'Couldn\'t sign up'.tr(), true);
  //   }
  // }

  bool _codeSent = false;
  String _verificationID = "";

  _submitPhoneNumber() async {
    //send code
    await showProgress(context, 'Sending code...'.tr(), true);
    await auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _mobileController.text,
      verificationCompleted: (auth.PhoneAuthCredential credential) {},
      verificationFailed: (auth.FirebaseAuthException e) {
        hideProgress();
        // String message = "errorOccurredTryAgain".tr();
        // switch (e.code) {
        //   case 'invalid-verification-code':
        //     message = "Invalid Code Expired".tr();
        //     break;
        //   case 'user-disabled':
        //     message = "User is Disabled".tr();
        //     break;
        //   default:
        //     message = "Error Occurred Try Again".tr();
        //     break;
        // }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.message.toString(),
          ),
        ));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          hideProgress();
          _codeSent = true;
          _verificationID = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void dispose() {
    _image = null;
    _carImage = null;
    super.dispose();
  }
}
