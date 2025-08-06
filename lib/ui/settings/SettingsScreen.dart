import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/theme/app_them_data.dart';
import 'package:emartdriver/ui/Language/language_choose_screen.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late User user;
  late bool pushNewMessages, orderUpdates, newArrivals, promotions;

  @override
  void initState() {
    user = widget.user;
    pushNewMessages = user.settings.pushNewMessages;
    orderUpdates = user.settings.orderUpdates;
    newArrivals = user.settings.newArrivals;
    promotions = user.settings.promotions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeData.grey50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppThemeData.green,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.green,
                    AppThemeData.green.withOpacity(0.8)
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.settings,
                      size: 40,
                      color: AppThemeData.green,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Driver Settings',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Settings Sections
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Notifications Section
                  _buildSettingsSection(
                    title: 'Notifications',
                    icon: Icons.notifications_outlined,
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_active,
                        title: 'Push Notifications',
                        subtitle: 'Receive notifications on your device',
                        value: pushNewMessages,
                        onChanged: (value) {
                          setState(() {
                            pushNewMessages = value;
                          });
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.local_shipping,
                        title: 'Order Updates',
                        subtitle: 'Get notified about order status changes',
                        value: orderUpdates,
                        onChanged: (value) {
                          setState(() {
                            orderUpdates = value;
                          });
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.local_offer,
                        title: 'Promotions',
                        subtitle: 'Receive promotional offers and discounts',
                        value: promotions,
                        onChanged: (value) {
                          setState(() {
                            promotions = value;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // App Settings Section
                  _buildSettingsSection(
                    title: 'App Settings',
                    icon: Icons.app_settings_alt_outlined,
                    children: [
                      _buildListTile(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'Change app language',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LanguageChooseScreen(isContainer: false),
                            ),
                          );
                        },
                      ),
                      // _buildListTile(
                      //   icon: Icons.dark_mode_outlined,
                      //   title: 'Dark Mode',
                      //   subtitle: 'Toggle dark/light theme',
                      //   trailing: Switch(
                      //     value: isDarkMode(context),
                      //     onChanged: (value) {
                      //       // TODO: Implement dark mode toggle
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text('Dark mode feature coming soon!'),
                      //           duration: Duration(seconds: 2),
                      //         ),
                      //       );
                      //     },
                      //     activeColor: AppThemeData.green,
                      //   ),
                      // ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Account Section
                  _buildSettingsSection(
                    title: 'Account',
                    icon: Icons.account_circle_outlined,
                    children: [
                      _buildListTile(
                        icon: Icons.info_outline,
                        title: 'App Version',
                        subtitle: 'Version 1.0.2',
                        onTap: null,
                      ),
                      _buildListTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                        onTap: () {
                          // TODO: Navigate to help screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Help & Support coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  // Save Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeData.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemeData.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppThemeData.green,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ).tr(),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppThemeData.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppThemeData.green,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ).tr(),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ).tr(),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppThemeData.green,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppThemeData.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppThemeData.green,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ).tr(),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ).tr(),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ),
      onTap: onTap,
    );
  }

  Future<void> _saveSettings() async {
    showProgress(context, 'Saving changes...'.tr(), true);

    user.settings.pushNewMessages = pushNewMessages;
    user.settings.orderUpdates = orderUpdates;
    user.settings.newArrivals = newArrivals;
    user.settings.promotions = promotions;

    User? updateUser = await FireStoreUtils.updateCurrentUser(user);
    hideProgress();

    if (updateUser != null) {
      this.user = updateUser;
      MyAppState.currentUser = user;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: AppThemeData.green,
          content: Text(
            'Settings saved successfully',
            style: TextStyle(fontSize: 17),
          ).tr(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          content: Text(
            'Failed to save settings',
            style: TextStyle(fontSize: 17),
          ).tr(),
        ),
      );
    }
  }
}
