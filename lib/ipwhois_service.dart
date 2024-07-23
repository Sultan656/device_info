import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:user_info/otp_status_request_model.dart';

import 'ipwhois_model.dart';
import 'otp_response_model.dart';

class IpWhoisService {
    String _baseUrl = 'http://ipwhois.app/json/';

  Future<IpWhoIsModel> fetchIpWhoisDetails() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      print("response==========${response.body}");
      return IpWhoIsModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load IP WHOIS details');
    }
  }



  Future<OtpStatusResponseModel> otpStatus(OtpStatusRequestModel otpStatusRequestModel) async {
    // Serialize the request model to JSON
    final body = json.encode(otpStatusRequestModel);
    // int contentLength = body.length;
    // Perform the HTTP POST request

    final response = await http.post(
      Uri.parse('http://34.18.9.89:9191/check_user/'),

      body: body,
        headers: {'Content-Type': 'application/json',
          //'Content-Length': contentLength.toString(),
        }

    );
    print("status:=======${response.body}");
    // Check if the response status is OK
    if (response.statusCode == 200) {

      // Parse and return the response model
      return OtpStatusResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load OTP status');
    }
  }
}
