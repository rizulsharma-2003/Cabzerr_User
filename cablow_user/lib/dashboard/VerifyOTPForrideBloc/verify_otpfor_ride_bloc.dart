import 'package:bloc/bloc.dart';
import 'package:cablow_user/apiServices.dart';
import 'package:meta/meta.dart';

part 'verify_otpfor_ride_event.dart';
part 'verify_otpfor_ride_state.dart';

class VerifyOtpforRideBloc extends Bloc<VerifyOtpforRideEvent, VerifyOtpforRideState> {
  VerifyOtpforRideBloc() : super(VerifyOtpforRideInitial()) {
    on<SendVerifyOtpforRideEvent>((event, emit) async {
      emit(VerifyOtpforRideLoading());
      try{
        final res=await ApiServices().checkOtp(rideId: event.rideID, otp: event.otp);
        if(res!=null){
          emit(VerifyOtpforRideSuccess(res: res));

        }else{
          emit(VerifyOtpforRideFailed());

        }
      }catch(e){
        emit(VerifyOtpforRideFailed());

      }

    });
  }
}
