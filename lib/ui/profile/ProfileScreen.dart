import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/services/show_toast_dialog.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/accountDetails/AccountDetailsScreen.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/ui/contactUs/ContactUsScreen.dart';
import 'package:emartdriver/ui/container/ContainerScreen.dart';
import 'package:emartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:emartdriver/ui/reauthScreen/reauth_user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emartdriver/ui/settings/SettingsScreen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late User user;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeData.grey50,
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            // Header com gradiente
            Container(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 16, right: 16, bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.green,
                    AppThemeData.green.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContainerScreen(user: user),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Text(
                      'My Profile'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: AppThemeData.regular,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48), // Para centralizar o título
                ],
              ),
            ),

            // Seção de fotos
            Container(
              margin: EdgeInsets.only(top: 16, left: 16, right: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Text(
                  //   'Profile Photos'.tr(),
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                  // SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImageSection(
                        imageUrl: user.profilePictureURL,
                        title: 'Personal Photo'.tr(),
                        onTap: () => _onCameraClick(true),
                        isUserImage: true,
                      ),
                      _buildImageSection(
                        imageUrl: user.carPictureURL,
                        title: 'Vehicle Photo'.tr(),
                        onTap: () => _onCameraClick(false),
                        isUserImage: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Opções do perfil
            Container(
              margin: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 4,
                child: Column(
                  children: [
                    _buildProfileOption(
                      icon: CupertinoIcons.person_alt,
                      title: 'Account Details'.tr(),
                      subtitle: 'Edit personal information'.tr(),
                      color: Colors.blue,
                      onTap: () =>
                          push(context, AccountDetailsScreen(user: user)),
                    ),
                    Divider(height: 1, indent: 60, endIndent: 16),
                    _buildProfileOption(
                      icon: CupertinoIcons.settings,
                      title: 'Settings'.tr(),
                      subtitle: 'App preferences and notifications'.tr(),
                      color: Colors.orange,
                      onTap: () => push(context, SettingsScreen(user: user)),
                    ),
                    Divider(height: 1, indent: 60, endIndent: 16),
                    _buildProfileOption(
                      icon: CupertinoIcons.phone_solid,
                      title: 'Contact Us'.tr(),
                      subtitle: 'Contact support'.tr(),
                      color: Colors.green,
                      onTap: () => push(context, ContactUsScreen()),
                    ),
                    Divider(height: 1, indent: 60, endIndent: 16),
                    _buildProfileOption(
                      icon: CupertinoIcons.delete,
                      title: 'Delete Account'.tr(),
                      subtitle: 'Remove account permanently'.tr(),
                      color: Colors.red,
                      onTap: () => showDeleteAccountAlertDialog(context),
                    ),
                  ],
                ),
              ),
            ),

            // Botão de logout
            Container(
              margin: EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.newBlack.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppThemeData.newBlack),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  user.isActive = false;
                  user.lastOnlineTimestamp = Timestamp.now();
                  await FireStoreUtils.updateCurrentUser(user);
                  await auth.FirebaseAuth.instance.signOut();
                  MyAppState.currentUser = null;
                  pushAndRemoveUntil(
                      context, PhoneNumberInputScreen(login: false), false);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Logout'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildImageSection({
    required String imageUrl,
    required String title,
    required VoidCallback onTap,
    required bool isUserImage,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(COLOR_PRIMARY), width: 3),
              ),
              child: ClipOval(
                child: isUserImage
                    ? displayCircleImage(imageUrl, 100, false)
                    : displayCarImage(imageUrl, 100, false),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(COLOR_PRIMARY),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: onTap,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
      onTap: onTap,
    );
  }

  Future<void> showDeleteAccountAlertDialog(BuildContext context) async {
    final reasons = [
      'Technical issues'.tr(),
      'Few ride offers'.tr(),
      'Privacy concerns'.tr(),
      'Other'.tr(),
    ];
    String? selectedReason;
    TextEditingController otherController = TextEditingController();
    bool isDeleting = false;

    await showDialog(
      context: context,
      barrierDismissible: !isDeleting,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Delete Account').tr(),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...reasons.map((reason) => RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: Color(0xFF82C100), // Verde
                        title:
                            Text(reason, style: TextStyle(fontSize: 15)).tr(),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: isDeleting
                            ? null
                            : (value) {
                                setState(() {
                                  selectedReason = value;
                                });
                              },
                      )),
                  if (selectedReason == 'Outro' || selectedReason == 'Other')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: otherController,
                        enabled: !isDeleting,
                        decoration: InputDecoration(
                          labelText: 'Please specify'.tr(),
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        maxLines: 2,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isDeleting ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF82C100), // Verde
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    textStyle: TextStyle(fontSize: 15),
                  ),
                  child: Text('Cancelar'.tr()),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: isDeleting || selectedReason == null
                      ? null
                      : () async {
                          setState(() => isDeleting = true);
                          final reason = (selectedReason == 'Outro' ||
                                  selectedReason == 'Other')
                              ? otherController.text.trim()
                              : selectedReason!;
                          user.isActive = false;
                          user.active = false;
                          user.deleteReason = reason;
                          user.deletedAt = DateTime.now().toIso8601String();
                          user.lastOnlineTimestamp = Timestamp.now();
                          await FireStoreUtils.updateCurrentUser(user);
                          await auth.FirebaseAuth.instance.signOut();
                          MyAppState.currentUser = null;
                          Navigator.pop(context);
                          pushAndRemoveUntil(context,
                              PhoneNumberInputScreen(login: false), false);
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    textStyle: TextStyle(fontSize: 15),
                  ),
                  child: Text('Delete'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  _onCameraClick(bool isUserImage) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  XFile? image =
                      await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await _imagePicked(File(image.path), isUserImage);
                  }
                  setState(() {});
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  XFile? image =
                      await _imagePicker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    await _imagePicked(File(image.path), isUserImage);
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _imagePicked(File image, bool isUserImage) async {
    showProgress(
        context,
        isUserImage ? 'Uploading image...'.tr() : 'Uploading car image...'.tr(),
        false);
    if (isUserImage)
      user.profilePictureURL =
          await FireStoreUtils.uploadUserImageToFireStorage(image, user.userID);
    else
      user.carPictureURL =
          await FireStoreUtils.uploadCarImageToFireStorage(image, user.userID);
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    setState(() {});
    hideProgress();
  }
}
