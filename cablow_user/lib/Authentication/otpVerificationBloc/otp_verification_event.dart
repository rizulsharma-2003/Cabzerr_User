part of 'otp_verification_bloc.dart';

@immutable
sealed class OtpVerificationEvent {}
class VerifyOtpVerificationEvent  extends OtpVerificationEvent{
  final mobleNo;
  final otp;
  VerifyOtpVerificationEvent({required this.mobleNo,required this.otp});
}
