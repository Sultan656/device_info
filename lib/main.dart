import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bluetooth_info/bluetooth_info.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:ip_country_lookup/models/ip_country_data_model.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ip_country_lookup/ip_country_lookup.dart';
import 'package:public_ip_address/public_ip_address.dart';
import 'ipwhois_model.dart';
import 'ipwhois_service.dart';
import 'otp_response_model.dart';
import 'otp_status_request_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Info App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DeviceInfoScreen(),
    );
  }
}

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  Map<String, dynamic>? _deviceData;
  String? _macAddress;
  String? _ipAddress;
  String? _country;
  String? _city;
  String? _region;
  String? _countryCode;
  String? _isp;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  String? _otpStatusResponse;
  @override
  void initState() {
    super.initState();
    // Fetch device info after the build is complete
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
    // Request necessary permissions
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
      deviceData = {
        "Error": "Failed to get platform version: '${e.toString()}'"
      };
    }

    if (mounted) {
      setState(() {
        _deviceData = deviceData;
      });
    }
  }

  getDeviceName() async {
    String deviceName = await BluetoothInfo.getDeviceName();
    print('Device Name: $deviceName');
  }

  Future<void> _fetchNetworkData() async {
    final info = NetworkInfo();

    String? macAddress;
    String? ipAddress;

    try {
      macAddress =
          await info.getWifiBSSID(); // WiFi BSSID often serves as MAC address
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
       // _ipAddress = ipAddress;
      });
    }
  }


  Future<void> _fetchCountryAndIsp(String ipAddress) async {
    try {
      IpCountryData countryData = await IpCountryLookup().getIpLocationData();
      final result =  countryData;

      if (mounted) {
        setState(() {
          _country = result.country_name;

          _isp = result.isp;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _country = "Error fetching country";
          _isp = "Error fetching ISP";
        });
      }
    }
  }


  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return {
//'Board': build.board,
    //  'Bootloader': build.bootloader,
      'Brand': build.brand,
     // 'Device': build.device,
      'Display': build.display,
      'Fingerprint': build.fingerprint,
      'Hardware': build.hardware,
    //  'Host': build.host,
//      'ID': build.id,
      'Manufacturer': build.manufacturer,
      'Model': build.model,
   //   'Product': build.product,
  //    'Tags': build.tags,
   //   'Type': build.type,
      'Android ID': build.id,
  //    'Build Fingerprint': build.fingerprint,
 //     'SDK Int': build.version.sdkInt,
 //     'Security Patch': build.version.securityPatch,
  //    'Release': build.version.release,
   //   'Preview SDK Int': build.version.previewSdkInt,
   //   'Incremental': build.version.incremental,
  //    'Is Physical Device': build.isPhysicalDevice,
 //     'Supported 64-bit ABIs': build.supported64BitAbis.join(', '),
 //     'Supported 32-bit ABIs': build.supported32BitAbis.join(', '),
 //     'Supported ABIs': build.supportedAbis.join(', '),
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
      'Node Name': data.utsname.nodename,
      'Release': data.utsname.release,
      'Sysname': data.utsname.sysname,
      'Version': data.utsname.version,
      'Is Physical Device': data.isPhysicalDevice,
    };
  }
  IpWhoIsModel? _ipDetails;
  bool _loading = false;
  String? _errorMessage;

  final IpWhoisService _ipWhoisService = IpWhoisService();

  _fetchIpDetails() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final ipDetailsResponse = await _ipWhoisService.fetchIpWhoisDetails();
      print("Fetched IP details: ${ipDetailsResponse.ip}");
      setState(() {
        _ipDetails = ipDetailsResponse;
      });
      print("Set state with IP details: ${_ipDetails?.ip}");
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  //OtpStatusResponseModel? _otpStatusss;
  bool _loading2 = false;
  String? _errorMessage2;
  _fetchOtpStatus() async {
    // setState(() {
    //   _loading2 = true;
    //   _errorMessage2 = null;
    // });
    //
    // // Ensure _ipDetails is not null before making the request
    // if (_ipDetails == null) {
    //   setState(() {
    //     _errorMessage2 = 'IP details are not loaded yet.';
    //   });
    //   return;
    // }

    OtpStatusRequestModel requestModel = OtpStatusRequestModel(
      iP: _ipDetails?.ip,
      androidID: _deviceData!['Android ID'] ?? 'Unknown',
      manufacturer: _deviceData!['Manufacturer'] ?? 'Unknown',
      modelNo: _deviceData!['Model'] ?? 'Unknown',
      hardware: _deviceData!['Hardware'] ?? 'Unknown',
      macAddress: _macAddress!,
      iEMI: 'cecec', // This should be fetched properly if needed
      userName: _nameController.text, // This should be fetched properly if needed
      phoneNo: _numberController.text, // This should be fetched properly if needed
      geoLocation: _ipDetails?.city ?? 'Unknown',
      brand: _deviceData!['Brand'] ?? 'Unknown',
      fingerprint: _deviceData!['Build Fingerprint'] ?? 'Unknown',
    );



    try {
      OtpStatusResponseModel response = await _ipWhoisService.otpStatus(requestModel);
      print("Fetched OTP status: ${response.response}");
      setState(() {
       _otpStatusResponse = response.response;

      });
    } catch (e) {
      setState(() {
        _errorMessage2 = e.toString();
        print('Error fetching OTP status: $e');
      });
    } finally {
      setState(() {
        _loading2 = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
      ),
      body: _deviceData == null &&
              _macAddress == null &&
              //_ipAddress == null &&
              _country == null &&
              _isp == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (_deviceData != null)
                  ..._deviceData!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                if (_macAddress != null)
                  _buildInfoTile('MAC Address', _macAddress!),



                if (_ipDetails?.city != null)
                  _buildInfoTile('City', _ipDetails!.city!),
                if (_ipDetails?.ip != null)
                  _buildInfoTile('IP', _ipDetails!.ip!),
                if (_ipDetails?.country != null)
                  _buildInfoTile('Country', _ipDetails!.country!),

                if (_ipDetails?.countryCapital != null)
                  _buildInfoTile('Capital', _ipDetails!.countryCapital!),
                if (_ipDetails?.region != null)
                  _buildInfoTile('Region', _ipDetails!.region!),



              ///textfields for name and number
                // Add text fields for name and number
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),

                // Add verify button
                ElevatedButton(
                  onPressed:(){
                    _fetchOtpStatus();
                    setState(() {

                    });
                  } ,
                  child: const Text('Verify'),
                ),

                // Display the OTP status response
                if (_otpStatusResponse != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'OTP Status: $_otpStatusResponse',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.blueGrey,
              ),
            ),
          ),


        ],
      ),
    );
  }
}
