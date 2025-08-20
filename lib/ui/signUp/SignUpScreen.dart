import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/SectionModel.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/model/VehicleMake.dart';
import 'package:emartdriver/model/VehicleTypeModel.dart';
import 'package:emartdriver/model/VehicleModel.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:intl/intl.dart';
import 'package:emartdriver/services/show_toast_dialog.dart';
import 'package:emartdriver/repositories/vehicle_make_repository.dart';
import 'package:emartdriver/repositories/vehicle_type_repository.dart';
import 'package:emartdriver/repositories/section_repository.dart';

File? _image;
File? _carImage;

class SignUpScreen extends StatefulWidget {
  final bool fromAccountDetails;
  SignUpScreen({this.fromAccountDetails = false});
  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _vehicleController = TextEditingController();
  TextEditingController _carNameController = TextEditingController();
  TextEditingController _carMakeController = TextEditingController();
  TextEditingController _carPlateController = TextEditingController();
  TextEditingController _carColorController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  GlobalKey<FormState> _deliveryKey = GlobalKey();

  bool isUserImage = true;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  TextEditingController _companyNameController = TextEditingController();
  TextEditingController _companyAddressController = TextEditingController();

  List<String> _locations = [
    'Delivery service',
    'Cab service',
    'Parcel service',
    'Rental Service'
  ]; // Option 2
  String? _selectedServiceType;

  Timer? _autoReloadTimer;

