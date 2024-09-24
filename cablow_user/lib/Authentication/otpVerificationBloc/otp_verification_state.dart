part of 'otp_verification_bloc.dart';

@immutable
sealed class OtpVerificationState {}

final class OtpVerificationInitial extends OtpVerificationState {}
final class OtpVerificationLoading extends OtpVerificationState {}
final class OtpVerificationSuccess extends OtpVerificationState {
  final res;
  OtpVerificationSuccess({required this.res});
}
final class OtpVerificationFailed extends OtpVerificationState {}
final class DocumentsNotSubmitted extends OtpVerificationState {}
final class DocumentsNotApproved extends OtpVerificationState {}
