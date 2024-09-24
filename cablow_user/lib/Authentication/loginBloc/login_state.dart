part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}
final class LoginLoading extends LoginState {}
final class LoginSuccess extends LoginState {
  final res;
  LoginSuccess({required this.res});
}
final class LoginFailed extends LoginState {}
