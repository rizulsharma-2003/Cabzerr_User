import 'package:flutter_bloc/flutter_bloc.dart';
import '../apiServices.dart';
import 'get_driver_info_event.dart';
import 'get_driver_info_state.dart';

class DriverInfoBloc extends Bloc<DriverInfoEvent, DriverInfoState> {


  DriverInfoBloc() : super(DriverInfoInitial()) {
    on<GetDriverInfoEvent>((event, emit) async {
      // emit(DriverInfoLoading());
      try {
        final driverInfo = await ApiServices().getDriverInfo(userId: event.userId,);
        print('====dfskljflkas==$driverInfo');

        if (driverInfo != null) {
          emit(DriverInfoSuccess(driverInfo));
        } else {
          print('objqwertyuioect');
          emit(DriverInfoFailed("Failed to fetch driver information."));
        }
      } catch (e) {
        emit(DriverInfoFailed(e.toString()));
      }
    });
  }
}
