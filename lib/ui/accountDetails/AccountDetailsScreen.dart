import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/model/VehicleMake.dart';
import 'package:emartdriver/model/VehicleTypeModel.dart';
import 'package:emartdriver/model/VehicleModel.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/ui/reauthScreen/reauth_user_screen.dart';
import 'package:emartdriver/ui/signUp/SignUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';

class AccountDetailsScreen extends StatefulWidget {
  final User user;

  AccountDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AccountDetailsScreenState createState() {
    return _AccountDetailsScreenState();
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late User user;
  GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String? firstName, lastName, carName, carPlate, email, mobile, carColor;

  // New variables for dropdowns
  List<VehicleTypeModel> vehiclesList = [];
  List<VehicleMake> carMakesList = [];
  List<VehicleModel> carModelList = [];
  VehicleTypeModel? selectedVehicle;
  VehicleMake? selectedCarMakes;
  VehicleModel? selectedCarModel;

  // Car colors list
  final List<String> carColors = [
    'Black',
    'White',
    'Silver',
    'Gray',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Brown',
    'Other'
  ];

  @override
  void initState() {
    user = widget.user;
    _loadData();

    super.initState();
  }

  Future<void> _loadData() async {
    // Load vehicle types
    vehiclesList = await FireStoreUtils.getVehicles();
    print(vehiclesList);

    // Load car makes
    carMakesList = await FireStoreUtils.getCarMakes();

    // Set initial values
    setState(() {
      // Find matching vehicle type
      if (user.vehicleType.isNotEmpty) {
        try {
          selectedVehicle = vehiclesList.firstWhere(
            (v) => v.name == user.vehicleType,
          );
        } catch (e) {
          selectedVehicle = vehiclesList.isNotEmpty ? vehiclesList.first : null;
        }
      } else if (vehiclesList.isNotEmpty) {
        selectedVehicle = vehiclesList.first;
      }

      // Find matching car make
      if (user.carMakes.isNotEmpty) {
        try {
          selectedCarMakes = carMakesList.firstWhere(
            (m) => m.name == user.carMakes,
          );
        } catch (e) {
          selectedCarMakes =
              carMakesList.isNotEmpty ? carMakesList.first : null;
        }
      } else if (carMakesList.isNotEmpty) {
        selectedCarMakes = carMakesList.first;
      }

      carColor = user.carColor.isNotEmpty ? user.carColor : carColors.first;
    });

    // Load car models for selected make
    if (selectedCarMakes != null) {
      carModelList =
          await FireStoreUtils.getCarModel(context, selectedCarMakes!.name!);

      // Find matching car model
      if (user.carName.isNotEmpty) {
        try {
          selectedCarModel = carModelList.firstWhere(
            (m) => m.name == user.carName,
          );
        } catch (e) {
          selectedCarModel =
              carModelList.isNotEmpty ? carModelList.first : null;
        }
      } else if (carModelList.isNotEmpty) {
        selectedCarModel = carModelList.first;
      }

      setState(() {}); // Update UI with car models
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(COLOR_PRIMARY),
          title: Text(
            'Account Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ).tr(),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(COLOR_PRIMARY),
                Colors.white,
              ],
              stops: [0.0, 0.3],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
                // Form Content
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _key,
                    autovalidateMode: _validate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildSectionHeader('Public Info'),
                        _buildFormField(
                          icon: Icons.person_outline,
                          label: 'First Name',
                          initialValue: user.firstName,
                          onSaved: (val) => firstName = val,
                          validator: validateName,
                        ),
                        _buildFormField(
                          icon: Icons.person_outline,
                          label: 'Last Name',
                          initialValue: user.lastName,
                          onSaved: (val) => lastName = val,
                          validator: validateName,
                        ),
                        _buildSectionHeader('Vehicle Details'),
                        _buildDropdownField(
                          icon: Icons.directions_car,
                          label: 'Vehicle Type',
                          value: selectedVehicle,
                          items: vehiclesList,
                          onChanged: (VehicleTypeModel? value) {
                            setState(() {
                              selectedVehicle = value;
                            });
                          },
                        ),
                        _buildDropdownField(
                          icon: Icons.branding_watermark,
                          label: 'Car Make',
                          value: selectedCarMakes,
                          items: carMakesList,
                          onChanged: (VehicleMake? value) async {
                            setState(() {
                              selectedCarMakes = value;
                              carModelList.clear();
                              selectedCarModel = null;
                            });
                            if (value != null) {
                              carModelList = await FireStoreUtils.getCarModel(
                                  context, value.name!);
                              setState(() {});
                            }
                          },
                        ),
                        _buildDropdownField(
                          icon: Icons.directions_car,
                          label: 'Car Model',
                          value: selectedCarModel,
                          items: carModelList,
                          onChanged: (VehicleModel? value) {
                            setState(() {
                              selectedCarModel = value;
                            });
                          },
                        ),
                        _buildDropdownField(
                          icon: Icons.color_lens,
                          label: 'Car Color',
                          value: carColor,
                          items: carColors,
                          onChanged: (String? value) {
                            setState(() {
                              carColor = value;
                            });
                          },
                        ),
                        _buildFormField(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Car Plate',
                          initialValue: user.carNumber,
                          onSaved: (val) => carPlate = val,
                          validator: validateEmptyField,
                        ),
                        SizedBox(height: 16),
                        // Legal Documents Section
                        _buildSectionHeader('Legal Documents'.tr()),
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SignUpScreen(fromAccountDetails: true),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: Colors.blue.shade700,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Driver License & Vehicle Documents'
                                                    .tr(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade800,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color:
                                                        Colors.green.shade700,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Complete'.tr(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Update your driver license and vehicle registration documents'
                                              .tr(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.blue.shade600,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildSectionHeader('Private Details'),
                        _buildFormField(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          initialValue: user.email,
                          onSaved: (val) => email = val,
                          validator: validateEmail,
                          enabled: false,
                        ),
                        _buildFormField(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          initialValue: user.phoneNumber,
                          onSaved: (val) => mobile = val,
                          enabled: false,
                        ),
                        SizedBox(height: 24),
                        _buildSaveButton(),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(COLOR_PRIMARY),
        ),
      ).tr(),
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required String? initialValue,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        onSaved: onSaved,
        validator: validator,
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.start,
        initialValue: initialValue,
        enabled: enabled,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode(context) ? Colors.white : Colors.black,
        ),
        cursorColor: Color(COLOR_ACCENT),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(COLOR_PRIMARY)),
          labelText: label.tr(),
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required IconData icon,
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    // Ensure items list is not empty and has unique values
    if (items.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(COLOR_PRIMARY)),
          labelText: label.tr(),
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((T item) {
          String displayText = '';
          if (item is VehicleTypeModel) {
            displayText = item.name ?? '';
          } else if (item is VehicleMake) {
            displayText = item.name ?? '';
          } else if (item is VehicleModel) {
            displayText = item.name ?? '';
          } else {
            displayText = item.toString();
          }
          return DropdownMenuItem<T>(
            value: item,
            child: Text(displayText),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _validateAndSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(COLOR_PRIMARY),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        child: Text(
          'Save',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).tr(),
      ),
    );
  }

  _validateAndSave() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      AuthProviders? authProvider;
      List<auth.UserInfo> userInfoList =
          auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
      await Future.forEach(userInfoList, (auth.UserInfo info) {
        if (info.providerId == 'password') {
          authProvider = AuthProviders.PASSWORD;
        } else if (info.providerId == 'phone') {
          authProvider = AuthProviders.PHONE;
        }
      });
      bool? result = false;
      if (authProvider == AuthProviders.PHONE &&
          auth.FirebaseAuth.instance.currentUser!.phoneNumber != mobile) {
        result = await showDialog(
          context: context,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            phoneNumber: mobile,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context, 'Saving details...'.tr(), false);
          await _updateUser();
          await hideProgress();
        }
      } else if (authProvider == AuthProviders.PASSWORD &&
          auth.FirebaseAuth.instance.currentUser!.email != email) {
        result = await showDialog(
          context: context,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            email: email,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context, 'Saving details...'.tr(), false);
          await _updateUser();
          await hideProgress();
        }
      } else {
        showProgress(context, 'Saving details...'.tr(), false);
        await _updateUser();
        hideProgress();
      }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _updateUser() async {
    user.firstName = firstName!;
    user.lastName = lastName!;
    user.email = email!;
    user.phoneNumber = mobile!;
    user.carNumber = carPlate!;
    user.carName = selectedCarModel?.name ?? '';
    user.carMakes = selectedCarMakes?.name ?? '';
    user.vehicleType = selectedVehicle?.name ?? '';
    user.carColor = carColor ?? '';

    var updatedUser = await FireStoreUtils.updateCurrentUser(user);
    if (updatedUser != null) {
      MyAppState.currentUser = user;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Details saved successfully',
        style: TextStyle(fontSize: 17),
      ).tr()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Couldn't save details, Please try again",
        style: TextStyle(fontSize: 17),
      ).tr()));
    }
  }
}