  @override
  void initState() {
    super.initState();
    getCarMakes();
    getVehicles();
    _refreshCurrentUser();
    // Auto reload a cada 15 segundos
    _autoReloadTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      _refreshCurrentUser();
    });
  } // Option 2

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

  getCarMakes() async {
    await VehicleMakeRepository.getVehicleMakes().then((value) {
      setState(() {
        carMakesList = value;
      });
    });

    await FireStoreUtils.getRentalVehicleType().then((value) {
      setState(() {
        rentalVehicleType = value;
      });
    });

    await SectionRepository.getSections().then((value) {
      setState(() {
        sectionsVal = value;
      });
    });
  }

  getVehicles() async {
    await VehicleTypeRepository.getVehicleTypes().then((value) {
      setState(() {
        vehiclesList = value;
      });
    });
  }

  void _refreshCurrentUser() async {
    final userStream =
        FireStoreUtils().getUserByID(MyAppState.currentUser!.userID);
    final user = await userStream.first;
    setState(() {
      MyAppState.currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status =
        MyAppState.currentUser?.active == true ? 'Approved' : 'Pending';
    final statusColor = _getStatusColor(status);
    // final User user =
    //     FireStoreUtils().getUserByID(MyAppState.currentUser!.userID);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Personal Information'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).tr(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _onCameraClick(true),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(COLOR_PRIMARY),
                        child: MyAppState.currentUser?.profilePictureURL !=
                                    null &&
                                MyAppState
                                    .currentUser!.profilePictureURL!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  MyAppState.currentUser!.profilePictureURL!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${MyAppState.currentUser?.firstName ?? ''} ${MyAppState.currentUser?.lastName ?? ''}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            MyAppState.currentUser?.vehicleType ??
                                'Tipo de veículo não definido',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Divider(height: 1),
              SizedBox(height: 16),
              _buildDocumentCard(
                title: 'Pre-registration'.tr(),
                subtitle: MyAppState.currentUser?.createdAt != null
                    ? 'Filled on ${DateFormat('dd/MM/yyyy').format(MyAppState.currentUser!.createdAt!.toDate())}'
                    : 'Not filled'.tr(),
                status: status.tr(),
                statusColor: statusColor,
                onTap: null, // Pre-registration is not clickable
              ),
              SizedBox(height: 16),
              _buildDocumentCard(
                  title: 'Car Photo'.tr(),
                  subtitle: (MyAppState.currentUser?.carPictureStatus ==
                          'Rejected')
                      ? (MyAppState.currentUser?.carPictureRejectionReason ??
                              'Rejected')
                          .tr()
                      : (MyAppState.currentUser?.carPictureURL != null &&
                              MyAppState.currentUser!.carPictureURL.isNotEmpty
                          ? 'Submitted'.tr()
                          : 'Not submitted'.tr()),
                  status: MyAppState.currentUser?.carPictureStatus != null &&
                          MyAppState.currentUser!.carPictureStatus.isNotEmpty
                      ? MyAppState.currentUser!.carPictureStatus.tr()
                      : 'Pending'.tr(),
                  statusColor: _getStatusColor(
                      MyAppState.currentUser?.carPictureStatus ?? 'Pending'),
                  onTap: () =>
                      _showImagePicker('carPictureURL', 'carPictureStatus')),
              SizedBox(height: 16),

              _buildDocumentCard(
                title: 'Driver License'.tr(),
                subtitle: (MyAppState.currentUser?.driverProofStatus ==
                        'Rejected')
                    ? (MyAppState.currentUser?.driverProofRejectionReason ??
                            'Rejected')
                        .tr()
                    : (MyAppState.currentUser?.driverProofPictureURL != null &&
                            MyAppState
                                .currentUser!.driverProofPictureURL!.isNotEmpty
                        ? 'Submitted'.tr()
                        : 'Not submitted'.tr()),
                status: MyAppState.currentUser?.driverProofStatus != null &&
                        MyAppState.currentUser!.driverProofStatus.isNotEmpty
                    ? MyAppState.currentUser!.driverProofStatus.tr()
                    : 'Pending'.tr(),
                statusColor: _getStatusColor(
                    MyAppState.currentUser?.driverProofStatus ?? 'Pending'),
                onTap: () => _showImagePicker(
                    'driverProofPictureURL', 'driverProofStatus'),
              ),
              SizedBox(height: 16),
              _buildDocumentCard(
                title: 'Criminal Record'.tr(),
                subtitle: (MyAppState.currentUser?.criminalRecordStatus ==
                        'Rejected')
                    ? (MyAppState.currentUser?.criminalRecordRejectionReason ??
                            'Rejected')
                        .tr()
                    : (MyAppState.currentUser?.criminalRecordPictureURL !=
                                null &&
                            MyAppState.currentUser!.criminalRecordPictureURL!
                                .isNotEmpty
                        ? 'Submitted'.tr()
                        : 'Not submitted'.tr()),
                status:
                    (MyAppState.currentUser?.criminalRecordStatus ?? 'Pending')
                        .tr(),
                statusColor: _getStatusColor(
                    MyAppState.currentUser?.criminalRecordStatus ?? 'Pending'),
                onTap: () => _showImagePicker(
                    'criminalRecordPictureURL', 'criminalRecordStatus'),
              ),
              SizedBox(height: 16),
              _buildDocumentCard(
                title: 'Proof of Residence or NUIT'.tr(),
                subtitle: (MyAppState.currentUser?.nuitStatus == 'Rejected')
                    ? (MyAppState.currentUser?.nuitRejectionReason ??
                            'Rejected')
                        .tr()
                    : (MyAppState.currentUser?.nuitPictureURL != null &&
                            MyAppState.currentUser!.nuitPictureURL!.isNotEmpty
                        ? 'Submitted'.tr()
                        : 'Not submitted'.tr()),
                status: (MyAppState.currentUser?.nuitStatus ?? 'Pending').tr(),
                statusColor: _getStatusColor(
                    MyAppState.currentUser?.nuitStatus ?? 'Pending'),
                onTap: () => _showImagePicker('nuitPictureURL', 'nuitStatus'),
              ),
              SizedBox(height: 16),
              _buildDocumentCard(
                title: 'Car Registration'.tr(),
                subtitle: (MyAppState.currentUser?.carProofStatus == 'Rejected')
                    ? (MyAppState.currentUser?.carProofRejectionReason ??
                            'Rejected')
                        .tr()
                    : (MyAppState.currentUser?.carProofPictureURL != null &&
                            MyAppState
                                .currentUser!.carProofPictureURL!.isNotEmpty
                        ? 'Submitted'.tr()
                        : 'Not submitted'.tr()),
                status:
                    (MyAppState.currentUser?.carProofStatus ?? 'Pending').tr(),
                statusColor: _getStatusColor(
                    MyAppState.currentUser?.carProofStatus ?? 'Pending'),
                onTap: () =>
                    _showImagePicker('carProofPictureURL', 'carProofStatus'),
              ),
              SizedBox(height: 16),
              _buildDocumentCard(
                title: 'Insurance Type'.tr(),
                subtitle:
                    '', // Assuming no specific field for this in User model
                status: '', // Assuming no specific field for this in User model
                statusColor: Colors.transparent,
                onTap: null, // Not a photo document
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(COLOR_PRIMARY),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () async {
                    ShowToastDialog.showLoader("Saving changes...".tr());
                    try {
                      User? updatedUser =
                          await FireStoreUtils.updateCurrentUser(
                              MyAppState.currentUser!);
                      if (updatedUser != null) {
                        MyAppState.currentUser = updatedUser;
                        ShowToastDialog.closeLoader();
                        if (widget.fromAccountDetails) {
                          Navigator.pop(context);
                        } else {
                          pushAndRemoveUntil(
                              context,
                              ContainerScreen(user: MyAppState.currentUser!),
                              false);
                        }
                      } else {
                        ShowToastDialog.closeLoader();
                        ShowToastDialog.showToast("Error saving changes".tr());
                      }
                    } catch (e) {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Error saving changes: $e".tr());
                    }
                  },
                  child: Text(
                    'Save changes'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Under review':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  Future<void> _pickImageAndUpload(
      ImageSource source, String fieldName, String statusFieldName) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      ShowToastDialog.showLoader('Uploading image...');
      String? imageUrl = await FireStoreUtils.uploadUserImageAndGetURL(
          imageFile, fieldName, context);
      ShowToastDialog.closeLoader(); // Dismiss progress dialog

      if (imageUrl != null) {
        setState(() {
          // Update the specific field in MyAppState.currentUser
          switch (fieldName) {
            case 'profilePictureURL':
              MyAppState.currentUser!.profilePictureURL = imageUrl;
              MyAppState.currentUser!.profilePictureStatus = 'Under review';
              break;
            case 'driverProofPictureURL':
              MyAppState.currentUser!.driverProofPictureURL = imageUrl;
              MyAppState.currentUser!.driverProofStatus = 'Under review';
              break;
            case 'criminalRecordPictureURL':
              MyAppState.currentUser!.criminalRecordPictureURL = imageUrl;
              MyAppState.currentUser!.criminalRecordStatus = 'Under review';
              break;
            case 'nuitPictureURL':
              MyAppState.currentUser!.nuitPictureURL = imageUrl;
              MyAppState.currentUser!.nuitStatus = 'Under review';
              break;
            case 'carProofPictureURL':
              MyAppState.currentUser!.carProofPictureURL = imageUrl;
              MyAppState.currentUser!.carProofStatus = 'Under review';
              break;
            case 'carPictureURL':
              MyAppState.currentUser!.carPictureURL = imageUrl;
              MyAppState.currentUser!.carPictureStatus = 'Under review';
              break;
          }
        });
        await FireStoreUtils.updateCurrentUser(
            MyAppState.currentUser!); // Persist changes
        ShowToastDialog.showToast('Photo sent for validation.'.tr());
      } else {
        ShowToastDialog.showToast('Failed to send photo.'.tr());
      }
    }
  }

  void _showImagePicker(String fieldName, String statusFieldName) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppThemeData.white,
                ),
                title: Text(
                  'Gallery'.tr(),
                  selectionColor: AppThemeData.white,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndUpload(
                      ImageSource.gallery, fieldName, statusFieldName);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: AppThemeData.white),
                title: Text('Camera'.tr(), selectionColor: AppThemeData.white),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndUpload(
                      ImageSource.camera, fieldName, statusFieldName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppThemeData.grey, width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (status.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
      ),
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
          child: const Text('Choose image from gallery'),
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
          child: const Text('Take a picture'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _onCameraClick(bool isUserImage) async {
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
            if (image != null) {
              setState(() {
                isUserImage
                    ? _image = File(image.path)
                    : _carImage = File(image.path);
              });

              if (isUserImage && _image != null) {
                ShowToastDialog.showLoader("Uploading image...".tr());
                String? imageUrl =
                    await FireStoreUtils.uploadUserImageToFireStorage(
                  _image!,
                  MyAppState.currentUser!.userID,
                );
                if (imageUrl != null) {
                  MyAppState.currentUser!.profilePictureURL = imageUrl;
                  MyAppState.currentUser!.profilePictureStatus = 'Under review';
                  User? updatedUser = await FireStoreUtils.updateCurrentUser(
                      MyAppState.currentUser!);
                  if (updatedUser != null) {
                    MyAppState.currentUser = updatedUser;
                    setState(() {});
                  }
                }
                ShowToastDialog.closeLoader();
              }
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              setState(() {
                isUserImage
                    ? _image = File(image.path)
                    : _carImage = File(image.path);
              });

              if (isUserImage && _image != null) {
                ShowToastDialog.showLoader("Uploading image...".tr());
                String? imageUrl =
                    await FireStoreUtils.uploadUserImageToFireStorage(
                  _image!,
                  MyAppState.currentUser!.userID,
                );
                if (imageUrl != null) {
                  MyAppState.currentUser!.profilePictureURL = imageUrl;
                  MyAppState.currentUser!.profilePictureStatus = 'Under review';
                  User? updatedUser = await FireStoreUtils.updateCurrentUser(
                      MyAppState.currentUser!);
                  if (updatedUser != null) {
                    MyAppState.currentUser = updatedUser;
                    setState(() {});
                  }
                }
                ShowToastDialog.closeLoader();
              }
            }
          },
        ),
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
        // Campo: Tipo de Veículo
// Campo: Tipo de Veículo
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<VehicleTypeModel>(
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0),
                ),
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
              value: selectedVehicle,
              onChanged: (VehicleTypeModel? value) async {
                setState(() {
                  selectedVehicle = value;
                  carMakesList.clear();
                  selectedCarMakes = null;
                  carModelList.clear();
                  selectedCarModel = null;
                });
                if (value != null) {
                  try {
                    await FireStoreUtils.getCarMakes(value.name).then((makes) {
                      setState(() {
                        carMakesList = makes;
                      });
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error loading brands: $e'.tr())),
                    );
                  }
                }
              },
              hint: Text('Select Vehicle Type'.tr()),
              items: vehiclesList.map((VehicleTypeModel item) {
                return DropdownMenuItem<VehicleTypeModel>(
                  child: Text(item.name.toString()),
                  value: item,
                );
              }).toList(),
            ),
          ),
        ),
