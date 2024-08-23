import 'package:flutter/material.dart';
import 'package:user_info/constants/app_colors.dart';
import 'package:user_info/ipwhois_service.dart';
import 'package:user_info/models/get_all_channel_price.dart';
import 'package:user_info/models/update_channel_price.dart';
import 'package:user_info/views/menu/menu_view.dart';
import 'package:user_info/widgets/app_button.dart';
import 'package:user_info/widgets/app_textfield.dart';

class ChannelRatesView extends StatefulWidget {
  const ChannelRatesView({super.key});

  @override
  State<ChannelRatesView> createState() => _ChannelRatesViewState();
}

class _ChannelRatesViewState extends State<ChannelRatesView> {
  // Initialize controllers without referencing each other
  //these controllers will be used in prices text fields
  final TextEditingController _whatsAppController = TextEditingController();
  final TextEditingController _voiceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();


  @override
  void initState() {
    super.initState();
    //calling API here "_loadChannelPrices()" to load the prices on initialization of screen
    Future.microtask(() => _loadChannelPrices());
  }

  //creating function _loadChannelPrices() to call the getAllChannelPrice which will return the prices of channels
  Future<void> _loadChannelPrices() async {
    try {
      //calling and saving list of object for each channel in prices variable
      List<GetAllChannelPriceResponse> prices = await IpWhoisService().getAllChannelPrice();

      //applied a loop here on prices so when can extract the each channel price and initialize to their controllers
      for (var price in prices) {
      //switch is called inside a set State so we can rebuild the UI
        setState(() {
          switch (price.channel) {
            case 'sms':
              _smsController.text = price.price.toString();
              break;
            case 'whatsapp':
              _whatsAppController.text = price.price.toString();
              break;
            case 'voice':
              _voiceController.text = price.price.toString();
              break;
            case 'email':
              _emailController.text = price.price.toString();
              break;
            default:
              break;
          }
        });

      } //calling catch if API is not called successfully
    } catch (e) {
      print('Error fetching channel prices: $e');
    }
  }

  //creating function updateChannelPrice() to call the API for updating the channel prices
  void updateChannelPrice() async {
    // Create a list of UpdateChannelPriceRequest, assuming you might be updating multiple channels
    //IDs are placed as static as it will not change in any case
    //username and password is also static as we are not using it on the UI
    List<UpdateChannelPriceRequest> requests = [
      UpdateChannelPriceRequest(channel: 'sms', price: double.tryParse(_smsController.text) ?? 0, username: 'string', password: 'string', id: 1),
      UpdateChannelPriceRequest(channel: 'whatsapp', price: double.tryParse(_whatsAppController.text) ?? 0, username: 'string', password: 'string', id: 2),
      UpdateChannelPriceRequest(channel: 'voice', price: double.tryParse(_voiceController.text) ?? 0, username: 'string', password: 'string', id: 3),
      UpdateChannelPriceRequest(channel: 'email', price: double.tryParse(_emailController.text) ?? 0, username: 'string', password: 'string', id: 4),
    ];

    // Update each channel price one by one (this can be optimized based on API capabilities)
    bool success = await IpWhoisService().updateChannelPrice(requests);
    //if API return true so a modal will open to show success message that price has been updated successfully
    if (success) {
      //context.mounted is used to avoid warning "don't use context inside async function"
      if ( context.mounted){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Channel prices have been successfully updated.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  //to close the modal when pressed OK button
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );}
      //if API return false than an ERROR dialog will open to show the message "Failed to update channel prices"
    } else {
      //context.mounted is used to avoid warning "don't use context inside async function"

      if(context.mounted){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to update channel prices.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  //to close the modal when pressed OK button
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );}
    }
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
                const SizedBox(height: 40.0),

                //app logo at the top on the screen
                Row(
                  children: [
                    InkWell(
                        onTap:(){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>  const MenuView()),
                          );
                        },
                        child: Image.asset('assets/images/arrow_back.png', width: 30, height: 30)),
                    const Spacer(),
                    Image.asset('assets/images/app_logo.png', width: 131, height: 33),
                    const Spacer(flex: 2,),
                  ],
                ),

                const SizedBox(height: 40.0),
                const Text('Channel Rates',style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor)),
                const SizedBox(height: 7.0),


                //use custom text fields for price channels
                appTextField(controller: _smsController, title: 'SMS'),
                appTextField(controller: _whatsAppController, title: 'WhatsApp'),
                appTextField(controller: _voiceController, title: 'Voice'),
                appTextField(controller: _emailController, title: 'E-mail'),
                const SizedBox(height: 40.0),
                appButton(title: 'Update', onTap: () {
                  //calling the function updateChannelPrice to call price update API
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
