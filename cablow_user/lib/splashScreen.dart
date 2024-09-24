import 'package:cablow_user/Authentication/LoginScreen.dart';
import 'package:cablow_user/SharedPrefUtils.dart';
import 'package:cablow_user/check.dart';
import 'package:cablow_user/googleMapsScreen/MapScreen.dart';
import 'package:cablow_user/my_helpers/helps/navigator_help.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   isLoggedin()async{
     SharedPreferences sp = await SharedPreferences.getInstance();

     final login= sp.getBool(SharedPreffUtils().isLoggedin);
     if(login==true){
       navigatorPushReplace(context, const AttendanceScreen());
     }else{
       navigatorPushReplace(context,  Loginscreen());
     }
   }
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      isLoggedin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Image.asset(
          'assets/image/Cablow.png',
          width: 350, // Adjust width and height as needed
          height: 350,
        ),
      ),
    );
  }
}