class VehicleDetailsScreen extends StatefulWidget {
  final User user;

  VehicleDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _VehicleDetailsScreenState createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final TextEditingController _noOfPassengersController =
      TextEditingController();
  final TextEditingController _noOfDoorController = TextEditingController();
  final TextEditingController _maxPowerController = TextEditingController();
  final TextEditingController _mphController = TextEditingController();
  final TextEditingController _topSpeedController = TextEditingController();

  String airConditioning = "Yes";
  String gear = "Manual";
  String fuelFilling = "Full to full";
  String mileage = "Average";
  String fuelType = "Petrol";

  final List<String> fuelFillingList = ['Full to full', 'Half'];
  final List<String> gearList = ['Manual', 'Automatic'];
  final List<String> airConditioningList = ['Yes', 'No'];
  final List<String> mileageList = ['Average', 'Good', 'Excellent'];
  final List<String> fuelTypeList = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
  }

  void _loadVehicleDetails() {
    if (widget.user.carInfo != null) {
      _noOfPassengersController.text = widget.user.carInfo!.passenger ?? '';
      _noOfDoorController.text = widget.user.carInfo!.doors ?? '';
      _maxPowerController.text = widget.user.carInfo!.maxPower ?? '';
      _mphController.text = widget.user.carInfo!.mph ?? '';
      _topSpeedController.text = widget.user.carInfo!.topSpeed ?? '';

      airConditioning = widget.user.carInfo!.airConditioning ?? 'Yes';
      gear = widget.user.carInfo!.gear ?? 'Manual';
      fuelFilling = widget.user.carInfo!.fuelFilling ?? 'Full to full';
      mileage = widget.user.carInfo!.mileage ?? 'Average';
      fuelType = widget.user.carInfo!.fuelType ?? 'Petrol';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(COLOR_PRIMARY),
        title: Text(
          'Additional Vehicle Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ).tr(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(COLOR_PRIMARY),
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField(
                    icon: Icons.people,
                    label: 'Number of Passengers',
                    controller: _noOfPassengersController,
                  ),
                  _buildFormField(
                    icon: Icons.door_front_door,
                    label: 'Number of Doors',
                    controller: _noOfDoorController,
                  ),
                  _buildFormField(
                    icon: Icons.speed,
                    label: 'Max Power',
                    controller: _maxPowerController,
                  ),
                  _buildFormField(
                    icon: Icons.speed,
                    label: 'MPH',
                    controller: _mphController,
                  ),
                  _buildFormField(
                    icon: Icons.speed,
                    label: 'Top Speed',
                    controller: _topSpeedController,
                  ),
                  _buildDropdownField(
                    icon: Icons.ac_unit,
                    label: 'Air Conditioning',
                    value: airConditioning,
                    items: airConditioningList,
                    onChanged: (value) {
                      setState(() {
                        airConditioning = value!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    icon: Icons.settings,
                    label: 'Gear Type',
                    value: gear,
                    items: gearList,
                    onChanged: (value) {
                      setState(() {
                        gear = value!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    icon: Icons.local_gas_station,
                    label: 'Fuel Filling',
                    value: fuelFilling,
                    items: fuelFillingList,
                    onChanged: (value) {
                      setState(() {
                        fuelFilling = value!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    icon: Icons.speed,
                    label: 'Mileage',
                    value: mileage,
                    items: mileageList,
                    onChanged: (value) {
                      setState(() {
                        mileage = value!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    icon: Icons.local_gas_station,
                    label: 'Fuel Type',
                    value: fuelType,
                    items: fuelTypeList,
                    onChanged: (value) {
                      setState(() {
                        fuelType = value!;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveVehicleDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(COLOR_PRIMARY),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).tr(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(COLOR_PRIMARY)),
          labelText: label.tr(),
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    // Ensure items list is not empty and has unique values
    if (items.isEmpty) {
      return SizedBox.shrink();
    }

    // Ensure value exists in items list
    final validValue = items.contains(value) ? value : items.first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: validValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(COLOR_PRIMARY)),
          labelText: label.tr(),
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _saveVehicleDetails() async {
    CarInfo carInfo = CarInfo(
      passenger: _noOfPassengersController.text,
      doors: _noOfDoorController.text,
      maxPower: _maxPowerController.text,
      mph: _mphController.text,
      topSpeed: _topSpeedController.text,
      airConditioning: airConditioning,
      gear: gear,
      fuelFilling: fuelFilling,
      mileage: mileage,
      fuelType: fuelType,
      carImage: widget.user.carInfo?.carImage ?? [],
    );

    widget.user.carInfo = carInfo;
    var updatedUser = await FireStoreUtils.updateCurrentUser(widget.user);

    if (updatedUser != null) {
      MyAppState.currentUser = widget.user;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Vehicle details saved successfully',
          style: TextStyle(fontSize: 17),
        ).tr(),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Couldn't save vehicle details, Please try again",
          style: TextStyle(fontSize: 17),
        ).tr(),
      ));
    }
  }
}
