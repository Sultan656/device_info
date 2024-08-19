import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:ip_country_lookup/ip_country_lookup.dart';
import 'package:ip_country_lookup/models/ip_country_data_model.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user_info/constants/app_colors.dart';
import 'package:user_info/ipwhois_service.dart';
import 'package:user_info/models/ipwhois_model.dart';
import 'package:user_info/models/otp_response_model.dart';
import 'package:user_info/models/otp_status_request_model.dart';
import 'package:user_info/widgets/app_button.dart';
import 'package:user_info/widgets/app_textfield.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  Map<String, dynamic>? _deviceData;
  String? _macAddress;
  String? _country;
  IpWhoIsModel? _ipDetails;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  String? _otpStatusResponse;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeviceData();
    });
  }

  Future<void> _initDeviceData() async {
    await _requestPermissions();
    await _fetchDeviceData();
    await _fetchNetworkData();
    await _fetchIpDetails();
  }

  Future<void> _requestPermissions() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      await [
        Permission.phone,
        Permission.locationWhenInUse,
        Permission.bluetooth,
        Permission.bluetoothScan,
      ].request();
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      await [
        Permission.location,
        Permission.bluetooth,
      ].request();
    }
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
    String? ipAddress;

    try {
      macAddress = await info.getWifiBSSID(); // WiFi BSSID often serves as MAC address
      ipAddress = await info.getWifiIP();
      if (ipAddress != null) {
        await _fetchCountryAndIsp(ipAddress);
      }
    } catch (e) {
      macAddress = "Error fetching MAC address";
      ipAddress = "Error fetching IP address";
    }

    if (mounted) {
      setState(() {
        _macAddress = macAddress;
      });
    }
  }

  Future<void> _fetchCountryAndIsp(String ipAddress) async {
    try {
      IpCountryData countryData = await IpCountryLookup().getIpLocationData();
      if (mounted) {
        setState(() {
          _country = countryData.country_name;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _country = "Error fetching country";
        });
      }
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
      geoLocation: _country ?? 'Unknown',
      brand: _deviceData?['Brand'] ?? 'Unknown',
      fingerprint: _deviceData?['Fingerprint'] ?? 'Unknown',
    );
    print("payload=====${json.encode(requestModel)}");

    try {
      OtpStatusResponseModel response = await IpWhoisService().otpStatus(requestModel);
      setState(() {
        _otpStatusResponse = response.response;

      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
        child: SingleChildScrollView(
          child: Column(
         //   crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Image.asset('assets/images/app_logo.png', width: 131, height: 33),
                ),
              ),
              const Text("Device Information",style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w700),),
              const SizedBox(height: 10.0,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
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
                    if (_country != null)
                      _buildTableRow('Country', _country!),
                  ],
                ),
              ),
              const SizedBox(height: 16.0,),
              appTextField(
                controller: _nameController,
                title: 'Name',
                keyboardType: TextInputType.name,
              ),
              appTextField(
                controller: _numberController,
                title: 'Phone No',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 22.0,),
              appButton(
                title: 'Verify User',
                onTap: (){
                  _fetchOtpStatus();
                  setState(() {

                  });
                },
              ),
              const SizedBox(height: 10.0,),
              if (_otpStatusResponse != null && _otpStatusResponse == 'no send otp')

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 373.0,
                    height: 60.0 ,
                   decoration: BoxDecoration(border: Border.all(color: AppColors.appButtonColor),
                     color: AppColors.appButtonColor.withOpacity(0.60),
                     borderRadius: BorderRadius.circular(4.0),
                   ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Returning User',
                            style:  TextStyle(fontSize: 12,color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'OTP has not been sent',
                            style:  TextStyle(fontSize: 12,color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if(_otpStatusResponse != null && _otpStatusResponse == 'new_user_send_otp')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 373.0,
                    height: 60.0 ,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.redColor),
                      color: AppColors.redColor.withOpacity(0.50),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New User',
                            style:  TextStyle(fontSize: 12,color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'OTP has been sent',
                            style:  TextStyle(fontSize: 12,color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
