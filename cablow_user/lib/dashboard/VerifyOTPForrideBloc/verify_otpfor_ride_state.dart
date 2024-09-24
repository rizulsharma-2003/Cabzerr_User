part of 'verify_otpfor_ride_bloc.dart';

@immutable
sealed class VerifyOtpforRideState {}

final class VerifyOtpforRideInitial extends VerifyOtpforRideState {}
final class VerifyOtpforRideLoading extends VerifyOtpforRideState {}
final class VerifyOtpforRideSuccess extends VerifyOtpforRideState {
  final res;
  VerifyOtpforRideSuccess({required this.res});
}
final class VerifyOtpforRideFailed extends VerifyOtpforRideState {}
