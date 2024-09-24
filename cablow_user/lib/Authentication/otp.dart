
import 'package:cablow_user/Authentication/LoginScreen.dart';
import 'package:cablow_user/SharedPrefUtils.dart';
import 'package:cablow_user/googleMapsScreen/MapScreen.dart';
import 'package:cablow_user/my_helpers/helps/navigator_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'otpVerificationBloc/otp_verification_bloc.dart';

class Otpscreen extends StatelessWidget {
  final phoneno;
  final otp;


  Otpscreen({super.key, required this.phoneno,required this.otp, });

  TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) => OtpVerificationBloc(),
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(otp.toString()),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: PinCodeTextField(
                controller: _otpController,
                appContext: context,
                pastedTextStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                length: 4,
                keyboardType: TextInputType.number,
                animationType: AnimationType.none,
                validator: (v) {
                  if (v!.length < 4) {
                    return "Invalid OTP";
                  } else {
                    return null;
                  }
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 60,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  activeBorderWidth: 0,
                  borderWidth: 20,
                  selectedColor: Colors.black,
                  selectedBorderWidth: 0,
                  errorBorderColor: Colors.black,
                  errorBorderWidth: 0,
                  activeColor: Colors.black,
                  inactiveColor: Colors.black,
                  inactiveBorderWidth: 0,
                ),
                cursorColor: Colors.black,
                enableActiveFill: false,
                onChanged: (value) {},
              ),
            ),
            SizedBox(
              height: height / 30,
            ),
            BlocConsumer<OtpVerificationBloc, OtpVerificationState>(
              listener: (context, state) async {

                if (state is OtpVerificationSuccess) {
                  SharedPreferences sp= await SharedPreferences.getInstance();
                  sp.setBool(SharedPreffUtils().isLoggedin, true);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendanceScreen(),));
                  // navigatorPush(context: context, newScreen: const RidesScreen());
                }
                if(state is DocumentsNotApproved){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Success'),
                        content: const Text('Your documents are not approved yet we will notify you once they are approved '),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              navigatorPushReplace(context, Loginscreen());
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              builder: (context, state) {
                if (state is OtpVerificationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return InkWell(
                  onTap: () {
                    context.read<OtpVerificationBloc>().add(
                        VerifyOtpVerificationEvent(
                            mobleNo: phoneno.toString(), otp: _otpController.text));
                  },
                  child: Container(
                    width: width / 1.1,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('Get OTP')),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
