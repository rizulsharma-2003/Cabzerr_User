import 'package:bloc/bloc.dart';
import 'package:cablow_user/apiServices.dart';
import 'package:meta/meta.dart';

part 'book_ride_event.dart';
part 'book_ride_state.dart';

class BookRideBloc extends Bloc<BookRideEvent, BookRideState> {
  BookRideBloc() : super(BookRideInitial()) {
    on<SendBookRideDetailsEvent>((event, emit) async {
      emit(BookRideLoading());
      try {
        final res = await ApiServices().requestRide(
          rideId: event.rideId,
          sourceaddress: event.sourceaddress,
          sourcelatitude: event.sourcelatitude,
          sourcelongitude: event.sourceLongitudex,
          destinationAddress: event.destinationaddress,
          destinationlatitude: event.destinationlatitude,
          destinationLongitude: event.destinationLongitudex,
          vehicletype: event.vehicleType,
          price: event.price,  // Corrected line
        );
        print('bloc data =====$res');
        if (res != null) {
          emit(BookRideSuccess(res: res));
        } else {
          emit(BookRideFailed());
        }
      } catch (e) {
        print('error at book ride bloc $e');
        emit(BookRideFailed());
      }
    });
  }
}
