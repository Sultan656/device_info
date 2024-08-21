import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:user_info/models/get_all_channel_price.dart';
import 'package:user_info/models/otp_status_request_model.dart';

import 'models/ipwhois_model.dart';
import 'models/otp_response_model.dart';
import 'models/update_channel_price.dart';

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

    Future<List<GetAllChannelPriceResponse>> getAllChannelPrice() async {
      final response = await http.get(Uri.parse('http://34.18.47.112:8000/channels/?skip=0&limit=10'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        // Check if jsonData is a list or a map and convert accordingly
        if (jsonData is List) {
          return jsonData.map((item) => GetAllChannelPriceResponse.fromJson(item as Map<String, dynamic>)).toList();
        } else if (jsonData is Map) {
          // Explicitly cast the map
          return [GetAllChannelPriceResponse.fromJson(jsonData as Map<String, dynamic>)];
        } else {
          throw Exception('Unexpected JSON format');
        }
      } else {
        throw Exception('Failed to load channel prices');
      }
    }


    Future<bool> updateChannelPrice(List<UpdateChannelPriceRequest> requests) async {
      var url = Uri.parse('http://34.18.47.112:8000/channels/bulk-update/');
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requests.map((req) => req.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        return true; // or handle the response data as needed
      } else {
        print('Failed to update channel price: ${response.body}');
        return false;
      }
    }


  Future<OtpStatusResponseModel> otpStatus(OtpStatusRequestModel otpStatusRequestModel) async {
    // Serialize the request model to JSON
    final body = json.encode(otpStatusRequestModel);
    int contentLength = body.length;
    // Perform the HTTP POST request

    final response = await http.post(
      Uri.parse('http://34.18.47.112:8000/check_user'),

      body: body,
        headers: {'Content-Type': 'application/json',
          'Content-Length': contentLength.toString(),
        }

    );
    // Check if the response status is OK
    if (response.statusCode == 200) {

      // Parse and return the response model
      return OtpStatusResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load OTP status');
    }
  }
}
