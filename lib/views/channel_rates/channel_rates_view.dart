import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user_info/ipwhois_service.dart';
import 'package:user_info/models/get_all_channel_price.dart';
import 'package:user_info/models/update_channel_price.dart';
import 'package:user_info/widgets/app_button.dart';
import 'package:user_info/widgets/app_textfield.dart';

class ChannelRatesView extends StatefulWidget {
  const ChannelRatesView({super.key});

  @override
  State<ChannelRatesView> createState() => _ChannelRatesViewState();
}

class _ChannelRatesViewState extends State<ChannelRatesView> {
  // Initialize controllers without referencing each other
  final TextEditingController _whatsAppController = TextEditingController();
  final TextEditingController _voiceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  Map<String, int> channelIds = {};
  @override
  void initState() {
    super.initState();
    _emailController.text = _smsController.text; // You can set this here if needed initially
    Future.microtask(() => _loadChannelPrices());
  }

  Future<void> _loadChannelPrices() async {
    try {
      List<GetAllChannelPriceResponse> prices = await IpWhoisService().getAllChannelPrice();
      print('Prices loaded: ${json.encode(prices)}');
      for (var price in prices) {

        setState(() {
          switch (price.channel) {
            case 'sms':
              _smsController.text = price.price.toString();
              channelIds['sms'] = price.id!;
              break;
            case 'whatsapp':
              _whatsAppController.text = price.price.toString();
              channelIds['whatsapp'] = price.id!;
              break;
            case 'voice':
              _voiceController.text = price.price.toString();
              channelIds['voice'] = price.id!;
              break;
            case 'email':
              _emailController.text = price.price.toString();
              channelIds['email'] = price.id!;
              break;
            default:
              break;
          }
        });

      }
    } catch (e) {
      print('Error fetching channel prices: $e');
    }
  }
  void updateChannelPrice() async {
    // Create a list of UpdateChannelPriceRequest, assuming you might be updating multiple channels
    List<UpdateChannelPriceRequest> requests = [
      UpdateChannelPriceRequest(channel: 'sms', price: double.tryParse(_smsController.text) ?? 0, username: 'string', password: 'string', id: 1),
      UpdateChannelPriceRequest(channel: 'whatsapp', price: double.tryParse(_whatsAppController.text) ?? 0, username: 'string', password: 'string', id: 2),
      UpdateChannelPriceRequest(channel: 'voice', price: double.tryParse(_voiceController.text) ?? 0, username: 'string', password: 'string', id: 3),
      UpdateChannelPriceRequest(channel: 'email', price: double.tryParse(_emailController.text) ?? 0, username: 'string', password: 'string', id: 4),
    ];

    // Update each channel price one by one (this can be optimized based on API capabilities)
    bool success = await IpWhoisService().updateChannelPrice(requests);
    if (success) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Channel prices have been successfully updated.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update channel prices.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

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
                Image.asset('assets/images/app_logo.png', height: 33.0, width: 131.0),
                const SizedBox(height: 20.0),
                appTextField(controller: _smsController, title: 'SMS'),
                appTextField(controller: _whatsAppController, title: 'WhatsApp'),
                appTextField(controller: _voiceController, title: 'Voice'),
                appTextField(controller: _emailController, title: 'E-mail'),
                const SizedBox(height: 40.0),
                appButton(title: 'Update', onTap: () {
                  // var request = UpdateChannelPriceRequest(
                  //   username: "string",
                  //   password: "string",
                  //   channel: 'sms', // For example; adapt as needed
                  //   price: int.tryParse(_smsController.text) ?? 0,
                  // );
                  updateChannelPrice();

                  // Optionally handle update action here
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
