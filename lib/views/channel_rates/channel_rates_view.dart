import 'package:flutter/material.dart';
import 'package:user_info/widgets/app_button.dart';
import 'package:user_info/widgets/app_textfield.dart';

class ChannelRatesView extends StatelessWidget {
  const ChannelRatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                const SizedBox(height: 40.0),
                Image.asset('assets/images/app_logo.png',height: 33.0,width: 131.0,),
                const SizedBox(height: 20.0,),
                appTextField(title: 'SMS'),
                appTextField(title: 'WhatsApp'),
                appTextField(title: 'Voice'),
                appTextField(title: 'E-mail'),
                const SizedBox(height: 40.0,),
                appButton(title: 'Update', onTap: (){

                }),

              ],
            ),
          ),
        ),
      ),
    );
  }
}