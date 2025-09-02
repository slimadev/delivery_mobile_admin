import 'dart:io';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:easy_localization/easy_localization.dart' as Easy;
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/model/SectionModel.dart';
import 'package:emartdriver/model/VehicleMake.dart';
import 'package:emartdriver/model/VehicleModel.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/services/show_toast_dialog.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/termsAndCondition/terms_and_codition.dart';
import 'package:emartdriver/ui/privacy_policy/privacy_policy.dart';
import 'package:flutter/gestures.dart';
import 'package:emartdriver/model/VehicleTypeModel.dart';
import 'package:emartdriver/repositories/vehicle_make_repository.dart';
import 'package:emartdriver/repositories/vehicle_type_repository.dart';
import 'package:emartdriver/repositories/user_repository.dart';
import 'package:emartdriver/repositories/document_repository.dart';
import 'package:emartdriver/model/DocumentModel.dart';
import 'package:emartdriver/userPrefrence.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emartdriver/userPrefrence.dart';

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
  TextEditingController _passwordController = TextEditingController();

  TextEditingController _carNameController = TextEditingController();
  TextEditingController _carMakeController = TextEditingController();
  TextEditingController _carPlateController = TextEditingController();
  TextEditingController _carColorController = TextEditingController();
  TextEditingController _vehicleController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  GlobalKey<FormState> _deliveryKey = GlobalKey();

  bool isUserImage = true;
  bool _consentChecked = false;
  bool _termsAccepted = false;
  bool _showPassword = false;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  // Variável para controlar o step atual
  int _currentStep = 1;

  @override
  void initState() {
    getCarMakes();
    getVehicles();
    getRequiredDocuments();
    super.initState();
  } // Option 2

  List<VehicleTypeModel> vehiclesList = [];
  List<VehicleMake> carMakesList = [];
  List<VehicleModel> carModelList = [];
  List<SectionModel> sectionsList = [];

  VehicleMake? selectedCarMakes;
  VehicleModel? selectedCarModel;
  VehicleTypeModel? selectedVehicle;
  List<VehicleTypeModel> vehicleType = [];
  VehicleTypeModel? selectedVehicleType;

  List<SectionModel>? sectionsVal = [];
  SectionModel? selectedSection;

  // Lista de documentos necessários
  List<DocumentModel> requiredDocuments = [];
  Map<int, File?> documentFiles = {}; // Mapeia ID do documento para o arquivo

  getVehicles() async {
    await VehicleTypeRepository.getVehicleTypes().then((value) {
      setState(() {
        vehiclesList = value;
      });
    });
  }

  getRequiredDocuments() async {
    try {
      await DocumentRepository.getRequiredDocuments().then((value) {
        setState(() {
          requiredDocuments = value;
          for (var doc in value) {
            documentFiles[doc.id!] = null;
          }
        });
      });
    } catch (e) {
      print('Error loading required documents: $e');
    }
  }

  // Método para selecionar documentos
  void _selectDocument(int documentId) {
    final action = CupertinoActionSheet(
      message: Text(
        'Adicionar ${requiredDocuments.firstWhere((doc) => doc.id == documentId).description}',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? singleImage =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (singleImage != null) {
              setState(() {
                documentFiles[documentId] = File(singleImage.path);
              });
            }
          },
          child: const Text('Escolher da galeria'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            final XFile? singleImage =
                await ImagePicker().pickImage(source: ImageSource.camera);
            if (singleImage != null) {
              setState(() {
                documentFiles[documentId] = File(singleImage.path);
              });
            }
          },
          child: const Text('Tirar foto'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancelar'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  // Método para obter o ícone apropriado para cada tipo de documento
  IconData _getDocumentIcon(String documentDescription) {
    switch (documentDescription.toLowerCase()) {
      case 'bilhete de identidade':
        return Icons.badge;
      case 'registro criminal':
        return Icons.description;
      case 'carta de condução':
        return Icons.credit_card;
      case 'livrete':
        return Icons.directions_car;
      case 'nuit':
        return Icons.business;
      case 'registro criminal':
        return Icons.security;
      default:
        return Icons.description;
    }
  }

  getCarMakes() async {
    await VehicleMakeRepository.getVehicleMakes().then((value) {
      setState(() {
        carMakesList = value;
      });
    });
  }

  // getVehicleModels() async {
  //   await VehicleModelRepository.getVehicleModels().then((value) {
  //     setState(() {
  //       carModelList = value;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      retrieveLostData();
    }
    return WillPopScope(
        onWillPop: () async {
          // Se estiver no Step 2, volta para Step 1
          if (_currentStep == 2) {
            setState(() {
              _currentStep = 1;
            });
            return false; // Não fecha a tela, apenas volta o step
          }
          // Se estiver no Step 1, permite fechar a tela normalmente
          return true;
        },
        child: Scaffold(
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
                    Column(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey.shade200)),
                                      child: InternationalPhoneNumberInput(
                                        onInputChanged: (PhoneNumber number) {
                                          // Capturar apenas o número local, removendo o código do país
                                          String fullNumber =
                                              number.phoneNumber.toString();
                                          String localNumber =
                                              fullNumber.replaceAll(
                                                  number.dialCode ?? '', '');
                                          _mobileController.text = localNumber;
                                        },
                                        ignoreBlank: true,
                                        autoValidateMode:
                                            AutovalidateMode.disabled,
                                        initialValue: PhoneNumber(
                                            isoCode: 'MZ', phoneNumber: ''),
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
                                                PhoneInputSelectorType.DIALOG),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                // padding: const EdgeInsets.only(
                                //     top: 16.0, right: 8.0, left: 8.0),
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: 'Password'.tr(),
                                  hintText: 'Enter your password'.tr(),
                                  prefixIcon: Icon(Icons.lock,
                                      color: Color(COLOR_PRIMARY)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Color(COLOR_PRIMARY), width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required'.tr();
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters'
                                        .tr();
                                  }
                                  return null;
                                },
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
                                      padding:
                                          EdgeInsets.only(top: 12, bottom: 12),
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
                        ),
                      ],
                    ),
                  ] else ...[
                    Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width *
                              0.95, // 95% da largura da tela
                        ),
                        child: Form(
                          key: _deliveryKey,
                          autovalidateMode: _validate,
                          child: formUI(),
                        ),
                      ),
                    ),
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
                ],
              ),
            ),
          ),
        ));
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
        // Indicador de Progresso - Steps (Compacto)
        Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _currentStep >= 1
                      ? Color(COLOR_PRIMARY)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1',
                  style: TextStyle(
                    color:
                        _currentStep >= 1 ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 1,
                color: _currentStep >= 2
                    ? Color(COLOR_PRIMARY)
                    : Colors.grey.shade300,
                margin: EdgeInsets.symmetric(horizontal: 4),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _currentStep >= 2
                      ? Color(COLOR_PRIMARY)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '2',
                  style: TextStyle(
                    color:
                        _currentStep >= 2 ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppThemeData.lightgrey.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.only(top: 6.0, right: 8.0, left: 8.0),
          child: Column(
            children: <Widget>[
              // Step 1: Campos básicos
              if (_currentStep == 1) ...[
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
              ],
              if (_currentStep == 1) ...[
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
                                  // Capturar apenas o número local, removendo o código do país
                                  String fullNumber =
                                      number.phoneNumber.toString();
                                  String localNumber = fullNumber.replaceAll(
                                      number.dialCode ?? '', '');
                                  _mobileController.text = localNumber;
                                  state.didChange(
                                      localNumber); // Atualiza o estado do campo
                                },
                                ignoreBlank: true,
                                autoValidateMode: AutovalidateMode.disabled,
                                initialValue:
                                    PhoneNumber(isoCode: 'MZ', phoneNumber: ''),
                                selectorConfig: SelectorConfig(
                                  selectorType:
                                      PhoneInputSelectorType.BOTTOM_SHEET,
                                  useEmoji: false,
                                  setSelectorButtonAsPrefixIcon: true,
                                ),
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
                                formatInput: true,
                                keyboardType: TextInputType.phone,
                                textFieldController: TextEditingController(),
                                onInputValidated: (bool value) {
                                  // Atualiza o estado de validação
                                  if (value) {
                                    state.didChange(_mobileController.text);
                                  }
                                },
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
                                    fontSize: 11, // Reduzir tamanho da fonte
                                  ),
                                  maxLines: 2, // Permitir 2 linhas
                                  overflow: TextOverflow
                                      .ellipsis, // Truncar se necessário
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (_currentStep == 1) ...[
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
              ],

              if (_currentStep == 1) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                    child: DropdownButtonFormField<VehicleTypeModel>(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 1.0),
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
                      onChanged: (VehicleTypeModel? value) async {
                        setState(() {
                          selectedVehicle = value;
                          // Removida a dependência das marcas do tipo de veículo
                          // carMakesList.clear();
                          // selectedCarMakes = null;
                          carModelList.clear();
                          selectedCarModel = null;
                        });
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
              ],
              if (_currentStep == 1) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                    child: DropdownButtonFormField<VehicleMake>(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 1.0),
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
                      validator: (value) => null, // Campo opcional
                      value: selectedCarMakes,
                      onChanged: (VehicleMake? value) async {
                        setState(() {
                          selectedCarMakes = value;
                          carModelList.clear();
                          selectedCarModel = null;
                        });
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
              ],
              if (_currentStep == 1) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                    child: TextFormField(
                      controller: _carNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Car model is required'.tr();
                        }
                        return null;
                      },
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Color(COLOR_PRIMARY),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Car Model'.tr(),
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
              ],
              if (_currentStep == 1) ...[
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
              ],

              // Checkbox para termos e condições (apenas quando não é login)
              if (!widget.login && _currentStep == 1) ...[
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

              // Step 2: Campos adicionais (como na tela de SignUp)
              if (_currentStep == 2) ...[
                // Campo para foto do perfil
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _onCameraClick(true),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(COLOR_PRIMARY),
                          child: _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.file(
                                    _image!,
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
                              'Foto do Perfil'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Toque para adicionar uma foto'.tr(),
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

                // Campo para foto do carro
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _onCameraClick(false),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(COLOR_PRIMARY),
                          child: _carImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.file(
                                    _carImage!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.directions_car,
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
                              'Foto do Veículo'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Toque para adicionar uma foto'.tr(),
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

                ...requiredDocuments
                    .map((document) => Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, right: 8.0, left: 8.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _selectDocument(document.id!),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(COLOR_PRIMARY),
                                  child: documentFiles[document.id] != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Image.file(
                                            documentFiles[document.id]!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          _getDocumentIcon(
                                              document.description ?? ''),
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
                                      document.description ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Toque para adicionar documento'.tr(),
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
                        ))
                    .toList(),
              ],

              Padding(
                padding: const EdgeInsets.only(
                    right: 8.0, left: 8.0, top: 16.0, bottom: 8),
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
                      _currentStep == 1
                          ? 'Continuar'.tr()
                          : 'Finalizar Cadastro'.tr(),
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

  /// if the fields are validated and location is enabled we create a new user
  /// and navigate to [ContainerScreen] else we show error
  _signUp() async {
    if (widget.login) {
      await _submitPhoneNumber();
    } else {
      if (_currentStep == 1) {
        _goToNextStep();
      } else if (_currentStep == 2) {
        // Step 2: Finalizar cadastro na API externa
        await _finalizeRegistration();
      }
    }
  }

  // Método para ir para o próximo step
  void _goToNextStep() {
    if (_fullNameController.text.trim().isEmpty) {
      ShowToastDialog.showToast('Full name is required'.tr());
      return;
    }
    if (_mobileController.text.isEmpty) {
      ShowToastDialog.showToast('Phone number is required'.tr());
      return;
    }
    if (!_mobileController.text.isEmpty) {
      String? phoneValidation = validateMobile(_mobileController.text);
      if (phoneValidation != null) {
        ShowToastDialog.showToast(phoneValidation);
      }
    }
    if (selectedVehicle == null) {
      ShowToastDialog.showToast('Vehicle type is required'.tr());
      return;
    }
    if (_carNameController.text.trim().isEmpty) {
      ShowToastDialog.showToast('Car model is required'.tr());
      return;
    }
    if (_carPlateController.text.trim().isEmpty) {
      ShowToastDialog.showToast('Car plate is required'.tr());
      return;
    }
    if (!_termsAccepted) {
      ShowToastDialog.showToast(
          'You must accept the terms and conditions'.tr());
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  Future<void> _finalizeRegistration() async {
    try {
      if (_image == null) {
        ShowToastDialog.showToast('Foto do perfil é obrigatória'.tr());
        return;
      }
      if (_carImage == null) {
        ShowToastDialog.showToast('Foto do veículo é obrigatória'.tr());
        return;
      }

      bool allDocumentsAttached = true;
      String missingDocuments = '';

      for (var doc in requiredDocuments) {
        if (documentFiles[doc.id] == null) {
          allDocumentsAttached = false;
          missingDocuments += '${doc.description}, ';
        }
      }

      if (!allDocumentsAttached) {
        ShowToastDialog.showToast(
            'Documentos obrigatórios não anexados: ${missingDocuments.substring(0, missingDocuments.length - 2)}'
                .tr());
        return;
      }

      // Mostrar loader
      ShowToastDialog.showLoader('Finalizando cadastro...'.tr());

      // Converter tipo de veículo para o formato da API

      // Registrar na API
      final result = await UserRepository.registerDriver(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _mobileController.text,
        profileImage: _image,
        vehicleModel: _carNameController.text.trim(),
        registrationNumber: _carPlateController.text.trim(),
        vehicleType: selectedVehicle?.value ?? '',
        vehicleMaker: selectedCarMakes?.id,
        vehiclePhoto: _carImage,
        documents: documentFiles,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();

      ShowToastDialog.closeLoader();

      if (result != null) {
        ShowToastDialog.closeLoader();

        prefs.setBool(REGISTER_FINISHED, true);
        // Mostrar popup de sucesso
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone de sucesso
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 50,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Título
                    Text(
                      'Cadastro Realizado!',
                      style: TextStyle(
                        color: Color(COLOR_PRIMARY),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16),

                    // Mensagem principal
                    Text(
                      'Parabéns! Seu cadastro foi realizado com sucesso.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24),

                    // Informações importantes
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.sms,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Aguarde a mensagem de ativação por SMS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.lock_open,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Após a ativação, você poderá fazer login',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Botão de ação
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(COLOR_PRIMARY),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Ir para Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Erro ao finalizar cadastro. Tente novamente.'.tr());
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Erro: $e'.tr());
      print('Erro ao finalizar cadastro: $e');
    }
  }

  _submitPhoneNumber() async {
    //send code

    if (_mobileController.text.isEmpty) {
      ShowToastDialog.showToast('Phone number is required'.tr());
      return;
    }

    // Validar formato do telefone
    String? phoneValidation = validateMobile(_mobileController.text);
    if (phoneValidation != null) {
      ShowToastDialog.showToast(phoneValidation);
      return; // Não continuar se a validação falhar
    }

    // Verificar se o usuário existe e está ativo antes de enviar código
    try {
      print('login with phone number: ${_mobileController.text}');
      User? user = await UserRepository.login(
          _mobileController.text, _passwordController.text);

      if (user == null) {
        ShowToastDialog.showToast('User not found'.tr());
        return;
      }

      if (user.isActive == false) {
        ShowToastDialog.showToast('This account is not active'.tr());
        return;
      }

      // Salva o token do usuário e vai para ContainerScreen
      UserPreference.setUserToken(token: user.authToken);
      pushAndRemoveUntil(context, ContainerScreen(user: user), false);
    } catch (e) {
      ShowToastDialog.showToast('Error checking user: $e'.tr());
      return;
    }
  }

  @override
  void dispose() {
    _image = null;
    _carImage = null;
    super.dispose();
  }
}
