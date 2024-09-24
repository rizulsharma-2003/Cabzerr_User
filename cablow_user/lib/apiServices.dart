import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cablow_user/SharedPrefUtils.dart';

import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
  final String baseURL = 'https://cablow.com/cablow/api/';


  getRideHistory() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final token = sp.getString(SharedPreffUtils().apiTokenKey);
    final userid = sp.getString(SharedPreffUtils().userIdKey);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final url='${baseURL}user/user_id_$userid/ride-history';
    try{
      final response=await http.get(Uri.parse(url), headers: headers);

      // print('======${response.body}');
      print(response.statusCode);
      print(response.request);
      if(response.statusCode==200){
        final data=jsonDecode(response.body);
        return data;
      }else{
        return null;
      }
    }catch(e){
      log('error at api call ride history $e');
      return null;
    }
  }



  checkOtp({required final rideId, required final otp}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final driverID = sp.getString(SharedPreffUtils().userIdKey);
    final url = '${baseURL}ride/verify-otp/ride_id_$rideId/driver_id_$driverID';

    final token = sp.getString(SharedPreffUtils().apiTokenKey);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = {
      "otp": otp.toString()
    };

    // print('=====================$body ');

    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: headers,
    );

    print(response.body);
    print(response.request);
    print(response.statusCode);
    print(token);
    if (response.statusCode == 200) {
      final jsondata = jsonDecode(response.body);
      return jsondata;
    } else {
      return null;
    }
  }


  requestRide(
      {required final vehicletype,required final price,required final rideId, required sourceaddress, required sourcelatitude, required sourcelongitude, required destinationAddress, required destinationlatitude, required destinationLongitude}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final userID = sp.getString(SharedPreffUtils().userIdKey);
    final url = '${baseURL}ride/request/user_id_$userID';

    final token = sp.getString(SharedPreffUtils().apiTokenKey);


    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = {
      "source_address": sourceaddress,
      "source_latitude": sourcelatitude,
      "source_longitude": sourcelongitude,
      "destination_address": destinationAddress,
      "destination_latitude": destinationlatitude,
      "destination_longitude": destinationLongitude,
      "vehicle_type": vehicletype,
      "price": price

    };


    print('=====================$body ');

    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: headers,
    );

    print(response.request);
    print(response.statusCode);
    print(response.body);
    print(token);
    if (response.statusCode == 200) {
      final jsondata = jsonDecode(response.body);
      return jsondata;
    } else {
      return null;
    }
  }


  verifyOtpAuth(String mobileNumber, String otp) async {
    print(mobileNumber);
    print('=============$otp');
    final url = Uri.parse('${baseURL}verify-otp');
    SharedPreferences sp = await SharedPreferences.getInstance();
    final token = sp.getString(SharedPreffUtils().apiTokenKey);

    if (token == null) {
      print('token');
      print('Error: Token not found in shared preferences');
      return null; // Handle the case where the token is not available
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'mobile_number': mobileNumber.replaceAll(" ", ""),
      'otp': otp,
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Handle success
        print('Response: ${response.body}');
        final responseData = jsonDecode(response.body);
        final userdata = responseData['User Detail'];

        print('Response ==========================data: ${userdata}');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        SharedPreffUtils prefsUtils = SharedPreffUtils();

        // await prefs.setString(prefsUtils.apiTokenKey, responseData['bearer_token']);
        await prefs.setString(prefsUtils.userIdKey, userdata['id'].toString());


        return response.body;
      } else if (response.statusCode == 300) {
        return 1;
      }

      else if (response.statusCode == 250) {
        // Handle error
        print('Error: ${response.statusCode} - ${response.body}');

        return 0;
      }
    } catch (e) {
      // Handle exception
      print('Exception: $e');
      return null;
    }
  }


  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? 'Unknown'; // Unique ID on Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'Unknown'; // Unique ID on iOS
    }
    return 'Unknown';
  }


  Future<String?> loginDriver({
    required String mobileNumber,
    required String name,
  }) async {
    final url = Uri.parse('${baseURL}send-otp');
    final headers = {'Content-Type': 'application/json'};
    final String deviceId = await getDeviceId();
    final mobile = mobileNumber.replaceAll(" ", "");

    final body = {
      "full_name": name,
      'mobile_number': mobile,
      'device_id': deviceId,
    };

    print(body);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: ${responseData}');

        // Initialize SharedPreferences and SharedPreffUtils
        SharedPreferences prefs = await SharedPreferences.getInstance();
        SharedPreffUtils prefsUtils = SharedPreffUtils();

        // Save the bearer token and user ID
        await prefs.setString(prefsUtils.apiTokenKey, responseData['bearer_token']);
        await prefs.setString(prefsUtils.userIdKey, responseData['driver_id'].toString());

        // Save the mobile number and full name
        await prefs.setString(prefsUtils.mobileNumberKey, mobile);
        await prefs.setString(prefsUtils.firstNameKey, name);

        return response.body;
      } else if (response.statusCode == 302) {
        return null;
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle any other errors
      print('Exception: $e');
      return null;
    }
  }


  getDriverInfo({
    required String userId,

  }) async {
    // Obtain the API token from SharedPreferences
    SharedPreferences sp = await SharedPreferences.getInstance();
    final token = sp.getString(SharedPreffUtils().apiTokenKey);

    // Get the current time and subtract 5 hours and 31 minutes
    DateTime now = DateTime.now();
    DateTime adjustedTime = now.subtract(Duration(hours: 5, minutes: 31));

    // Format the adjusted DateTime without milliseconds
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(adjustedTime);
    print('===========date and time $formattedDateTime');

    // Construct the URL with the provided userId and adjusted datetime
    final url = '${baseURL}rides/user_id_$userId/datetime_$formattedDateTime';

    // Set up the headers, including the Authorization header with the bearer token
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Make the GET request
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    // Print out response details for debugging purposes
    // print(response.body);
    print(response.statusCode);
    print(response.request);

    // If the response status code is 200, return the parsed JSON data
    if (response.statusCode == 200) {
      print('object');
      final jsondata = jsonDecode(response.body);
      // print(jsondata);
      return jsondata;
    }
  }

}