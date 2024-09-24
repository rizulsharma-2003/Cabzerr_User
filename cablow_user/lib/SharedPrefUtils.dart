import 'package:shared_preferences/shared_preferences.dart';

class SharedPreffUtils {
  String apiTokenKey = 'barrier_token';
  String isLoggedin = 'isLogin';
  String userIdKey = 'user_id';
  String firstNameKey = 'first_name';
  String lastNameKey = 'last_name';
  String emailKey = 'email';
  String mobileNumberKey = 'mobile_number';
  String otpKey = 'otp';
  String otpExpiryKey = 'otp_expiry';
  String deviceIdKey = 'device_id';
  String addressID = 'AddressID';
  String address = 'address';
  String selectedMobileNOForDelivery = 'selectedMobileNOForDelivery';

  Future<String?> getStringValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> saveStringValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
  // Save the profile image for the current user
  Future<void> saveProfileImage(String userId, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_$userId', imagePath);
  }

  // Retrieve the profile image for the current user
  Future<String?> getProfileImage(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_$userId');
  }
}
