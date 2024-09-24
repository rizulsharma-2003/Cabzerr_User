part of 'book_ride_bloc.dart';

@immutable
sealed class BookRideEvent {}
 class SendBookRideDetailsEvent extends BookRideEvent{
  final String rideId;
  final String sourceaddress;
  final double sourcelatitude;
  final double sourceLongitudex;
  final String destinationaddress;
  final double destinationlatitude;
  final double destinationLongitudex;
  final String vehicleType;
  final double price;

  SendBookRideDetailsEvent({
   required this.rideId,
   required this.sourceaddress,
   required this.sourcelatitude,
   required this.sourceLongitudex,
   required this.destinationaddress,
   required this.destinationlatitude,
   required this.destinationLongitudex,
   required this.vehicleType,
   required this.price,
  });
}