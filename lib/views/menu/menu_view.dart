import 'package:flutter/material.dart';
import 'package:user_info/views/channel_rates/channel_rates_view.dart';
import 'package:user_info/views/device_info_view/device_info_view.dart';
import 'package:user_info/widgets/app_button.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const SizedBox(height: 40.0),
              Image.asset('assets/images/app_logo.png',height: 33.0,width: 131.0,),
              const SizedBox(height: 20.0,),
              appButton(title: 'OTP Request', onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeviceInfoScreen()),
                );
              }),
              const SizedBox(height: 15.0,),
              appButton(title: 'Channel Rates',onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChannelRatesView()),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}