part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}
 class SendLoginEvent extends LoginEvent{
 final name;
  final mobileNo;
  SendLoginEvent({required this.name,required this.mobileNo});
}
