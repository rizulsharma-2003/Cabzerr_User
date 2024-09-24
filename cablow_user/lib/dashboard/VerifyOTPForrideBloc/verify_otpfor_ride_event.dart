part of 'verify_otpfor_ride_bloc.dart';

@immutable
sealed class VerifyOtpforRideEvent {}
 class SendVerifyOtpforRideEvent extends VerifyOtpforRideEvent{
  final rideID;
  final otp;
  SendVerifyOtpforRideEvent( {required this.rideID,required this.otp});
}