// Campo: Marca do Veículo
        // Campo: Marca do Veículo
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<VehicleMake>(
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0),
                ),
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
              onChanged: (VehicleMake? value) async {
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
                      SnackBar(content: Text('Error loading models: $e'.tr())),
                    );
                  }
                }
              },
              hint: Text('Select Vehicle Brand'.tr()),
              items: carMakesList.map((VehicleMake item) {
                return DropdownMenuItem<VehicleMake>(
                  child: Text(item.name.toString()),
                  value: item,
                );
              }).toList(),
            ),
          ),
        ),
        // Campo: Modelo do Carro
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<VehicleModel>(
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0),
                ),
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
              items: carModelList.map((VehicleModel item) {
                return DropdownMenuItem<VehicleModel>(
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
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
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
                        borderRadius: BorderRadius.circular(25),
                        shape: BoxShape.rectangle,
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
                          state.didChange(
                              number.phoneNumber); // Atualiza o estado do campo
                        },
                        ignoreBlank: true,
                        autoValidateMode: AutovalidateMode.disabled,
                        inputDecoration: InputDecoration(
                          hintText: 'Phone Number'.tr(),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          isDense: true,
                          errorBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        inputBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG),
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
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
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              obscureText: true,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              controller: _passwordController,
              validator: validatePassword,
              style: TextStyle(fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Password'.tr(),
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
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (val) =>
                  validateConfirmPassword(_passwordController.text, val),
              style: TextStyle(fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Confirm Password'.tr(),
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
                      "Pickup Car proof",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ).tr(),
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
                            heroTag: 'carProfileImage',
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
                      "Pickup Driver proof",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ).tr(),
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
                              ? Image.asset(
                                  "assets/images/img_placeholder.png",
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
                            heroTag: 'driverProfileImage',
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
          padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 40.0),
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
      ],
    );
  }

  String? companyOrNot = "individual";

  /// if the fields are validated and location is enabled we create a new user
  /// and navigate to [ContainerScreen] else we show error
  _signUp() async {
    if (_deliveryKey.currentState?.validate() ?? false) {
      _deliveryKey.currentState!.save();

      await _signUpWithEmailAndPasswordInDeliveryService();
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
        print("Validation failed, activating automatic validation");
      });
    }
  }

  void _showActivationPendingAlert(BuildContext parentContext) {
    print('Showing activation pending alert...');
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Account Created Successfully'.tr()),
          content: Text(
            'Please wait for your account to be activated. You will be notified via email or your phone number once your account is active.'
                .tr(),
          ),
          actions: [
            TextButton(
              child: Text('OK'.tr()),
              onPressed: () {
                try {
                  print('Clicked OK, closing dialog...');
                  Navigator.of(dialogContext).pop(); // Fecha o diálogo
                  print('Dialog closed, redirecting to AuthScreen...');
                  pushAndRemoveUntil(parentContext, AuthScreen(), false);
                  print('Navigation completed successfully.');
                } catch (e, stackTrace) {
                  print('Error redirecting: $e');
                  print('StackTrace: $stackTrace');
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Navigation error: $e'.tr()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    ).catchError((e, stackTrace) {
      print('Error displaying dialog: $e');
      print('StackTrace: $stackTrace');
    });
  }

  _signUpWithEmailAndPasswordInDeliveryService() async {
    await ShowToastDialog.showLoader('Creating new account, Please wait...');

    dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _image,
        _carImage,
        _driverProofPictureURLFile,
        _carProofPictureFile,
        _vehicleController.text,
        _carNameController.text,
        _carMakeController.text,
        _carPlateController.text,
        _firstNameController.text,
        _lastNameController.text,
        _mobileController.text,
        "delivery-service");
    await ShowToastDialog.closeLoader();
    if (result != null && result is User) {
      MyAppState.currentUser = result;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      _showActivationPendingAlert(context);
      // pushAndRemoveUntil(context, AuthScreen(), false);
    } else if (result != null && result is String) {
      showAlertDialog(context, 'Failed'.tr(), result, true);
    } else {
      showAlertDialog(context, 'Failed'.tr(), "Couldn't sign up".tr(), true);
    }
  }

  @override
  void dispose() {
    _autoReloadTimer?.cancel();
    _passwordController.dispose();
    _image = null;
    _carImage = null;
    super.dispose();
  }
}
