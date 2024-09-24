part of 'book_ride_bloc.dart';

@immutable
sealed class BookRideState {}

final class BookRideInitial extends BookRideState {}
final class BookRideLoading extends BookRideState {}
final class BookRideSuccess extends BookRideState {
  final res;
  BookRideSuccess({required this.res});
}
final class BookRideFailed extends BookRideState {}
