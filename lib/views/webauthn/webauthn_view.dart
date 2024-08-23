import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_info/constants/app_colors.dart';
import 'package:user_info/service/web_authn_service.dart';
import 'package:user_info/widgets/app_button.dart';
import 'package:user_info/widgets/app_textfield.dart';

class WebAuthnView extends StatefulWidget {
  const WebAuthnView({super.key});

  @override
  State<WebAuthnView> createState() => _WebAuthnViewState();
}

class _WebAuthnViewState extends State<WebAuthnView> {
  // Initialize controllers without referencing each other
  //these controllers will be used in prices text fields
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final WebAuthnService authService = WebAuthnService();

  Future<void> _initWebAuthnLogin() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final credentialId = prefs.getString('credentialId');

    if(credentialId != null){
      //calling webauthn login on init if user registered
      authService.getAssertion(context, credentialId);
    }
  }

  @override
  void initState() {
    super.initState();
    _initWebAuthnLogin();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0),
                //app logo at the top on the screen
                Center(child: Image.asset('assets/images/app_logo.png', height: 33.0, width: 131.0)),
                const SizedBox(height: 40.0),
                const Text('Please login into your account',style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor)),
                const SizedBox(height: 20.0),

                //using custom text fields for for user name and password
                appTextField(controller: _userNameController, title: 'User Name'),
                appTextField(controller: _passwordController, title: 'Password'),

                const SizedBox(height: 40.0),
                appButton(title: 'Login', onTap: () {}),
                const SizedBox(height: 20.0,),
                appButton(
                    bgColor: AppColors.purpleColor,
                    title: 'Register', onTap: () {
                      //calling webauthn registration function
                      authService.createCredentials(context);
                      //set state to update the UI
                      setState(() {

                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
