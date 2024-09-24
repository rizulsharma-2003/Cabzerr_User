part of 'ride_history_bloc.dart';

@immutable
sealed class RideHistoryState {}

final class RideHistoryInitial extends RideHistoryState {}
final class RideHistoryLoading extends RideHistoryState {}
final class RideHistorySuccess extends RideHistoryState {
  final historyData;
  RideHistorySuccess({required this.historyData});
}
final class RideHistoryFailed extends RideHistoryState {}
