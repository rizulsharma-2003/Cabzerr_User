abstract class DriverInfoEvent {}

class GetDriverInfoEvent extends DriverInfoEvent {
  final String userId;
  final String rideId;
  final String datetime;

  GetDriverInfoEvent( {required this.userId, required this.rideId,required this.datetime,});
}
