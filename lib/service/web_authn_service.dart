import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_info/constants/web_authn.dart';
import 'package:user_info/views/device_info_view/device_info_view.dart';
import 'package:webauthn/webauthn.dart';

class WebAuthnService {
  final Authenticator _authenticator = Authenticator(true, false);
//creating function for making credential and it will be called for webauthn registration
  Future<void> createCredentials(BuildContext context) async {
    try {
      final makeCredentialOptions = MakeCredentialOptions.fromJson(json.decode(makeCredentialJson));

      final Attestation attestation = await _authenticator.makeCredential(makeCredentialOptions);
      String credentialId = base64Encode(attestation.getCredentialId());

      // Here you would typically store the credential ID securely
      storeCredentialId(credentialId);
      //navigating to device info screen if registered using webauthn
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  DeviceInfoScreen()),
      );
      //success snack bar on webauthn registration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credential Created Successfully')),
      );
    } catch (e) {
      print('Error creating credentials: $e');
      //fail snack bar on webauthn registration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create credentials: $e')),
      );
    }
  }
//on registration we will have a key 'credentialId' storing that key in this function
  void storeCredentialId(String credentialId) async{
    // Simulate storing the credential ID
    // In a real application, store this securely (e.g., secure storage)
    final SharedPreferences prefs = await SharedPreferences.getInstance();

// Save an string value to 'credentialId' key.
    await prefs.setString('credentialId', credentialId);
    print('Storing Credential ID: $credentialId');
  }

  //creating function for webauthn login using the stored key 'credentialId'
  Future<void> getAssertion(BuildContext context, String credentialId) async {
    try {
      //retrieving the credentialId stored on registration
      String getAssertionJsonModified = '''
      {
        "allowCredentialDescriptorList": [{
            "id": "$credentialId",
            "type": "public-key"
        }],
        "authenticatorExtensions": "",
        "clientDataHash": "LTCT/hWLtJenIgi0oUhkJz7dE8ng+pej+i6YI1QQu60=",
        "requireUserPresence": true,
        "requireUserVerification": false,
        "rpId": "sultan"
      }''';

      final getAssertionOptions = GetAssertionOptions.fromJson(json.decode(getAssertionJsonModified));

      final Assertion assertion = await _authenticator.getAssertion(getAssertionOptions);
      //navigating to device info screen if webauthn logged in successfully
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  DeviceInfoScreen()),
      );
      //success snack bar on webauthn login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Successful')),
      );
    } catch (e) {
      print('Error during authentication: $e');
      //fail snack bar on webauthn login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e')),
      );
    }
  }

}
