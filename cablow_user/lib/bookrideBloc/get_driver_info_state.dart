abstract class DriverInfoState {}

class DriverInfoInitial extends DriverInfoState {}

class DriverInfoLoading extends DriverInfoState {}

class DriverInfoSuccess extends DriverInfoState {
  final driverInfo;

  DriverInfoSuccess(this.driverInfo);
}

class DriverInfoFailed extends DriverInfoState {
  final String error;

  DriverInfoFailed(this.error);
}
