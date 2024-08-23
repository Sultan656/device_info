import 'dart:convert';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:ip_country_lookup/ip_country_lookup.dart';
import 'package:ip_country_lookup/models/ip_country_data_model.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_info/constants/app_colors.dart';
import 'package:user_info/constants/web_authn.dart';
import 'package:user_info/ipwhois_service.dart';
import 'package:user_info/models/ipwhois_model.dart';
import 'package:user_info/models/otp_response_model.dart';
import 'package:user_info/models/otp_status_request_model.dart';
import 'package:user_info/service/web_authn_service.dart';
import 'package:user_info/views/channel_rates/channel_rates_view.dart';
import 'package:user_info/views/menu/menu_view.dart';
import 'package:user_info/widgets/app_button.dart';
import 'package:user_info/widgets/app_textfield.dart';
import 'package:webauthn/webauthn.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  Map<String, dynamic>? _deviceData;
  String? _macAddress;
  IpWhoIsModel? _ipDetails;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final WebAuthnService authService = WebAuthnService();

  // Define FocusNodes for each text field
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  String? _otpStatusResponse;
  String? _changeIn;
  String? _errorMessage;
  bool _isLoading = false;
  String? authData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeviceData();
    });
  }

  @override
  void dispose() {
    // Don't forget to dispose the focus nodes to avoid memory leaks
    _nameFocus.dispose();
    _numberFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _initDeviceData() async {
    await _fetchDeviceData();
    await _fetchNetworkData();
    await _fetchIpDetails();

  }


  Future<void> _fetchDeviceData() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData;

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = _readAndroidBuildData(androidInfo);
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = _readIosDeviceInfo(iosInfo);
      } else {
        deviceData = {"Error": "Unsupported platform"};
      }
    } catch (e) {
      deviceData = {"Error": "Failed to get platform version: '${e.toString()}'"};
    }

    if (mounted) {
      setState(() {
        _deviceData = deviceData;
      });
    }
  }

  Future<void> _fetchNetworkData() async {
    final info = NetworkInfo();
    String? macAddress;

    try {
      macAddress = await info.getWifiBSSID(); // WiFi BSSID often serves as MAC address

    } catch (e) {
      macAddress = "Error fetching MAC address";
    }

    if (mounted) {
      setState(() {
        _macAddress = macAddress;
      });
    }
  }



  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return {
      'Brand': build.brand,
      'Display': build.display,
      'Fingerprint': build.fingerprint,
      'Hardware': build.hardware,
      'Manufacturer': build.manufacturer,
      'Model': build.model,
      'Android ID': build.id,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return {
      'Name': data.name,
      'System Name': data.systemName,
      'System Version': data.systemVersion,
      'Model': data.model,
      'Localized Model': data.localizedModel,
      'Identifier for Vendor': data.identifierForVendor,
      'Machine': data.utsname.machine,
    };
  }

  _fetchIpDetails() async {
    final IpWhoisService ipWhoisService = IpWhoisService();
    setState(() {
      _ipDetails = null; // Reset IP details before fetching new ones
    });

    try {
      final ipDetailsResponse = await ipWhoisService.fetchIpWhoisDetails();
      setState(() {
        _ipDetails = ipDetailsResponse;
      });
    } catch (e) {
      setState(() {
        _ipDetails = IpWhoIsModel(ip: 'Error', country: 'Error'); // Use a placeholder on error
      });
    }
  }

  Future<void> _fetchOtpStatus() async {
    setState(() {
      _errorMessage = null;
      _otpStatusResponse = null;
      _isLoading = true;
    });

    OtpStatusRequestModel requestModel = OtpStatusRequestModel(
      iP: _ipDetails?.ip ?? 'Unknown',
      androidID: _deviceData?['Android ID'] ?? 'Unknown',
      manufacturer: _deviceData?['Manufacturer'] ?? 'Unknown',
      modelNo: _deviceData?['Model'] ?? 'Unknown',
      hardware: _deviceData?['Hardware'] ?? 'Unknown',
      macAddress: _macAddress ?? 'Unknown',
      iEMI: 'imei', // This should be fetched properly if needed
      userName: _nameController.text,
      phoneNo: _numberController.text,
      emailId: _emailController.text ,
      city: _ipDetails?.city ?? 'Unknown',
      geoLocation: _ipDetails?.country ?? 'Unknown',
      brand: _deviceData?['Brand'] ?? 'Unknown',
      fingerprint: _deviceData?['Fingerprint'] ?? 'Unknown',
    );

    try {
      OtpStatusResponseModel response = await IpWhoisService().otpStatus(requestModel);
      setState(() {
        _otpStatusResponse = response.response;
        _changeIn = response.changeIn;
        _isLoading = false;

      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Container(
          color: AppColors.tableBgColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          color: AppColors.tableBgColor,

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(value),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: SafeArea(
        child: Stack(
          children:[ SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                // This will dismiss the keyboard when tapping outside of a text field
                FocusManager.instance.primaryFocus?.unfocus();
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Row(
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
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    appTextField(
                        controller: _nameController,
                        title: 'Name',
                        keyboardType: TextInputType.name,
                        focusNode: _nameFocus,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _nameFocus, _numberFocus);
                        }
                    ),
                    appTextField(
                      controller: _numberController,
                      title: 'Phone No',
                      keyboardType: TextInputType.phone,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, _numberFocus, _emailFocus);
                      },
                    ),
                    appTextField(
                      controller: _emailController,
                      title: 'Email',
                      keyboardType: TextInputType.name,
                      focusNode: _emailFocus,
                      onFieldSubmitted: (term) {
                        _emailFocus.unfocus();
                      },
                    ),
                    const SizedBox(height: 22.0,),
                    appButton(
                      title: 'Verify User',
                      onTap: (){
                        // This line dismisses the keyboard
                        FocusScope.of(context).unfocus();

                        _fetchOtpStatus();
                        setState(() {

                        });
                      },
                    ),
                    const SizedBox(height: 10.0,),
                    _otpStatusResponse != null ? (
                        _otpStatusResponse == 'no send otp' ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildInfoContainer(
                            'Returning User',
                            'OTP has not been sent',
                            AppColors.appButtonColor,
                          ),
                        ) : _otpStatusResponse == 'send otp' ? (
                            _changeIn == 'device and geolocation change' ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildInfoContainer(
                                'Returning User / Geolocation and Device Info Changed',
                                'OTP has been sent',
                                AppColors.redColor,
                              ),
                            ) : _changeIn == 'device value changed' ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildInfoContainer(
                                'Returning User / Device Info Changed',
                                'OTP has been sent',
                                AppColors.redColor,
                              ),
                            ) : _changeIn == 'geolocation' ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildInfoContainer(
                                'Returning User / GEO Location Changed',
                                'OTP has been sent',
                                AppColors.redColor,
                              ),
                            ) : const SizedBox.shrink()
                        ) : _otpStatusResponse == 'new_user_send_otp' ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildInfoContainer(
                            'New User',
                            'OTP has been sent',
                            AppColors.redColor,
                          ),
                        ) : const SizedBox.shrink()
                    ) : const SizedBox.shrink(),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error: $_errorMessage',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(height: 16.0,),
                    const Text("Device Information",style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w700),),
                    const SizedBox(height: 10.0,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        border: TableBorder.all(color: AppColors.textFieldOutline, width: 1),
                        children: [
                          if (_deviceData != null)
                            ..._deviceData!.entries.map(
                                  (entry) => _buildTableRow(entry.key, entry.value.toString()),
                            ),
                          if (_macAddress != null)
                            _buildTableRow('MAC Address', _macAddress!),
                          if (_ipDetails != null && _ipDetails!.ip != null)
                            _buildTableRow('IP Address', _ipDetails!.ip!),
                          if (_ipDetails != null)
                            _buildTableRow('City', _ipDetails!.city!),
                          if (_ipDetails != null)
                            _buildTableRow('Country', _ipDetails!.country!),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10.0,),
                  ],
                ),
              ),
            ),
          ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.appButtonColor,), // Loading indicator at the center
              ),
          ]
        ),
      ),
    );
  }
  // Helper function to change focus
  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
Widget _buildInfoContainer(String title, String subtitle, Color color) {
  return Container(
    width: 373.0,
    height: 60.0,
    decoration: BoxDecoration(
      border: Border.all(color: color),
      color: color.withOpacity(0.50),
      borderRadius: BorderRadius.circular(4.0),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}