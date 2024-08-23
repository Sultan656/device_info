import 'package:flutter/material.dart';
import 'package:user_info/constants/app_colors.dart';
import 'package:user_info/views/menu/menu_view.dart';
import 'package:user_info/views/webauthn/webauthn_view.dart';
import '../device_info_view/device_info_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  WebAuthnView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          height: 78.0,
          width: 307.0,
        ),
      ),
    );
  }
}
